/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>

NS_ASSUME_NONNULL_BEGIN


/**
 * Defines a block for presenting a custom view controller in response to built-in UI.
 *
 * @param navigationController   The navigation controller to push new view controllers onto.
 *
 * @ingroup UITypes
 */
typedef void (^rauthentication_presenter_t)(UINavigationController *navigationController);

/**
 * Defines a block invoked in response to a logout workflow.
 *
 * @param cancelled   Whether the logout was cancelled or not.
 *
 * @ingroup UITypes
 */
typedef void (^rauthentication_logout_completion_t)(BOOL cancelled);

/**
 * Defines a logout preflight block for using with RBuiltinLogoutWorkflow.
 *
 * @param completion   Completion block the preflight block must invoke on completion.
 *
 * @ingroup UITypes
 */
typedef void (^rauthentication_logout_preflight_t)(rauthentication_logout_completion_t completion);

/**
 * Base protocol for logout workflows.
 *
 * Conforming classes should implement the complete UI/UX flow for logging users out.
 *
 * @protocol RLogoutWorkflow RLogoutWorkflow.h <RAuthentication/RLogoutWorkflow.h>
 * @ingroup RAuthenticationUI
 * @see RBuiltinLogoutWorkflow
 */
RAUTH_EXPORT @protocol RLogoutWorkflow<NSObject, NSCopying>
@required

/**
 * Log an account out.
 *
 * The receiver should respond by asking users to confirm they want to log out,
 * the proceed to using RAuthenticationAccount::logoutWithSettings:options:completion:
 * to perform the actual logout in the background.
 *
 * @param account     The account to log out.
 * @param completion  The block to be called whenever the operation completes or user-cancelled.
 */
- (void)logout:(RAuthenticationAccount *)account completion:(rauthentication_logout_completion_t)completion;
@end


/**
 * Standard high-level logout workflow for @ref authentication-sso "Single Sign-On" enabled applications.
 *
 * This workflow bundles standard logic to log a user out. Instances can be reused.
 *
 * @note While this class uses a standard RBuiltinLogoutDialog view controller, a few customization
 * options exist for that class using custom resources. Please refer to its documentation.
 *
 * @class RBuiltinLogoutWorkflow RLogoutWorkflow.h <RAuthentication/RLogoutWorkflow.h>
 * @ingroup RAuthenticationUI
 * @see RBuiltinLogoutDialog
 */
RAUTH_EXPORT @interface RBuiltinLogoutWorkflow : NSObject<RLogoutWorkflow>

/**
 * Custom presenter for the privacy policy page.
 *
 * If set, the block will be invoked whenever the "Privacy Policy" button is tapped. The internal
 * navigation controller currently presenting the @ref RBuiltinLogoutDialog "logout dialog" is
 * provided so that developers can push a custom view controller on top of it.
 *
 * If not set, the standard privacy policy page will be presented in a web view. The URL is localized,
 * and can be changed by applications by providing a different URL in their resources using the
 * `authentication.builtinDialogs.privacyPolicyURL` localized string key.
 */
@property (nonatomic, copy) rauthentication_presenter_t privacyPolicyPagePresenter;

/**
 * Custom presenter for the help page.
 *
 * If set, the block will be invoked whenever the "Help" button is tapped. The internal
 * navigation controller currently presenting the @ref RBuiltinLogoutDialog "logout dialog" is
 * provided so that developers can push a custom view controller on top of it.
 *
 * If not set, the standard privacy policy page will be presented in a web view. The URL is localized,
 * and can be changed by applications by providing a different URL in their resources using the
 * `authentication.builtinDialogs.helpURL` localized string key.
 */
@property (nonatomic, copy) rauthentication_presenter_t helpPagePresenter;

/**
 * Custom pre-flight block, executed on the main queue if the user chose to logout, before
 * any token gets actually revoked.
 *
 * This offers an opportunity for apps to e.g. unsubscribe from push notifications, or clean
 * user-associated data.
 */
@property (nonatomic, copy) rauthentication_logout_preflight_t preflight;

/**
 * The authentication settings used by this instance.
 */
@property (nonatomic, copy, readonly) RAuthenticationSettings *settings;

/**
 * Designated initializer.
 *
 * @param settings                The @ref RAuthenticationSettings "authentication settings" to use for logging users
 *                                out. This is typically the same settings used for logging them in in the first place.
 * @param presentationConfiguration Presentation configuration.
 * @return The receiver.
 */
- (instancetype)initWithSettings:(RAuthenticationSettings *)settings
       presentationConfiguration:(nullable RBuiltinWorkflowPresentationConfiguration *)presentationConfiguration RAUTH_DESIGNATED_INITIALIZER;

/**
 * Convenience initializer.
 * (As above but lacking the presentationStyle & popoverAnchor parameters.)
 *
 * @param settings                The @ref RAuthenticationSettings "authentication settings" to use for logging users
 *                                out. This is typically the same settings used for logging them in in the first place.
 * @param presenterViewController The view controller from which to present the user interface. If nil, the top most
 *                                presented controller from the rootViewController of the first non-hidden window on
 *                                UIApplication.sharedApplication.windows will be used. Note the workflow will retain the
 *                                presenterViewController weakly to avoid strong reference cycles.
 * @return The receiver.
 */
- (instancetype)initWithSettings:(RAuthenticationSettings *)settings
         presenterViewController:(nullable UIViewController *)presenterViewController;

/**
 * Convenience initializer.
 * (As above but lacking the presenterViewController parameter.)
 *
 * @param settings                The @ref RAuthenticationSettings "authentication settings" to use for logging users
 *                                out. This is typically the same settings used for logging them in in the first place.
 * @return The receiver.
 */
- (instancetype)initWithSettings:(RAuthenticationSettings *)settings;


#ifndef DOXYGEN
- (instancetype)init NS_UNAVAILABLE;
#endif
@end

NS_ASSUME_NONNULL_END
