#import "_RETracking.h"

@implementation _RETracking
+ (void)_broadcastEvent:(NSString *)event object:(id)object
{
    NSString *name = [NSString stringWithFormat:@"com.rakuten.esd.sdk.events.%@", event];
    [NSNotificationCenter.defaultCenter postNotificationName:name object:object];
}

#pragma mark Public

+ (void)broadcastClientCredentialsTokenRequestFailureWithError:(NSError *)error
{
    NSMutableDictionary *object = [NSMutableDictionary dictionary];
    object[@"type"] = @"auth_request";
    
    if (error.localizedDescription.length)     object[@"rae_error"] = error.localizedDescription;
    if (error.localizedFailureReason.length)   object[@"rae_error_message"] = error.localizedFailureReason;
    
    [self _broadcastEvent:@"login.failure" object:object];
}

@end
