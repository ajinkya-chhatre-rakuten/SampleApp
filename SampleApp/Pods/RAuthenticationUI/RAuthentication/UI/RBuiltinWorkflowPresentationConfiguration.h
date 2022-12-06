/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Workflow presentation configuration.
 *
 * @class RBuiltinWorkflowPresentationConfiguration RBuiltinWorkflowPresentationConfiguration.h <RAuthentication/RBuiltinWorkflowPresentationConfiguration.h>
 * @ingroup RAuthenticationUI
 */
RAUTH_EXPORT @interface RBuiltinWorkflowPresentationConfiguration : NSObject <NSCopying>

/**
 * The view controller from which to present the user interface. If nil, the top most
 * presented controller from the rootViewController of the first non-hidden window on
 * UIApplication.sharedApplication.windows will be used. Note the workflow will retain the
 * presenterViewController weakly to avoid strong reference cycles.
 */
@property (weak, nullable) UIViewController *presenterViewController;

/**
 * Modal presentation style for this workflow. Only affect if presenterViewController is provided.
 */
@property (nonatomic) UIModalPresentationStyle presentationStyle;

/**
 * Anchor view. Can not be nil if set presentationStyle to UIModalPresentationStylePopover.
 */
@property (weak, nullable) id popoverAnchor;
@end

NS_ASSUME_NONNULL_END
