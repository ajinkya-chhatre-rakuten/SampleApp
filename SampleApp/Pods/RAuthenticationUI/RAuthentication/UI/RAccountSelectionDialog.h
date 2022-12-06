/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>
@protocol RAccountSelectionDialog;
@class RAuthenticationAccount, RAuthenticationViewController;

NS_ASSUME_NONNULL_BEGIN

/**
 * Allow any conforming class to be set as the delegate of an @ref RAccountSelectionDialog "account selection dialog".
 *
 * @protocol RAccountSelectionDialogDelegate RAccountSelectionDialog.h <RAuthentication/RAccountSelectionDialog.h>
 * @ingroup RAuthenticationUI
 */
@protocol RAccountSelectionDialogDelegate<NSObject>
@required

/**
 * An @ref RAccountSelectionDialog "account selection dialog" wants to
 * sign in with the specified @ref RAuthenticationAccount "account".
 *
 * Receivers should respond by signing in with the specified @ref RAuthenticationAccount "account"
 * and dismissing the dialog.
 *
 * @param accountSelectionDialog The @ref RAccountSelectionDialog "account selection dialog" sending this message. Although not guaranteed, this is typically a `UIViewController` object.
 * @param account                The @ref RAuthenticationAccount "account", as selected by the user.
 */
- (void)accountSelectionDialog:(UIViewController<RAccountSelectionDialog> *)accountSelectionDialog
      wantsToSignInWithAccount:(RAuthenticationAccount *)account;

@optional
/**
 * An @ref RAccountSelectionDialog "account selection dialog" wants to
 * sign in with an account not found in the list it was provided with.
 *
 * Receivers should respond by dismissing the dialog and showing a @ref RLoginDialog "login dialog"
 * instead.
 *
 * @param accountSelectionDialog The @ref RAccountSelectionDialog "account selection dialog" sending this message. Although not guaranteed, this is typically a `UIViewController` object.
 */
- (void)accountSelectionDialogWantsToSignInWithAnotherAccount:(UIViewController<RAccountSelectionDialog> *)accountSelectionDialog;

/**
 * An @ref RAccountSelectionDialog "account selection dialog" wants to
 * create a new user account.
 *
 * Receivers should respond by showing an account registration screen.
 *
 * @param accountSelectionDialog The @ref RAccountSelectionDialog "account selection dialog" sending this message. Although not guaranteed, this is typically a `UIViewController` object.
 */
- (void)accountSelectionDialogWantsToCreateNewAccount:(UIViewController<RAccountSelectionDialog> *)accountSelectionDialog;

/**
 * An @ref RAccountSelectionDialog "account selection dialog" wants to
 * skip login.
 *
 * Receivers should respond by dismissing the dialog and having the user continue using
 * the application without requiring them to sign in.
 *
 * @param accountSelectionDialog The @ref RAccountSelectionDialog "account selection dialog" sending this message. Although not guaranteed, this is typically a `UIViewController` object.
 */
- (void)accountSelectionDialogWantsToSkipSignIn:(UIViewController<RAccountSelectionDialog> *)accountSelectionDialog;
@end

/**
 * Base protocol for all account selection dialogs.
 *
 * Application developers should present users with an account selection dialog
 * when they are not currently logged-in and possibly-usable accounts have been
 * loaded with RAuthenticationAccount::loadAccountsWithService:error:.
 *
 * @note Custom account selection dialogs created by application developers *must* conform to this protocol
 *       and descend from `UIViewController`.
 *
 * @protocol RAccountSelectionDialog RAccountSelectionDialog.h <RAuthentication/RAccountSelectionDialog.h>
 * @ingroup RAuthenticationUI
 */
@protocol RAccountSelectionDialog<NSObject>
@required

/**
 * The delegate for this instance.
 */
@property (weak, nonatomic) id<RAccountSelectionDialogDelegate> accountSelectionDialogDelegate;

/**
 * A list of @ref RAuthenticationAccount "accounts" to ask the users to choose from.
 *
 * @attention This *must* be set before the dialog is presented.
 */
@property (copy, nonatomic, nullable) NSArray<RAuthenticationAccount *> *accounts;

@optional
/**
 *  Whether or not an error is handled internally by the dialog.
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
@end

/**
 * Standard @ref RAccountSelectionDialog "account selection dialog".
 * Currently this only lets the user pick a single account (the most recently saved one).
 *
 * The dialog is localized in both US English and Japanese. Other translations can be provided by the applications.
 *
 * ### Preview
 * @image html RBuiltinAccountSelectionDialog.png "Preview" width=80%
 *
 * ### Custom logo
 * As with the other built-in dialogs provided within this module, you can set a
 * custom logo by including an image named `RAuthenticationLogo` in your application bundle.
 *
 * @class RBuiltinAccountSelectionDialog RAccountSelectionDialog.h <RAuthentication/RAccountSelectionDialog.h>
 * @ingroup RAuthenticationUI
 */
RAUTH_EXPORT @interface RBuiltinAccountSelectionDialog : RAuthenticationViewController<RAccountSelectionDialog>
/**
 *  Whether to always hide the "Skip" button or not.
 *
 *  That button is normally shown whenever the @ref RAccountSelectionDialog::accountSelectionDialogDelegate "delegate"
 *  implements @ref RAccountSelectionDialogDelegate::accountSelectionDialogWantsToSkipSignIn:.
 */
@property (nonatomic) BOOL shouldHideSkipButton;

/**
 *  Override point for the **Privacy Policy** button handler.
 *
 *  If unset, the SDK will open the defaut privacy policy web page in the browser.
 */
@property (nonatomic, copy) dispatch_block_t privacyPolicyButtonHandler;

/**
 *  Override point for the **Help** button handler.
 *
 *  If unset, the SDK will open the defaut help web page in the browser.
 */
@property (nonatomic, copy) dispatch_block_t helpButtonHandler;
@end

NS_ASSUME_NONNULL_END
