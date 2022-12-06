/*
 * © Rakuten, Inc.
 */
#import "_RAuthenticationTracking.h"
#import "_RAuthenticationHelpers.h"
#import <RAnalyticsBroadcast/RAnalyticsBroadcast.h>

/*
 * Small class to hold onto the current login method
 */
@interface _RAuthenticationLoginMethodTracking : NSObject
@property (nonatomic) _RAuthenticationLoginMethod method;
@end

@implementation _RAuthenticationLoginMethodTracking
+ (instancetype)instance
{
    static _RAuthenticationLoginMethodTracking *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = _RAuthenticationLoginMethodTracking.new;
    });
    return instance;
}

+ (_RAuthenticationLoginMethod)currentMethod
{
    _RAuthenticationLoginMethodTracking *instance = self.instance;
    return instance.method;
}
@end

@implementation _RAuthenticationTracking
+ (void)_broadcastEvent:(NSString *)event object:(nullable id)object
{
    NSString *name = [NSString stringWithFormat:@"com.rakuten.esd.sdk.events.%@", event];
    _RAuthenticationLog(@"👁 Emitting tracking event %@(object: %@).", name, object);
    [NSNotificationCenter.defaultCenter postNotificationName:name object:object];
}

+ (void)_broadcastEvent:(NSString *)event account:(RAuthenticationAccount *)account
{
    [self _broadcastEvent:event object:account.trackingIdentifier];
}

+ (void)setLoginMethod:(_RAuthenticationLoginMethod)loginMethod
{
    _RAuthenticationLoginMethodTracking *lmt = [_RAuthenticationLoginMethodTracking instance];
    lmt.method = loginMethod;
}

#pragma mark Public

+ (void)broadcastUnknownLoginEventWithAccount:(RAuthenticationAccount *)account
{
    [self _broadcastEvent:@"login.other" account:account];
}

+ (void)broadcastManualPasswordLoginEventWithAccount:(RAuthenticationAccount *)account
{
    [self _broadcastEvent:@"login.password" account:account];
}

+ (void)broadcastOneTapSSOLoginEventWithAccount:(RAuthenticationAccount *)account
{
    [self _broadcastEvent:@"login.one_tap" account:account];
}

+ (void)broadcastLoginEventWithAccount:(RAuthenticationAccount *)account
{
    switch (_RAuthenticationLoginMethodTracking.currentMethod) {
        case _RAuthenticationLoginMethodManualPassword:
            [self broadcastManualPasswordLoginEventWithAccount:account];
            break;

        case _RAuthenticationLoginMethodOneTapSSO:
            [self broadcastOneTapSSOLoginEventWithAccount:account];
            break;

        default:
            [self broadcastUnknownLoginEventWithAccount:account];
            break;
    }
}

+ (void)broadcastLoginFailureWithError:(NSError *)error
{
    NSString *loginMethod = nil;
    NSString *errorFailureReason = error.localizedFailureReason;
    switch (_RAuthenticationLoginMethodTracking.currentMethod) {
        case _RAuthenticationLoginMethodManualPassword: loginMethod = @"password_login";
            break;
        case _RAuthenticationLoginMethodOneTapSSO: loginMethod = @"sso_login";
            break;
        default: loginMethod = @"auth_request";
            break;
    }
    if (errorFailureReason.length && [errorFailureReason isKindOfClass:NSString.class])
    {
        [self _broadcastEvent:@"login.failure" object:@{@"type":loginMethod,@"rae_error":error.localizedDescription, @"rae_error_message" : errorFailureReason}];
    }
    else
    {
        [self _broadcastEvent:@"login.failure" object:@{@"type":loginMethod,@"rae_error":error.localizedDescription}];
    }
}

+ (void)broadcastLocalLogoutEventWithAccount:(RAuthenticationAccount *)account
{
    [self _broadcastEvent:@"logout.local" account:account];
}

+ (void)broadcastGlobalLogoutEventWithAccount:(RAuthenticationAccount *)account
{
    [self _broadcastEvent:@"logout.global" account:account];
}

+ (void)broadcastStandardVerificationEvent
{
    [self _broadcastEvent:@"_rem_visit" object:nil];
}

+ (void)broadcastStartVerificationEvent
{
    [RABEventBroadcaster sendEventName:@"_rem_user_verification_start" dataObject:nil];
}

+ (void)broadcastEndVerificationEventWithResult:(_RAuthenticationTrackingVerificationResult)result
{
    NSString *trackingResult = @"";
    switch (result)
    {
        case _RAuthenticationTrackingVerificationResultFingerprint:
            trackingResult = @"fingerprint";
            break;

        case _RAuthenticationTrackingVerificationResultFailed:
            trackingResult = @"failed";
            break;

        case _RAuthenticationTrackingVerificationResultPassword:
            trackingResult = @"password";
            break;

        case _RAuthenticationTrackingVerificationResultCanceled:
            trackingResult = @"canceled";
            break;

        default:
            break;
    }
    
    [RABEventBroadcaster sendEventName:@"_rem_user_verification_end" dataObject:@{@"result":trackingResult}];
}

+ (void)broadcastHelpTappedWithClass:(Class)aClass
{
    [self _broadcastEvent:@"ssodialog" object:[NSString stringWithFormat:@"%@.help", aClass]];
}

+ (void)broadcastPrivacyPolicyTappedWithClass:(Class)aClass
{
    [self _broadcastEvent:@"ssodialog" object:[NSString stringWithFormat:@"%@.privacypolicy", aClass]];
}

+ (void)broadcastForgotPasswordTappedWithClass:(Class)aClass
{
    [self _broadcastEvent:@"ssodialog" object:[NSString stringWithFormat:@"%@.forgotpassword", aClass]];
}

+ (void)broadcastCreateAccountTappedWithClass:(Class)aClass
{
    [self _broadcastEvent:@"ssodialog" object:[NSString stringWithFormat:@"%@.register", aClass]];
}

+ (void)broadcastSSOCredentialFound:(NSString*)source
{
    [self _broadcastEvent:@"ssocredentialfound" object:@{@"source":source}];
}

+ (void)broadcastLoginCredentialFound:(NSString*)source
{
    [self _broadcastEvent:@"logincredentialfound" object:@{@"source":source}];
}

@end
