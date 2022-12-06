/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>
@class RAuthenticator, RUserPasswordAuthenticator;
@protocol RLoginDialog, RAccountSelectionDialog;

NS_ASSUME_NONNULL_BEGIN

/**
 * Defines a factory to be used by a @ref RBuiltinLoginWorkflow "login workflow" to create
 * an @ref RAuthenticator "authenticator" capable of logging a user in.
 *
 * @param settings               The @ref RAuthenticationSettings "authentication settings" to apply when creating new authenticators.
 * @param username               The username obtained by the @ref RBuiltinLoginWorkflow "login workflow".
 * @param password               The password obtained by the @ref RBuiltinLoginWorkflow "login workflow".
 *
 * @return An @ref RAuthenticator "authenticator".
 *
 * @see
 *  Builtins for creating standard factories:
 *  - @ref RBuiltinJapanIchibaUserAuthenticatorFactory creates and configures @ref RJapanIchibaUserAuthenticator "Japan Ichiba user authenticators".
 *  - @ref RBuiltinJapanIchibaUserAuthenticatorFactoryWithServiceID creates and configures @ref RJapanIchibaUserAuthenticator "Japan Ichiba user authenticators" for a specific RAE service identifier, e.g. `i101`.
 *
 * @ingroup UITypes
 */
typedef RAuthenticator * __nonnull (^rauthenticator_factory_block_t)(RAuthenticationSettings *settings, NSString *username, NSString *password);

/**
 * Creates an @ref rauthenticator_factory_block_t "authenticator factory" that can create and configure @ref RJapanIchibaUserAuthenticator "Japan Ichiba user authenticators".
 *
 * @note Factories created by this function set the authenticator's @ref RUserPasswordAuthenticator::username "-username",
 *       @ref RUserPasswordAuthenticator::password "-password" and @ref RAuthenticator::requestedScopes "-requestedScopes".
 *
 * @param requestedScopes  Requested scopes.
 *
 * @return A new @ref rauthenticator_factory_block_t "authenticator factory".
 * @ingroup UIFunctions
 */
RAUTH_EXPORT rauthenticator_factory_block_t RBuiltinJapanIchibaUserAuthenticatorFactory(NSSet<NSString *> *requestedScopes);

/**
 * Creates an @ref rauthenticator_factory_block_t "authenticator factory" that can create and configure @ref RJapanIchibaUserAuthenticator "Japan Ichiba user authenticators".
 *
 * @note Factories created by this function set the authenticator's @ref RUserPasswordAuthenticator::username "-username",
 *       @ref RUserPasswordAuthenticator::password "-password", @ref RJapanIchibaUserAuthenticator::raeServiceIdentifier "-raeServiceIdentifier"
 *       and @ref RAuthenticator::requestedScopes "-requestedScopes".
 *
 * @param requestedScopes      `[Required]` Requested scopes.
 * @param raeServiceIdentifier `[Optional]` RAE service id.
 *
 * @return A new @ref rauthenticator_factory_block_t "authenticator factory".
 * @ingroup UIFunctions
 */
RAUTH_EXPORT rauthenticator_factory_block_t RBuiltinJapanIchibaUserAuthenticatorFactoryWithServiceID(NSSet<NSString *> *requestedScopes, NSString *__nullable raeServiceIdentifier);

