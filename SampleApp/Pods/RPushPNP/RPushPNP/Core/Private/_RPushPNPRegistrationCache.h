#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

RWC_EXPORT @interface _RPushPNPRegistrationCache : NSObject
@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, copy, readonly) NSString *clientId;

+ (instancetype)cacheWithConfiguration:(RWCURLRequestConfiguration *)configuration clientId:(NSString *)clientId;
- (BOOL)setDeviceToken:(NSData *)deviceToken userId:(nullable NSString *)userId rpCookie:(nullable NSHTTPCookie *)cookie;
- (BOOL)hasDeviceToken:(NSData *)deviceToken userId:(nullable NSString *)userId rpCookie:(nullable NSHTTPCookie *)cookie;
- (BOOL)hasSafeToken:(nullable NSData *)deviceToken;
- (nullable NSString *)cachedSafeToken;
- (void)invalidate;
@end

NS_ASSUME_NONNULL_END
