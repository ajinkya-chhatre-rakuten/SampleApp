/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationCore.h>
#import <RAuthenticationChallenge/RAuthenticationChallenge.h>
#import "_RAuthenticationHelpers.h"

static NSString* const _RChallengePageId = @"399206e3-905a-4d27-937d-5786ba07e742";
static NSString* const _RChallengeUrlPro = @"https://challenger.api.rakuten.co.jp";
static NSString* const _RChallengeUrlStg = @"https://stg-challenger.api.rakuten.co.jp";

@interface RJapanIchibaUserAuthenticator ()
@property (nonatomic, copy, nullable) NSString *privacyPolicyVersion;
@property (nonatomic, copy) NSString *challengePageId;

@end

@implementation RJapanIchibaUserAuthenticator

+ (void)load
{
    _RAuthenticationLog(@"Registered authenticator \"%@\" with default service \"%@\".", NSStringFromClass(self), self.defaultServiceIdentifier);
}

#pragma mark RAuthenticator
+ (NSString *)defaultServiceIdentifier
{
    return @"jp.co.rakuten.sdk.authentication.sso.japanId";
}

+ (nullable NSSet<NSString *> *)scopesForPromotion
{
    static NSSet<NSString *> *scopesForPromotion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scopesForPromotion = [NSSet setWithObject:@"Promotion@Refresh"];
    });
    return scopesForPromotion;
}

- (instancetype)initWithSettings:(RAuthenticationSettings *)settings
{
    if (self = [super initWithSettings:settings])
    {
        _challengePageId = _RChallengePageId;
    }
    return self;
}

- (void)setUsername:(NSString * __nullable)username
{
    NSString *cleanedUsername = [[username componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] componentsJoinedByString:@""];
    if (!_RAuthenticationObjectsEqual(cleanedUsername, super.username))
    {
        super.username = cleanedUsername;
    }
}