/**
 * Standard high-level login workflow.
 *
 * This workflow bundles standard logic to log a user in, using the developer-supplied
 * @ref RLoginDialog "login dialog" and @ref rauthenticator_factory_block_t "authenticator factory".
 *
 * @ref authentication-sso "Single Sign-On" is also supported transparently, provided
 * it has not been disabled. An optional @ref RAccountSelectionDialog "account selection dialog"
 * can be set to let users pick from a list of most-recently used accounts.
 *
 * Once a workflow has been set up, developers only get to call its @ref RBuiltinLoginWorkflow::start "start"
 * method to eventually receive an @ref RAuthenticationAccount "account".
 *
 * @note The login workflow is not retained globally, and must be retained by the caller. Otherwise
 *       all operations are cancelled and the completion block is never invoked.
 *
 * @attention This API is still in-progress and should change a bit in upcoming releases.
 *            Specific areas of improvements:
 *            - @ref RBuiltinLoginWorkflow::start and @ref RBuiltinLoginWorkflow::cancel look like
 *            `NSOperation` methods, and using an `NSOperation` subclass for the workflow would
 *            actually make more sense.
 *            - There should be a `RLoginWorkflow` abstract class, or some other way to provide
 *            concrete alternate workflows that extend or change the behavior of this one (though
 *            this is dangerous territory where application developers can break things in other
 *            apps if not getting Single Sign-On right).
 *
 * @class RBuiltinLoginWorkflow RLoginWorkflow.h <RAuthentication/RLoginWorkflow.h>
 * @ingroup RAuthenticationUI
 */
RAUTH_EXPORT @interface RBuiltinLoginWorkflow : NSObject

/**
 * The @ref RAuthenticationSettings "authentication settings" used with this instance.
 */
@property (nonatomic, readonly) RAuthenticationSettings *authenticationSettings;

/**
 * The @ref RLoginDialog "login dialog" used with this instance.
 */
@property (nonatomic, readonly) UIViewController<RLoginDialog> *loginDialog;

/**
 * The @ref RAccountSelectionDialog "account selection dialog" used with this instance.
 */
@property (nonatomic, readonly, nullable) UIViewController<RAccountSelectionDialog> *accountSelectionDialog;

/**
 * The @ref rauthenticator_factory_block_t "authenticator factory" used with this instance.
 */
@property (copy, nonatomic, readonly) rauthenticator_factory_block_t authenticatorFactory;

/**
 * Initialize the receiver.
 *
 * For quick prototyping, developers are encouraged to use a @ref RBuiltinLoginDialog "builtin login dialog"
 * and a @ref RBuiltinAccountSelectionDialog "builtin account selection dialog".
 *
 * @param authenticationSettings  The @ref RAuthenticationSettings "authentication settings" to use for this workflow.
 * @param loginDialog             The @ref RLoginDialog "login dialog" to use for this workflow.
 * @param accountSelectionDialog  The @ref RAccountSelectionDialog "account selection dialog" to use for this workflow.
 *                                If not set, then the most recently used account will be used, unless `loginDialog` also
 *                                conforms to @ref RAccountSelectionDialog and can thus be used for selecting accounts.
 * @param authenticatorFactory    The @ref rauthenticator_factory_block_t "authenticator factory" to use for this workflow.
 * @param presentationConfiguration Presentation configuration.
 * @param completion              Block to be invoked upon completion. If `nil`, no block will be invoked,
 *                                and the client will have to rely on the @ref RLoginWorkflowCompletedSuccessfullyNotification and
 *                                @ref RLoginWorkflowFailedWithErrorNotification notifications.
 * @return The receiver.
 */
- (instancetype)initWithAuthenticationSettings:(RAuthenticationSettings *)authenticationSettings
                                   loginDialog:(UIViewController<RLoginDialog> *)loginDialog
                        accountSelectionDialog:(nullable UIViewController<RAccountSelectionDialog> *)accountSelectionDialog
                          authenticatorFactory:(rauthenticator_factory_block_t)authenticatorFactory
                     presentationConfiguration:(nullable RBuiltinWorkflowPresentationConfiguration *)presentationConfiguration
                                    completion:(nullable rauthentication_account_completion_block_t)completion RAUTH_DESIGNATED_INITIALIZER;

