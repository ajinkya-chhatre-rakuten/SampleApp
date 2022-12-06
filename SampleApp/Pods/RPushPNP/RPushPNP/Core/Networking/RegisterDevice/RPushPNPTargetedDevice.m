#import "RPushPNPTargetedDevice.h"
#import <RAnalytics/RAnalytics.h>

@interface RPushPNPTargetedDevice ()
@property (strong, nonatomic) RAnalyticsRpCookieFetcher *rpCookieFetcher;
@end

@implementation RPushPNPTargetedDevice

- (instancetype)initWithRPCookieFetcher:(RAnalyticsRpCookieFetcher *)rpCookieFetcher {
    self = [super init];
    if (self) {
        _rpCookieFetcher = rpCookieFetcher;
    }
    return self;
}

- (BOOL)isTargeted {
    return NO;
}

- (void)fetchRPCookie:(void (^)(NSHTTPCookie *_Nullable))completionHandler {
    [_rpCookieFetcher getRpCookieCompletionHandler:^(NSHTTPCookie *_Nullable cookie, NSError *__unused _Nullable error) {
        completionHandler(cookie);
    }];
}

@end
