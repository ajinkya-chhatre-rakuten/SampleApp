/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationCore.h>
#import "_RAuthenticationHelpers.h"
#import "_RAuthenticationTracking.h"

@interface RAuthenticator ()
@property (copy, nonatomic) NSOperationQueue *operationQueue;
@end

@implementation RAuthenticator

+ (NSString *)defaultServiceIdentifier
{
    return nil;
}

+ (nullable NSSet<NSString *> *)scopesForPromotion
{
    return nil;
}

- (instancetype)initWithSettings:(RAuthenticationSettings *)settings
{
    NSParameterAssert(settings.isValid);
    if (!settings.isValid) { return nil; }

    if ((self = [super init]))
    {
        _settings        = settings.copy;
        _serviceIdentifier = [self.class defaultServiceIdentifier];
        _operationQueue = NSOperationQueue.new;
        if (!_settings || !_operationQueue) { return nil; }
    }
    return self;
}

- (NSOperation *)requestTokenWithCompletion:(void (^ __unused)(RAuthenticationToken *, NSError *))completion
{
    // Must be implemented by subclasses
    RAUTH_INVALID_METHOD;
}

- (NSOperation *)requestUserInformationWithToken:(RAuthenticationToken __unused *)token
                                      completion:(void (^ __unused)(RAuthenticationAccountUserInformation *, NSError *))completion
{
    // Must be implemented by subclasses
    RAUTH_INVALID_METHOD;
}

- (NSOperation *)requestTrackingIdentifierWithToken:(RAuthenticationToken *)token
                                         completion:(void(^)(NSString * __nullable trackingIdentifier, NSError * __nullable error))completion
{
    // Must be implemented by subclasses
    RAUTH_INVALID_METHOD;
}


- (NSOperation *)revokeToken:(RAuthenticationToken __unused *)token
                  completion:(void(^ __unused)(NSError *error))completion
{
    // Must be implemented by subclasses
    RAUTH_INVALID_METHOD;
}

- (NSOperation *)refreshToken:(RAuthenticationToken __unused *)token
                       scopes:(NSSet __unused *)scopes
                   completion:(void(^ __unused)(NSError *error))completion
{
    // Must be implemented by subclasses
    RAUTH_INVALID_METHOD;
}


- (NSOperation *)loginWithCompletion:(rauthentication_account_completion_block_t)completion
{
    NSParameterAssert(completion);
    if (!completion) { return nil; }

    NSString *serviceIdentifier = self.serviceIdentifier;
    NSString *name = NSBundle.mainBundle.bundleIdentifier ?: @"jp.co.rakuten.sdtd";
    if ([self isKindOfClass:RUserPasswordAuthenticator.class])
    {
        NSString *username = ((RUserPasswordAuthenticator *)self).username;
        if (username.length)
        {
            name = username;
        }
    }

    __block RAuthenticationAccount *account = [RAuthenticationAccount loadAccountWithName:name service:serviceIdentifier error:0];
    if (!account)
    {
        account                   = RAuthenticationAccount.new;
        account.name              = name;
        account.serviceIdentifier = serviceIdentifier;
    }

    __block NSError *error = nil;
    account.authenticatorClass = self.class;

    /*
     * Now the dirty work
     */
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);

    NSBlockOperation *operation = _RAuthenticationDispatchGroupOperation(group, ^{
        completion(error ? nil : account, error);
    });
    [self.operationQueue addOperation:operation];

    typeof(self) __weak weakSelf = self;
    [self requestTokenWithCompletion:^(RAuthenticationToken *token, NSError *tokenError) {
        if (tokenError)
        {
            [_RAuthenticationTracking broadcastLoginFailureWithError:tokenError];
            [_RAuthenticationTracking setLoginMethod:_RAuthenticationLoginMethodUnknown];
            error = tokenError;
        }
        else
        {
            account.token = token;

            /*
             * Beyond this point, success criteria are relaxed:
             * - If we can't fetch user's information, we only fail if we don't already have existing data;
             * - We don't fail if we can't acquire the tracking identifier (which might be because the app
             *   lacks the proper scope.
             */
            if (!account.trackingIdentifier)
            {
                dispatch_group_enter(group);
                [weakSelf requestTrackingIdentifierWithToken:token completion:^(NSString *trackingIdentifier, NSError *__unused ignored) {
                    account.trackingIdentifier = trackingIdentifier;
                    dispatch_group_leave(group);
                }];
            }

            dispatch_group_enter(group);
            [weakSelf requestUserInformationWithToken:token completion:^(RAuthenticationAccountUserInformation *userInfo, NSError *userInfoError) {
                if (userInfoError && !account.userInformation) error = userInfoError;
                else
                {
                    /*
                     * Merge newly-acquired values with previously-held ones.
                     */
                    RAuthenticationAccountUserInformation *merged = account.userInformation;
                    if (merged)
                    {
                        if (userInfo)
                        {
                            if (userInfo.firstName.length)  { merged.firstName  = userInfo.firstName; }
                            if (userInfo.middleName.length) { merged.middleName = userInfo.middleName; }
                            if (userInfo.lastName.length)   { merged.lastName   = userInfo.lastName; }
                            merged.shouldAgreeToTermsAndConditions = userInfo.shouldAgreeToTermsAndConditions;
                        }
                    }
                    else
                    {
                        merged = userInfo;
                    }
                    
                    account.userInformation = merged;
                }

                dispatch_group_leave(group);
            }];
        }

        dispatch_group_leave(group);
    }];

    return operation;
}

