#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RAnalyticsRpCookieFetcher;

@interface RPushPNPTargetedDevice : NSObject

/**
 *  Designated initializer.
 *
 *  @return An initialized instance of the RPushPNPTargetedDevice
 */
- (instancetype)initWithRPCookieFetcher:(RAnalyticsRpCookieFetcher *)rpCookieFetcher;

/**
 * @internal
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 *  Will always return false
 *
 *  @return A boolean
 */

- (BOOL)isTargeted DEPRECATED_MSG_ATTRIBUTE("Internal cache behavior has been modified and this method should no longer be used. It will be removed in a future version.  It will always return false.");


/**
 *  Fetches the RPCookie
 *
 */
- (void)fetchRPCookie:(void (^)(NSHTTPCookie *_Nullable))completionHandler;

@end

NS_ASSUME_NONNULL_END
