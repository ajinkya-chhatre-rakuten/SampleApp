/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>
#import <RAuthenticationUI/RAuthenticationViewController.h>
@protocol RVerificationDialog;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Allow any conforming class to be set as the delegate of a @ref RVerificationDialog "verification dialog".
 *
 *  @protocol RVerificationDialogDelegate RVerificationDialog.h <RAuthentication/RVerificationDialog.h>
 *  @ingroup RAuthenticationUI
 */
@protocol RVerificationDialogDelegate<NSObject>
@required
/**
 *  A @ref RVerificationDialog "verification dialog" wants to proceed.
 *
 *  Receivers should respond by allowing the process to continue if the password is valid.
 *
 *  @param verificationDialog  The @ref RVerificationDialog "verification dialog" sending this message.
 *  @param password            User password.
 */
- (void)verificationDialog:(UIViewController<RVerificationDialog> *)verificationDialog wantsToProceedWithPassword:(NSString *)password;

/**
 *  A @ref RVerificationDialog "verification dialog" wants to cancel.
 *
 *  Receivers should respond by cancelling the process.
 *
 *  @param verificationDialog  The @ref RVerificationDialog "verification dialog" sending this message.
 */
- (void)verificationDialogWantsToCancel:(UIViewController<RVerificationDialog> *)verificationDialog;
@end


/**
 *  Base protocol for all verification dialogs. A @ref RBuiltinVerificationDialog "concrete implementation" is also provided by this SDK.
 *
 *  @note Custom verification dialogs created by developers must conform to this protocol
 *        and descend from `UIViewController`.
 *
 *  @protocol RVerificationDialog RVerificationDialog.h <RAuthentication/RVerificationDialog.h>
 *  @ingroup RAuthenticationUI
 */
@protocol RVerificationDialog<NSObject>
@required

/**
 *  The delegate for this instance.
 *
 *  @note If using within a @ref RBuiltinVerificationWorkflow "verification workflow", the
 *        latter automatically sets itself as the dialog delegate.
 */
@property (nonatomic, weak) id<RVerificationDialogDelegate> verificationDialogDelegate;

@optional
/**
 *  The name of the user being asked for a password.
 */
@property (nonatomic, copy) NSString *userDisplayName;

/**
 *  Give the dialog the opportunity to handle a transient error. This is used by
 *  the @ref RBuiltinVerificationWorkflow "verification workflow" when some issue
 *  happens that can be recovered from without terminating the workflow, e.g.
 *  a temporary network issue or a wrong password.
 *
 *  @warning While this method is optional, unhandled transient errors eventually get promoted
 *           to fatal errors that terminate the @ref RBuiltinVerificationWorkflow "verification workflow"
 *           this dialog is attached to, so it is highly recommended that custom dialogs implement it.
 *
 *  @param error Error received while verifying the password. The error domain is always RVerificationWorkflowTransientErrorDomain.
 *  @return `YES` if the dialog will handle the error itself, `NO` otherwise.
 */
- (BOOL)handleError:(NSError *)error;

/**
 *  @name Responding to network activity
 *
 *  The following optional methods allow the dialog to react to network activity.
 *
 *  @{
 */

/**
 *  Called when network activity is about to start. The receiver should disallow
 *  subsequent user interactions that may result in new requests being issued. For
 *  instance, if the dialog has a password field and a submit button, it should disable
 *  both.
 *
 * @see RVerificationDialog::networkActivityDidEnd
 */
- (void)networkActivityWillStart;

/**
 *  Called after network activity has ended. The receiver should typically undo what
 *  it did in RVerificationDialog::networkActivityWillStart.
 */
- (void)networkActivityDidEnd;

/**
 *  Called multiple times during network activity, to report progress.
 *
 *  @note When using the dialog within the @ref RBuiltinVerificationWorkflow "verification workflow",
 *        network progress is already reported as a progress bar under the navigation
 *        bar.
 *
 *  @param fractionComplete A value in the `[0.0…1.0]` range, denoting current progress.
 */
- (void)handleNetworkActivityProgress:(double)fractionComplete;

/**
 *  @}
 */
@end

/**
 *  Builtin @ref RVerificationDialog "verification dialog".
 *
 *  The dialog is localized in both US English and Japanese. Other translations can be provided by the applications.
 *
 *  ### Preview
 *  @image html RBuiltinVerificationDialog.png "Preview" width=80%
 *
 *  #### Biometrics (Face ID and Touch ID)
 *  When used as part of a @ref RBuiltinVerificationWorkflow "verification workflow",
 *  a popup might appear if **Touch ID** or **Face ID** can be used, as depicted below:
 *
 *  @note
 *  [NSFaceIDUsageDescription](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW75) must be included in your app's Info.plist file. The description can be localized, for more info check [Localizing Property List Values](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/AboutInformationPropertyListFiles.html#//apple_ref/doc/uid/TP40009254-102276)
 *
 *  @image html RBuiltinVerificationDialog-TouchID.png "Touch ID" width=80%
 *
 *  @image html RBuiltinVerificationDialog-FaceID.png "Face ID" width=80%
 *
 *  ### Custom logo
 *  As with the other built-in dialogs provided within this module, you can set a
 *  custom logo by including an image named `RAuthenticationLogo` in your application bundle.
 *
 *  @class RBuiltinVerificationDialog RVerificationDialog.h <RAuthentication/RVerificationDialog.h>
 *  @ingroup RAuthenticationUI
 */
RAUTH_EXPORT @interface RBuiltinVerificationDialog : RAuthenticationViewController<RVerificationDialog>
/**
 *  The reason for asking for a password.
 */
@property (nonatomic, copy) IBInspectable NSString *reason;

/**
 *  Override point for the **Privacy Policy** button handler.
 *
 *  If unset, the SDK will open the localized URL with the key `authentication.builtinDialogs.privacyPolicyURL` and open the corresponding web page in the browser whenever that button is tapped.
 */
@property (nonatomic, copy) dispatch_block_t privacyPolicyButtonHandler;

/**
 *  Override point for the **Help** button handler.
 *
 *  If unset, the SDK will open the localized URL with the key `authentication.builtinDialogs.helpURL` and open the corresponding web page in the browser whenever that button is tapped.
 */
@property (nonatomic, copy) dispatch_block_t helpButtonHandler;

/**
 *  Override point for the **Forgot your password?** button handler.
 *
 *  If unset, the SDK hides that button.
 */
@property (nonatomic, copy) dispatch_block_t passwordResetButtonHandler;
@end

NS_ASSUME_NONNULL_END
