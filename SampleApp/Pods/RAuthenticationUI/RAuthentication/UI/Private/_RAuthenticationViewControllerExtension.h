/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>
#import "RBuiltinWorkflowPresentationConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (_RAuthenticationViewControllerExtension)

/*
 * Present the receiver modally in the specified window.
 *
 * @param window     Window to present the receiver's view in. If `nil`, the application's main window is used.
 * @param completion Optional completion block to invoke on the main thread once the view controller is done animating into place.
 */
- (void)presentInWindow:(nullable UIWindow *)window completion:(nullable dispatch_block_t)completion;

/*
 * Present the receiver modally using specified configuration.
 *
 * @param configuration     Presentation configuration.
 * @param completion Optional completion block to invoke on the main thread once the view controller is done animating into place.
 */
- (void)presentWithConfiguration:(nullable RBuiltinWorkflowPresentationConfiguration *)configuration completion:(nullable dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
