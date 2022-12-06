/*
 * © Rakuten, Inc.
 */

#import "_RAuthenticationViewControllerExtension.h"

@implementation UIViewController (_RAuthenticationViewControllerExtension)

- (void)presentInWindow:(nullable UIWindow *)window completion:(nullable dispatch_block_t)completion
{
    if (!window)
    {
        // Some apps create a 2nd window in their AppDelegate, so the first one is always hidden
        // See https://jira.rakuten-it.com/jira/browse/REMI-8?focusedCommentId=2566460
        for (UIWindow *w in UIApplication.sharedApplication.windows)
        {
            if (!w.isHidden)
            {
                window = w;
                break;
            }
        }
    }
    
    UIViewController *parentViewController = window.rootViewController;
    while (parentViewController.presentedViewController)
    {
        parentViewController = parentViewController.presentedViewController;
    }
    if (parentViewController)
    {
        [parentViewController presentViewController:self animated:YES completion:completion];
    }
}

- (void)presentWithConfiguration:(nullable RBuiltinWorkflowPresentationConfiguration *)configuration completion:(nullable dispatch_block_t)completion
{
    if (configuration && configuration.presenterViewController)
    {
        if ((configuration.presentationStyle == UIModalPresentationPopover && configuration.popoverAnchor == nil) || configuration.presentationStyle == UIModalPresentationNone)
        {
            configuration.presentationStyle = UIModalPresentationFullScreen;
        }
        self.modalPresentationStyle = configuration.presentationStyle;
        if (configuration.presentationStyle == UIModalPresentationPopover) {
            UIPopoverPresentationController *popoverController = self.popoverPresentationController;
            if ([configuration.popoverAnchor isKindOfClass:UIBarButtonItem.class])
            {
                popoverController.barButtonItem = (UIBarButtonItem*)configuration.popoverAnchor;
            }
            if ([configuration.popoverAnchor isKindOfClass:UIView.class])
            {
                popoverController.sourceView = (UIView*)configuration.popoverAnchor;
            }
            popoverController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            // Prevent popover be dissmissed by touch out side of it
            popoverController.passthroughViews = @[configuration.presenterViewController.view];
        }
        [configuration.presenterViewController presentViewController:self animated:YES completion:completion];
    }
    else
    {
        [self presentInWindow:nil completion:completion];
    }
}

@end
