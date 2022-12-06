#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

RWC_EXPORT @interface _RETracking : NSObject

+ (void)broadcastClientCredentialsTokenRequestFailureWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
