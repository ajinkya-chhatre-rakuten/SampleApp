#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/*
 * Small class for creating a data task that simply calls its completion block,
 * used to return something when calling -register and the cache is used.
 */
RWC_EXPORT @interface _RPushPNPMockedTask : NSURLSessionDataTask
- (instancetype)initWithCompletionBlock:(dispatch_block_t)completionBlock;
@end

NS_ASSUME_NONNULL_END
