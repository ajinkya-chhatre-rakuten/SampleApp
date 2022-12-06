/*
 * © Rakuten, Inc.
 */
#import <Foundation/Foundation.h>
#import "_RAuthenticationHelpers.h"

/* RAUTH_EXPORT */ NSString *const _RAuthenticationSingleSignOnAccessGroup = @"jp.co.rakuten.sdtd.sso";

/* RAUTH_EXPORT */ void _RAuthenticationLog(NSString *format, ...)
{
    va_list args;
    va_start(args, format);
#if DEBUG
    NSLogv([NSString stringWithFormat:@"[RAuthentication] %@", format], args);
#endif
    va_end(args);
}

/* RAUTH_EXPORT */ NSString *_RAuthenticationApplicationName(void)
{
    NSString *appName = nil;
    NSBundle *appBundle = NSBundle.mainBundle;
    id LSHasLocalizedDisplayName = [appBundle objectForInfoDictionaryKey:@"LSHasLocalizedDisplayName"];
    if ([LSHasLocalizedDisplayName respondsToSelector:@selector(boolValue)])
    {
        if ([LSHasLocalizedDisplayName boolValue])
        {
            static NSString *const notFound = @"notFound";
            NSString *result = [appBundle localizedStringForKey:@"CFBundleDisplayName" value:notFound table:@"InfoPlist"];
            if (result && ![result isEqualToString:notFound])
            {
                appName = result;
            }
        }
    }

    id info = appBundle.infoDictionary;
    return (id)(appName ?: info[@"CFBundleDisplayName"] ?: info[@"CFBundleName"] ?: info[@"CFBundleExecutable"] ?: appBundle.bundleIdentifier);
}

/* RAUTH_EXPORT */ NSBlockOperation *_RAuthenticationDispatchGroupOperation(dispatch_group_t group, dispatch_block_t __nullable completion)
{
    /*
     * DO NOT USE dispatch_group_wait() inside the operaton. It will crash in
     * _dispatch_semaphore_dispose() when the operation is canceled.
     *
     * Rather, use dispatch_group_notify() outside of the operation, and make it
     * mark the latter as completed.
     */
    __block BOOL completed = NO;
    NSBlockOperation *operation = NSBlockOperation.new;
    typeof (operation) __weak weakOperation = operation;
    [operation addExecutionBlock:^{
        while (weakOperation && !weakOperation.isCancelled && !completed) usleep(10000);
    }];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (weakOperation && !weakOperation.isCancelled && completion) completion();

        completed = YES;
    });
    return operation;
}

static NSURLSession *internalURLSession()
{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration];
        session.sessionDescription = NSLocalizedString(@"com.rakuten.esd.rem.sdk.authentication", nil);
    });
    return session;
}

#define MakeInternalClient(Name) \
@implementation Name \
- (instancetype)initWithBaseURL:(NSURL *)baseURL { \
    if ((self = [super init])) { \
        _clientConfiguration = [RWCURLRequestConfiguration new]; \
        _clientConfiguration.baseURL = baseURL; \
        _session = internalURLSession(); \
    } \
    return self; \
} \
+ (instancetype)with:(RAuthenticationSettings *)settings { \
    return [[self alloc] initWithBaseURL:settings.baseURL]; \
} \
@end

MakeInternalClient(_RAuthenticationEngineClient)
MakeInternalClient(_RAuthenticationMemberInformationClient)
MakeInternalClient(_RAuthenticationIdInformationClient)

@implementation RETokenResult (RAuthentication)
- (void)_populateExistingToken:(RAuthenticationToken *)token
{
    token.accessToken    = (id)self.accessToken;
    token.refreshToken   = self.refreshToken;
    token.expirationDate = (id)self.estimatedAccessTokenExpirationDate;
    token.scopes         = (id)self.scopes;
    token.tokenType      = @"BEARER";
}

- (RAuthenticationToken *)_convertedToken
{
    RAuthenticationToken *token = RAuthenticationToken.new;
    [self _populateExistingToken:token];
    return token;
}

- (BOOL)_isFirstTime
{
    return NO;
}
@end

@implementation _RAuthenticationAccessGroupHelper
+ (BOOL)shouldUseAccessGroups
{
    // Modern era
    static BOOL result = YES;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if TARGET_IPHONE_SIMULATOR
    // Keychain access groups don't work in test targets that don't have a keychain-sharing enabled
    // host application, such as our REMSDK module tests.
    if (NSClassFromString(@"XCTest"))
    {
        result = NO;
        _RAuthenticationLog(@"Running unit tests on simulator build made with Xcode build version %@. SSO will not use keychain access groups.", @(__apple_build_version__));
    }
#endif

    });

    return result;
}