/**
 * Convenience initializer.
 * (As above but lacking the presentationStyle & popoverAnchor parameters.)
 *
 * For quick prototyping, developers are encouraged to use a @ref RBuiltinLoginDialog "builtin login dialog"
 * and a @ref RBuiltinAccountSelectionDialog "builtin account selection dialog".
 *
 * @param authenticationSettings  The @ref RAuthenticationSettings "authentication settings" to use for this workflow.
 * @param loginDialog             The @ref RLoginDialog "login dialog" to use for this workflow.
 * @param accountSelectionDialog  The @ref RAccountSelectionDialog "account selection dialog" to use for this workflow.
 *                                If not set, then the most recently used account will be used, unless `loginDialog` also
 *                                conforms to @ref RAccountSelectionDialog and can thus be used for selecting accounts.
 * @param authenticatorFactory    The @ref rauthenticator_factory_block_t "authenticator factory" to use for this workflow.
 * @param presenterViewController The view controller from which to present the user interface. If nil, the top most
 *                                presented controller from the rootViewController of the first non-hidden window on
 *                                UIApplication.sharedApplication.windows will be used. Note the workflow will retain the
 *                                presenterViewController weakly to avoid strong reference cycles.
 * @param completion              Block to be invoked upon completion. If `nil`, no block will be invoked,
 *                                and the client will have to rely on the @ref RLoginWorkflowCompletedSuccessfullyNotification and
 *                                @ref RLoginWorkflowFailedWithErrorNotification notifications.
 * @return The receiver.
 */
- (instancetype)initWithAuthenticationSettings:(RAuthenticationSettings *)authenticationSettings
                                   loginDialog:(UIViewController<RLoginDialog> *)loginDialog
                        accountSelectionDialog:(nullable UIViewController<RAccountSelectionDialog> *)accountSelectionDialog
                          authenticatorFactory:(rauthenticator_factory_block_t)authenticatorFactory
                       presenterViewController:(nullable UIViewController *)presenterViewController
                                    completion:(nullable rauthentication_account_completion_block_t)completion;

/**
 * Convenience initializer.
 * (As above but lacking the presenterViewController parameter.)
 *
 * For quick prototyping, developers are encouraged to use a @ref RBuiltinLoginDialog "builtin login dialog"
 * and a @ref RBuiltinAccountSelectionDialog "builtin account selection dialog".
 *
 * @param authenticationSettings  The @ref RAuthenticationSettings "authentication settings" to use for this workflow.
 * @param loginDialog             The @ref RLoginDialog "login dialog" to use for this workflow.
 * @param accountSelectionDialog  The @ref RAccountSelectionDialog "account selection dialog" to use for this workflow.
 *                                If not set, then the most recently used account will be used, unless `loginDialog` also
 *                                conforms to @ref RAccountSelectionDialog and can thus be used for selecting accounts.
 * @param authenticatorFactory    The @ref rauthenticator_factory_block_t "authenticator factory" to use for this workflow.
 * @param completion              Block to be invoked upon completion. If `nil`, no block will be invoked,
 *                                and the client will have to rely on the @ref RLoginWorkflowCompletedSuccessfullyNotification and
 *                                @ref RLoginWorkflowFailedWithErrorNotification notifications.
 * @return The receiver.
 */
- (instancetype)initWithAuthenticationSettings:(RAuthenticationSettings *)authenticationSettings
                                   loginDialog:(UIViewController<RLoginDialog> *)loginDialog
                        accountSelectionDialog:(nullable UIViewController<RAccountSelectionDialog> *)accountSelectionDialog
                          authenticatorFactory:(rauthenticator_factory_block_t)authenticatorFactory
                                    completion:(nullable rauthentication_account_completion_block_t)completion;

/**
 * Start the user login flow.
 *
 * @note Login workflows cannot be reused.
 */
- (void)start;

/**
 * Cancel the user login flow.
 *
 * @note This cancels all pending operations, and the completion block will never be invoked.
 */
- (void)cancel;

/**
 * Returns the appearance of the navigation bar.
 */
+ (UINavigationBar *)navigationBarAppearance;

#ifndef DOXYGEN
- (instancetype)init NS_UNAVAILABLE;
#endif
@end

/**
 * Notification sent whenever a @ref RBuiltinLoginWorkflow "login workflow" was cancelled by the user.
 *
 * The `object` property of the notification points to the RBuiltinLoginWorkflow instance.
 *
 * @ingroup UINotifications
 */
RAUTH_EXPORT NSString *const RLoginWorkflowCancelledNotification;

