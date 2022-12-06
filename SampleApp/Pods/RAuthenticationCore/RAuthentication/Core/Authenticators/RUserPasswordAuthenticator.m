/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationCore.h>
#import "_RAuthenticationTracking.h"
#import "_RAuthenticationHelpers.h"

@implementation RUserPasswordAuthenticator

#pragma mark RAuthenticator
- (BOOL)isValid
{
    return _username.length && _password.length && super.isValid;
}


- (NSOperation *)loginWithCompletion:(rauthentication_account_completion_block_t)completion
{
    NSParameterAssert(completion);
    if (!completion) { return nil; }

    NSString *name     = self.username;
    NSString *password = self.password;
    NSString *method   = _RAuthenticationSelectorString(self, _cmd);

    _RAuthenticationLog(@"Trying to authenticate with username \"%@\" for service \"%@\"", name, self.serviceIdentifier);
    return [super loginWithCompletion:^(RAuthenticationAccount *account, NSError *error)
    {
        if (error)
        {
            completion(nil, error);
            return;
        }

        account.name     = name;
        account.password = password;

        /*
         * Only require a specific access group if a service identifier is provider
         */
        NSString *serviceIdentifier = account.serviceIdentifier;
        NSString *accessGroup = nil;

        /*
         * Enable SSO for accounts with a service identifier, if the authenticator class also
         * provides a default one.
         */
        if ([account.authenticatorClass respondsToSelector:@selector(defaultServiceIdentifier)])
        {
            NSString *defaultServiceIdentifier = [account.authenticatorClass defaultServiceIdentifier];
            if (defaultServiceIdentifier && [serviceIdentifier isEqualToString:defaultServiceIdentifier])
            {
                accessGroup = _RAuthenticationSingleSignOnAccessGroup;
            }
        }

        if (accessGroup)
        {
            if (!account.persistenceInformation)
            {
                account.persistenceInformation = RAuthenticationAccountPersistenceInformation.new;
            }
            account.persistenceInformation.accessGroup = accessGroup;
        }

        /*
         * Only try to persist the account if a service identifier was provided and the
         * user is fully registered
         */
        if (serviceIdentifier.length && account.userInformation && !account.userInformation.shouldAgreeToTermsAndConditions)
        {
            [account persistWithError:&error];
        }

        /*
         * Track a successful login.
         *
         * Note the builtin UI and the builtin workflow separately set the UI/UX login method.
         */
        if (!error)
        {
            [_RAuthenticationTracking broadcastLoginEventWithAccount:account];
            [_RAuthenticationTracking setLoginMethod:_RAuthenticationLoginMethodUnknown];
        }

        completion(error ? nil : account, error);
        _RAuthenticationLogSuccessOrFailure(method, error);
    }];
}

- (BOOL)isEqualToAuthenticator:(RUserPasswordAuthenticator *)other
{
    return
        [super isEqualToAuthenticator:other] &&
        _RAuthenticationObjectsEqual(_username, other.username) &&
        _RAuthenticationObjectsEqual(_password, other.password);
}

#pragma mark NSObject
- (NSUInteger)hash
{
    return [super hash] ^ _username.hash ^ _password.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"%@\n"
            @"\n\t username=%@"
            @"\n\t password=%@",
            super.description,
            _username, _password];
}

#pragma mark <NSCopying>
- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) __strong copy = [super copyWithZone:zone];
    copy.username = self.username;
    copy.password = self.password;
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
static NSString * const kUsernameKey = @"u";
static NSString * const kPasswordKey = @"p";

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_username forKey:kUsernameKey];
    [coder encodeObject:_password forKey:kPasswordKey];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder]))
    {
        _username = [coder decodeObjectOfClass:NSString.class forKey:kUsernameKey];
        _password = [coder decodeObjectOfClass:NSString.class forKey:kPasswordKey];
    }
    return self;
}

@end