+ (nullable NSString *)fullyQualifiedDefaultKeychainAccessGroupWithError:(out NSError **)error;
{
    /*
     * On success:
     * - If no support for access groups: returns nil
     * - If simulator && no keychain sharing configured: returns "test"
     * - Else: returns a string with format XXXXXXXXXX.BUNDLE_ID
     */
    NSError *localError = nil;
    static NSString *value = nil;

    if (self.shouldUseAccessGroups)
    {
        @synchronized(self)
        {
            if (!value)
            {
                id query = @{(__bridge id)kSecClass:             (__bridge id)kSecClassGenericPassword,
                             (__bridge id)kSecAttrService:       @"jp.co.rakuten.sdtd.authentication",
                             (__bridge id)kSecAttrAccount:       [NSString stringWithFormat:@"probe.%@", NSBundle.mainBundle.bundleIdentifier],
                             (__bridge id)kSecReturnAttributes:  @YES};

                CFTypeRef result;
                OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
                if (status == errSecItemNotFound)
                {
                    query = [query mutableCopy];
                    query[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly;

                    status = SecItemAdd((__bridge CFDictionaryRef)query, &result);
                }

                if (status == errSecSuccess)
                {
                    NSDictionary *values = CFBridgingRelease(result);
                    value = [values[(__bridge id)kSecAttrAccessGroup] copy];

                    /*
                     * We've had false positives in the past, so we don't assert() but just print a warning
                     * message to the console.
                     */
                    NSRange dot = [value rangeOfString:@"."];
                    if (dot.length == 1 && dot.location < value.length)
                    {
                        if ([_RAuthenticationSingleSignOnAccessGroup isEqualToString:[value substringFromIndex: dot.location + 1]])
                        {
                            _RAuthenticationLog(@"🚨 The framework found \"%@\" to be your application's default access group. This might indicate a problem with your configuration!", _RAuthenticationSingleSignOnAccessGroup);
                        }
                    }
                }
                else
                {
                    localError = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
                }
            }
        }
    }

    if (error)
    {
        *error = localError;
    }

    return value.length ? value : nil;
}

+ (nullable NSString *)bundleSeedIdWithError:(out NSError **)error
{
    /*
     * On success:
     * - If no support for access groups: returns nil
     * - If simulator && no keychain sharing configured: returns nil
     * - Else: returns the bundle seed id
     */
    NSString *value = [self fullyQualifiedDefaultKeychainAccessGroupWithError:error];
    if (value)
    {
        NSRange dot = [value rangeOfString:@"."];
        /*
         * If the "fully" qualified default group is just the plain bundle identifier,
         * if means we don't have any seed.
         */
        NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier ?: @"test";
        if (dot.length && ![value isEqualToString:bundleIdentifier])
        {
            value = [value substringToIndex:dot.location];
        }
        else
        {
            value = nil;
        }
    }

    return value;
}

+ (nullable NSString *)fullyQualifiedAccessGroupWithCanonicalAccessGroup:(nullable NSString *)canonicalAccessGroup error:(out NSError **)error
{
    /*
     * On success:
     * - If no support for access groups: returns nil
     * - If simulator && no keychain sharing configured: returns the canonical access group.
     * - Else: returns <bundle seed id>.<canonical access group>
     */
    NSString *value = [self bundleSeedIdWithError:error];
    if (self.shouldUseAccessGroups && canonicalAccessGroup.length)
    {
        if (value.length)
        {
            return [NSString stringWithFormat:@"%@.%@", value, canonicalAccessGroup];
        }
        else
        {
            return canonicalAccessGroup;
        }
    }

    return nil;
}

+ (nullable NSString *)canonicalAccessGroupWithFullyQualifiedAccessGroup:(nullable NSString *)fullyQualifiedAccessGroup error:(out NSError **)error
{
    /*
     * On success:
     * - If no support for access groups: returns nil
     * - If simulator && no keychain sharing configured: returns the access group.
     * - Else: returns the access group, without the seed id
     */
    NSString *value = [self bundleSeedIdWithError:error];
    if (self.shouldUseAccessGroups && fullyQualifiedAccessGroup.length)
    {
        if (value.length)
        {
            return [fullyQualifiedAccessGroup substringFromIndex:value.length + 1];
        }
        else
        {
            return fullyQualifiedAccessGroup;
        }
    }

    return nil;
}

+ (nullable NSString *)fullyQualifiedPrivateAccessGroupWithError:(out NSError **)error
{
    /*
     * On success:
     * - If no support for access groups: returns nil
     * - If simulator && no keychain sharing configured: returns the bundle id.
     * - Else: returns <bundle seed id>.<bundle id>
     */
    NSString *accessGroup = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"com.rakuten.tech.mobile.auth.access-group-overwrite"];
    if (accessGroup == nil)
    {
        accessGroup = NSBundle.mainBundle.bundleIdentifier;
    }
    return [self fullyQualifiedAccessGroupWithCanonicalAccessGroup:accessGroup error:error];
}
@end
