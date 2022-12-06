/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>
@protocol RLoginDialog;
@class RAuthenticationViewController;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Allow any conforming class to be set as the delegate of a @ref RLoginDialog "login dialog".
 *
 *  @protocol RLoginDialogDelegate RLoginDialog.h <RAuthentication/RLoginDialog.h>
 *  @ingroup RAuthenticationUI
 */
@protocol RLoginDialogDelegate<NSObject>
@required

/**
 *  A @ref RLoginDialog "login dialog" wants to sign a user in.
 *
 *  Receivers should respond by attempting to log the user in by calling
 *  @ref RAuthenticator::loginWithCompletion: "-loginWithCompletion" on a suitable @ref RAuthenticator "authenticator".
 *
 *  @param loginDialog The @ref RLoginDialog "login dialog" sending this message.
 *  @param username    User identifier.
 *  @param password    User password.
 *
 *  @note It's usually a good idea to provide some kind of visual feedback while signing users in, such
 *        as a `UIActivityIndicatorView`. You should also prevent user
 *        interactions until @ref RAuthenticator::loginWithCompletion: completes, then dismiss the dialog.
 */
- (void)loginDialog:(UIViewController<RLoginDialog> *)loginDialog
wantsToSignInWithUsername:(NSString *)username
           password:(NSString *)password;

@optional

/**
 *  A @ref RLoginDialog "login dialog" wants to retrieve a forgotten password.
 *
 *  Receivers should respond by offering the user a way to get their password reset.
 *
 *  When a delegate does not implement this method, @ref RLoginDialog "login dialogs" should not offer the
 *  option to reset password.
 *
 *  @param loginDialog The @ref RLoginDialog "login dialog" sending this message.
 */
- (void)loginDialogWantsToRetrieveForgottenPassword:(UIViewController<RLoginDialog> *)loginDialog;

/**
 *  A @ref RLoginDialog "login dialog" wants to create a new user account.
 *
 *  Receivers should respond by offering the user a way to create a new user account on the right marketplace.
 *
 *  When a delegate does not implement this method, @ref RLoginDialog "login dialogs" should not offer the
 *  option to create a new account.
 *
 *  @param loginDialog The @ref RLoginDialog "login dialog" sending this message.
 */
- (void)loginDialogWantsToCreateNewAccount:(UIViewController<RLoginDialog> *)loginDialog;

/**
 *  A @ref RLoginDialog "login dialog" was closed at user's request.
 *
 *  Receivers should respond by having the user continue using the application
 *  without being logged in.
 *
 *  @param loginDialog The @ref RLoginDialog "login dialog" sending this message.
 */
- (void)loginDialogWantsToSkipSignIn:(UIViewController<RLoginDialog> *)loginDialog;
@end



/**
 *  Base protocol for all login dialogs. A @ref RBuiltinLoginDialog "concrete implementation" is also provided by this SDK.
 *
 *  @note Custom @ref RLoginDialog "login dialogs" created by developers must conform to this protocol
 *        and descend from `UIViewController`.
 *
 *  @protocol RLoginDialog RLoginDialog.h <RAuthentication/RLoginDialog.h>
 *  @ingroup RAuthenticationUI
 */
@protocol RLoginDialog<NSObject>
@required

/**
 *  The delegate for this instance.
 */
@property (weak, nonatomic) id<RLoginDialogDelegate> loginDialogDelegate;

@optional
/**
 *  Whether or not an error is handled internally by the login dialog.
 *
 *  If the receiver implements this method, and if it returns `YES`, then no Notification
 *  is sent when an error occurred that the @ref RBuiltinLoginWorkflow "login workflow"
 *  can recover from.
 *
 *  If not implemented, or if it returns `NO`, then the login workflow will send a
 *  RLoginWorkflowTransientErrorNotification notification instead.
 *
 *  @see RLoginWorkflowTransientErrorNotification
 */
- (BOOL)handleError:(NSError *)error;

/**
 *  Populate the dialog's username text field with a value.
 *
 *  If the receiver implements this method, then it will be used by the
 *  @ref RBuiltinLoginWorkflow "login workflow" when it fails to log a user in
 *  from its @ref RAccountSelectionDialog "account selection dialog" and falls
 *  back to showing this login dialog.
 */
- (void)populateWithUsername:(NSString *__nullable)username;
@end

/**
 *  Standard @ref RLoginDialog "login dialog".
 *
 *  The dialog is localized in both US English and Japanese. Other translations can be provided by the applications.
 *
 *  ### Preview
 *  @image html RBuiltinLoginDialog.png "Preview" width=80%
 *
 *  ### Custom logo
 *  As with the other built-in dialogs provided within this module, you can set a
 *  custom logo by including an image named `RAuthenticationLogo` in your application bundle.
 *
 *  @note The builtin login dialog works for any authentication scheme that requires
 *        a username and a password, and can thus be used with either the built-in
 *        @ref RJapanIchibaUserAuthenticator "Japan Ichiba user authenticator" or any concrete
 *        @ref RUserPasswordAuthenticator "user/password authenticator" ―it is up
 *        to the @ref RLoginDialogDelegate "delegate" to create the right
 *        @ref RUserPasswordAuthenticator "authenticator" from the data inputted in the form.
 *
 *  @class RBuiltinLoginDialog RLoginDialog.h <RAuthentication/RLoginDialog.h>
 *  @ingroup RAuthenticationUI
 */
RAUTH_EXPORT @interface RBuiltinLoginDialog : RAuthenticationViewController<RLoginDialog>
/**
 *  Whether to hide the "Skip" navigation button or not.
 *
 *  That button is normally shown whenever the @ref RLoginDialog::loginDialogDelegate "delegate"
 *  implements RLoginDialogDelegate::loginDialogWantsToSkipSignIn:.
 */
@property (nonatomic) BOOL shouldHideSkipButton;

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
@end

NS_ASSUME_NONNULL_END