/**
 * Notification sent whenever a @ref RBuiltinLoginWorkflow "login workflow" completed successfully.
 *
 * The `object` property of the notification points to the @ref RBuiltinLoginWorkflow the
 * error originated from. An @ref RAuthenticationAccount "account" can be found in the notification's
 * `userInfo` dictionary, under the key @ref RLoginWorkflowNotificationAccountKey.
 *
 * @ingroup UINotifications
 */
RAUTH_EXPORT NSString *const RLoginWorkflowCompletedSuccessfullyNotification;

/**
 * Notification sent whenever a @ref RBuiltinLoginWorkflow "login workflow" failed with an error.
 *
 * The `object` property of the notification points to the @ref RBuiltinLoginWorkflow the
 * error originated from. An `NSError` object can be found in the notification's
 * `userInfo` dictionary, under the key @ref RLoginWorkflowNotificationErrorKey.
 *
 * @ingroup UINotifications
 */
RAUTH_EXPORT NSString *const RLoginWorkflowFailedWithErrorNotification;

/**
 * Notification sent whenever a @ref RBuiltinLoginWorkflow "login workflow" requested that the
 * application show a password retrieval form.
 *
 * @note We currently do not provide any native UI to retrieve password, so you will have
 *       to provide your own and push it on the view controller stack.
 *
 * The `object` property of the notification points to the RBuiltinLoginWorkflow instance.
 *
 * @ingroup UINotifications
 */
RAUTH_EXPORT NSString *const RLoginWorkflowStartPasswordRetrievalNotification;

/**
 * Notification sent whenever a @ref RBuiltinLoginWorkflow "login workflow" requested that the
 * application show a new user registration form.
 *
 * @note We currently do not provide any native UI to register new users, so you will have
 *       to provide your own and push it on the view controller stack.
 *
 * The `object` property of the notification points to the RBuiltinLoginWorkflow instance.
 *
 * @ingroup UINotifications
 */
RAUTH_EXPORT NSString *const RLoginWorkflowStartNewAccountCreationNotification;

/**
 * Notification sent whenever a transient error occurred that the @ref RBuiltinLoginWorkflow "login workflow"
 * can recover from, so that apps can show a message to the user.
 *
 * For example, a network error during login will not be treated as a fatal error resulting in
 * the workflow being canceled and the completion block being called. Rather, the login dialog
 * will stay on screen and the user will have to either press the `Login` button again or cancel
 * the process interactively.
 *
 * The `object` property of the notification points to the @ref RBuiltinLoginWorkflow the
 * error originated from. An `NSError` object can be found in the notification's
 * `userInfo` dictionary, under the key @ref RLoginWorkflowNotificationErrorKey.
 *
 * @ingroup UINotifications
 */
RAUTH_EXPORT NSString *const RLoginWorkflowTransientErrorNotification;

/**
 * Notification sent whenever a @ref RBuiltinLoginWorkflow "login workflow"
 * starts accessing the network.
 *
 * The `object` property of the notification points to the RBuiltinLoginWorkflow instance.
 *
 * @ingroup UINotifications
 */
RAUTH_EXPORT NSString *const RLoginWorkflowNetworkActivityStartedNotification;

/**
 * Notification sent whenever a @ref RBuiltinLoginWorkflow "login workflow"
 * stopped its network activity.
 *
 * The `object` property of the notification points to the RBuiltinLoginWorkflow instance.
 *
 * @ingroup UINotifications
 */
RAUTH_EXPORT NSString *const RLoginWorkflowNetworkActivityStoppedNotification;

/**
 * Key for the @ref RAuthenticationAccount "account" found in an @ref RLoginWorkflowCompletedSuccessfullyNotification.
 *
 * @ingroup UIConstants
 */
RAUTH_EXPORT NSString *const RLoginWorkflowNotificationAccountKey;

/**
 * Key for the `NSError` instance found in an @ref RLoginWorkflowTransientErrorNotification.
 *
 * @ingroup UIConstants
 */
RAUTH_EXPORT NSString *const RLoginWorkflowNotificationErrorKey;

NS_ASSUME_NONNULL_END