- (NSOperation *)requestTokenWithCompletion:(void(^)(RAuthenticationToken *token, NSError *error))completion
{
    NSParameterAssert(completion);
    if (!completion) { return nil; }
    
    _privacyPolicyVersion = @"20170213";
    
    NSString                *username             = self.username,
    *password             = self.password,
    *serviceIdentifier    = self.raeServiceIdentifier,
    *privacyPolicyVersion = self.privacyPolicyVersion;
    NSSet                   *requestedScopes      = self.requestedScopes;
    RAuthenticationSettings *settings             = self.settings;
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSOperation *operation = _RAuthenticationDispatchGroupOperation(group, 0);
    operation.name = _RAuthenticationSelectorString(self, _cmd);
    
    NSString * baseUrl = [self.settings.baseURL.host hasPrefix:@"stg"] ? _RChallengeUrlStg : _RChallengeUrlPro;
    RAuthenticationChallengeClient * challengeClient = [[RAuthenticationChallengeClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl] pageId:_challengePageId];

    NSOperation *challengeOperation = [challengeClient requestChallengeWithCompletion:^(RAuthenticationSolvedChallenge * _Nullable solvedChallenge, NSError * _Nullable error) {
        if (_RAuthenticationShouldProceed(operation, error))
        {
            REJapanPasswordTokenRequestContext *context = [REJapanPasswordTokenRequestContext.alloc initWithUsername:username ?: @"" password:password ?: @""];
            context.serviceIdentifier    = serviceIdentifier;
            context.privacyPolicyVersion = privacyPolicyVersion;
            
            if (!error && solvedChallenge)
            {
                context.challengeParameters = [REChallengeParameters parametersWithPageId:solvedChallenge.pageId identifier:solvedChallenge.identifier result:solvedChallenge.result];
            }
            
            RETokenRequest *request = [RETokenRequest.alloc initWithClientIdentifier:settings.clientId ?: @"" clientSecret:settings.clientSecret ?: @"" context:context];
            request.scopes = requestedScopes;
            
            dispatch_group_enter(group);
            [[[_RAuthenticationEngineClient with:settings] tokenWithRequest:request
                                                            completionBlock:^(RETokenResult *result, NSError *error)
              {
                  if (_RAuthenticationShouldProceed(operation, error))
                  {
                      completion(result._convertedToken, error);
                  }
                  dispatch_group_leave(group);
              }] resume];
        }
        dispatch_group_leave(group);
    }];
    
    [operation addDependency:challengeOperation];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (NSOperation *)requestUserInformationWithToken:(RAuthenticationToken *)token
                                      completion:(void (^)(RAuthenticationAccountUserInformation *, NSError *))completion
{
    NSParameterAssert(token);
    NSParameterAssert(completion);
    if (!completion) { return nil; }

    RAuthenticationSettings *settings = self.settings;

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSOperation *operation = _RAuthenticationDispatchGroupOperation(group, 0);
    operation.name = _RAuthenticationSelectorString(self, _cmd);
    [self.operationQueue addOperation:operation];

    [[[_RAuthenticationMemberInformationClient with:settings] getNameWithRequest:[RMIGetNameRequest requestWithAccessToken:token.accessToken]
                                                                               completionBlock:^(RMIName *result, NSError *error)
    {
        /*
         * If the user doesn't have a profile, the request fails with a 404 "not_found" error.
         * Additionally, if the MemberInformation API doesn't exist, it fails with a "wrong_parameter" error.
         * If member's firstName and lastName are not set, the system returns "system_error" message with 500 HTTP status code.
         * In these cases, we silently ignore the error.
         */

        if ([error.domain isEqualToString:RWCAppEngineResponseParserErrorDomain] &&
            (error.code == RWCAppEngineResponseParserErrorResourceNotFound ||
             error.code == RWCAppEngineResponseParserErrorInvalidParameter ||
            (error.code == RWCAppEngineResponseParserErrorUnauthorized && [error.localizedDescription isEqualToString:@"system_error"])))
        {
            error = nil;
        }

        if (_RAuthenticationShouldProceed(operation, error))
        {
            RAuthenticationAccountUserInformation *userInfo = nil;
            if (!error)
            {
                userInfo = RAuthenticationAccountUserInformation.new;
                userInfo.firstName  = result.firstName;
                userInfo.lastName   = result.lastName;
            }

            completion(userInfo, error);
        }
        dispatch_group_leave(group);
    }] resume];
    return operation;
}

- (NSOperation *)requestTrackingIdentifierWithToken:(RAuthenticationToken *)token
                                         completion:(void(^)(NSString * __nullable trackingIdentifier, NSError * __nullable error))completion
{
    NSParameterAssert(token);
    NSParameterAssert(completion);
    if (!completion) { return nil; }

    RAuthenticationSettings *settings = self.settings;
    RIIGetEncryptedEasyIdRequest *request = [RIIGetEncryptedEasyIdRequest requestWithAccessToken:token.accessToken];

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSOperation *operation = _RAuthenticationDispatchGroupOperation(group, 0);
    operation.name = _RAuthenticationSelectorString(self, _cmd);

    [[[_RAuthenticationIdInformationClient with:settings] getEncryptedEasyIdWithRequest:request
                                                                        completionBlock:^(RIIEncryptedEasyId *result, NSError *error)
    {
        if (_RAuthenticationShouldProceed(operation, error))
        {
            completion(error ? nil : result.easyId, error);
        }
        dispatch_group_leave(group);
    }] resume];

    [self.operationQueue addOperation:operation];
    return operation;
}

- (NSOperation *)revokeToken:(RAuthenticationToken *)token
                  completion:(void(^)(NSError *error))completion
{
    NSParameterAssert(token);
    NSParameterAssert(completion);
    if (!completion) { return nil; }

    RAuthenticationSettings *settings = self.settings;
    RERevokeTokenRequest *request = [RERevokeTokenRequest requestWithClientIdentifier:settings.clientId
                                                                         clientSecret:settings.clientSecret
                                                                          accessToken:token.accessToken];
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSOperation *operation = _RAuthenticationDispatchGroupOperation(group, 0);
    operation.name = _RAuthenticationSelectorString(self, _cmd);
    [self.operationQueue addOperation:operation];
    [[[_RAuthenticationEngineClient with:settings] revokeTokenWithRequest:request
                                                          completionBlock:^(BOOL __unused result, NSError *error)
    {
        if ([error.domain isEqualToString:RWCAppEngineResponseParserErrorDomain] &&
            (error.code == RWCAppEngineResponseParserErrorInvalidParameter ||
             error.code == RWCAppEngineResponseParserErrorUnauthorized))
        {
            // The access token is already invalid, so we can simply ignore the error
            error = nil;
        }

        if (_RAuthenticationShouldProceed(operation, error))
        {
            completion(error);
        }
        dispatch_group_leave(group);
    }] resume];
    return operation;
}

- (NSOperation *)refreshToken:(RAuthenticationToken *)token
                       scopes:(NSSet *)scopes
                   completion:(void(^)(NSError *error))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(token.refreshToken);
    if (!completion) { return nil; }

    RAuthenticationSettings *settings = self.settings;
    RETokenRequest *request = [RETokenRequest refreshTokenRequestWithClientIdentifier:settings.clientId
                                                                         clientSecret:settings.clientSecret
                                                                         refreshToken:(id)token.refreshToken];
    request.scopes = scopes;

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSOperation *operation = _RAuthenticationDispatchGroupOperation(group, 0);
    operation.name = _RAuthenticationSelectorString(self, _cmd);
    [self.operationQueue addOperation:operation];

    [[[_RAuthenticationEngineClient with:settings] tokenWithRequest:request
                                                    completionBlock:^(RETokenResult *result, NSError *error)
    {
        if (_RAuthenticationShouldProceed(operation, error))
        {
            if (!error)
            {
                [result _populateExistingToken:token];
            }
            completion(error);
        }
        dispatch_group_leave(group);
    }] resume];
    return operation;
}

#pragma mark NSObject
- (void)dealloc
{
    [self.operationQueue cancelAllOperations];
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
static NSString * const kServiceIdentifierKey = @"jid.si";

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_raeServiceIdentifier forKey:kServiceIdentifierKey];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder]))
    {
        _raeServiceIdentifier = (id)[coder decodeObjectOfClass:NSString.class forKey:kServiceIdentifierKey];
    }
    return self;
}
@end
