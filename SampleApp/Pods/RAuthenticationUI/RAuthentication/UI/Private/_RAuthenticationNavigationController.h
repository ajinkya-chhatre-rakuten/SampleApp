/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>

NS_ASSUME_NONNULL_BEGIN

RAUTH_EXPORT @interface _RAuthenticationNavigationBar : UINavigationBar
/*
 * If set, the navigation bar will show a progress view updated automatically to track it.
 */
@property (nonatomic, nullable) NSProgress *observedProgress;
@end

RAUTH_EXPORT @interface _RAuthenticationNavigationController : UINavigationController
@end

NS_ASSUME_NONNULL_END