- (BOOL)isValid
{
    return self.requestedScopes.count > 0 && self.settings.isValid;
}

- (BOOL)isEqualToAuthenticator:(RAuthenticator *)other
{
    if (![other isMemberOfClass:self.class] || other.hash != self.hash) { return NO; }
    return
        _RAuthenticationObjectsEqual(_requestedScopes,   other.requestedScopes)   &&
        _RAuthenticationObjectsEqual(_serviceIdentifier, other.serviceIdentifier) &&
        _RAuthenticationObjectsEqual(_settings,          other.settings);
}

#pragma mark NSObject
- (instancetype)init
{
    RAUTH_INVALID_METHOD;
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"<%@: %p>"
            @"\n\t  requestedScopes=%@"
            @"\n\t         settings=%@"
            @"\n\tserviceIdentifier=%@",
            NSStringFromClass(self.class), self,
            [_requestedScopes.allObjects componentsJoinedByString:@","],
            _settings.description,
            _serviceIdentifier];
}

- (NSUInteger)hash
{
    return _requestedScopes.hash ^ _settings.hash ^ _serviceIdentifier.hash;
}

- (BOOL)isEqual:(id)other
{
    if (other == self) { return YES; }
    if (![other isKindOfClass:self.class]) { return NO; }
    return [self isEqualToAuthenticator:(RAuthenticator *)other];
}

#pragma mark <NSCopying>
- (instancetype)copyWithZone:(NSZone *)zone
{
    RAuthenticator *copy = [[self.class allocWithZone:zone] initWithSettings:self.settings];
    copy.requestedScopes   = self.requestedScopes;
    copy.serviceIdentifier = self.serviceIdentifier;
    return copy;
}

#pragma mark <NSSecureCoding>
+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark <NSCoding>
/*
 * Local keys used for NSCoding. Should not be modified, even if the properties get renamed.
 */
static NSString * const kRequestedScopesKey   = @"requestedScopes";
static NSString * const kSettingsKey          = @"settings";
static NSString * const kServiceIdentifierKey = @"serviceIdentifier";

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_requestedScopes        forKey:kRequestedScopesKey];
    [coder encodeObject:_settings               forKey:kSettingsKey];
    [coder encodeObject:_serviceIdentifier      forKey:kServiceIdentifierKey];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    RAuthenticationSettings *settings = [coder decodeObjectOfClass:RAuthenticationSettings.class forKey:kSettingsKey];
    if ((self = [self initWithSettings:settings]))
    {
        _requestedScopes   = [coder decodeObjectOfClass:NSSet.class    forKey:kRequestedScopesKey];
        _serviceIdentifier = [coder decodeObjectOfClass:NSString.class forKey:kServiceIdentifierKey];
    }
    return self;
}

@end
