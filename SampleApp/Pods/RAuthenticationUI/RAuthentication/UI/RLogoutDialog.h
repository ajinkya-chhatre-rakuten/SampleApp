/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>
#import <RAuthenticationCore/RAuthenticationAccount.h>
@protocol RLogoutDialog;
@class RAuthenticationViewController;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Built-in logout dialog for @ref authentication-sso "Single Sign-On" enabled applications.
 *
 *  The dialog is localized in both US English and Japanese. Other translations can be provided by the applications.
 *
 *  @note Applications not enabled for @ref authentication-sso "Single Sign-On" should implement their own logout
 *        UI/UX and use neither RBuiltinLogoutDialog nor RBuiltinLogoutWorkflow.
 *
 *  @attention This class is UI only, and no actual logout takes place. Please see our
 *             @ref RBuiltinLogoutWorkflow "standard Single Sign-On logout workflow" for an all-in-one
 *             solution to log users out, or RAuthenticationAccount::logoutWithSettings:options:completion:
 *             for the low-level call to log out from an account.
 *
 *  ### Preview
 *  @image html RBuiltinLogoutDialog.png "Preview" width=80%
 *
 *  ### Custom logo
 *  As with the other built-in dialogs provided within this module, you can set a
 *  custom logo by including an image named `RAuthenticationLogo` in your application bundle.
 *
 *  @class RBuiltinLogoutDialog RLogoutDialog.h <RAuthentication/RLogoutDialog.h>
 *  @ingroup RAuthenticationUI
 *  @see RBuiltinLogoutWorkflow
 */
RAUTH_EXPORT @interface RBuiltinLogoutDialog : RAuthenticationViewController
/**
 *  Block to be invoked once an option is picked.
 *
 *  Applications are supposed to call RAuthenticationAccount::logoutWithSettings:options:completion: in
 *  this handler, and dismiss the dialog once this completes.
 */
@property (nonatomic, copy) void (^logoutOptionHandler)(RAuthenticationLogoutOptions options);

/**
 *  Override point for the **Privacy Policy** button handler.
 *
 *  If left unset, the standard privacy policy page will be presented in a web view. The URL is localized,
 *  and can be changed by applications by providing a different URL in their resources using the
 *  `authentication.builtinDialogs.privacyPolicyURL` localized string key.
 */
@property (nonatomic, copy) dispatch_block_t privacyPolicyButtonHandler;

/**
 *  Override point for the **Help** button handler.
 *
 *  If not set, the standard privacy policy page will be presented in a web view. The URL is localized,
 *  and can be changed by applications by providing a different URL in their resources using the
 *  `authentication.builtinDialogs.helpURL` localized string key.
 */
@property (nonatomic, copy) dispatch_block_t helpButtonHandler;

/**
 *  Cancel button handler.
 *
 *  Applications can get notified that the user closed the dialog without picking any option
 *  by setting this property.
 */
@property (nonatomic, copy) dispatch_block_t cancelButtonHandler;
@end

NS_ASSUME_NONNULL_END
