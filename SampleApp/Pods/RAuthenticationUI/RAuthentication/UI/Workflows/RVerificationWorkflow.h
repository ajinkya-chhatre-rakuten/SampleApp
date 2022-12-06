/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>
@class RUserPasswordAuthenticator;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Completion block for the @ref RBuiltinVerificationWorkflow "verification workflow".
 *
 *  @param token New access token issued during the verification workflow. Note this token is not linked to any @ref RAuthenticationAccount "account" that may be managed by the SDK. In particular, it is never persisted automatically by the SDK.
 *
 *  @param error If the workflow ended without getting a token for some reason, this parameter holds an error with its domain set to RVerificationWorkflowErrorDomain.
 *
 *  @ingroup UITypes
 */
typedef void (^rauthentication_verification_completion_block_t)(RAuthenticationToken *__nullable token, NSError *__nullable error);


/**
 *  Error domain for errors passed to the completion block of
 *  RBuiltinVerificationWorkflow::verifyAccountWithUsername:reason:verificationDialog:authenticator:completion:
 *  when a verification workflow completes without getting a token.
 *
 *  @ingroup UIConstants
 */
RAUTH_EXPORT NSString *const RVerificationWorkflowErrorDomain;

/**
 *  Error codes for errors passed to the completion block of
 *  RBuiltinVerificationWorkflow::verifyAccountWithUsername:reason:verificationDialog:authenticator:completion:.
 *  when a verification workflow completes without getting a token.
 *
 *  @enum RVerificationWorkflowErrorCode
 *  @ingroup UIConstants
 */
typedef NS_ENUM(NSInteger, RVerificationWorkflowErrorCode)
{
    /**
     *  Error returned when a verification workflow is already in progress when attempting to start a new one.
     */
    RVerificationWorkflowErrorAlreadyInProgress = 1,
    
    /**
     *  Error returned when a verification workflow is cancelled, either by the system, user, or developer.
     */
    RVerificationWorkflowErrorCancelled,
    
    /**
     *  Error returned when an authenticator is invalid, perhaps because it does not generate a token operation.
     */
    RVerificationWorkflowErrorInvalidAuthenticator,
    
    /**
     *  Error returned when verification failed, and the error was not handled by RVerificationDialog::handleError:.
     */
    RVerificationWorkflowErrorFailed,
};


/**
 *  Error domain for errors passed to RVerificationDialog::handleError: when a
 *  @ref RBuiltinVerificationWorkflow "verification workflow" encounters an error.
 *
 *  @ingroup UIConstants
 */
RAUTH_EXPORT NSString *const RVerificationWorkflowTransientErrorDomain;

/**
 *  Error codes for errors passed to RVerificationDialog::handleError: when a
 *  @ref RBuiltinVerificationWorkflow "verification workflow" encounters an error that can be recovered
 *  from.
 *
 *  @enum RVerificationWorkflowTransientErrorCode
 *  @ingroup UIConstants
 */
typedef NS_ENUM(NSInteger, RVerificationWorkflowTransientErrorCode)
{
    /**
     *  A network problem prevented the @ref RBuiltinVerificationWorkflow "verification workflow" from
     *  verifying the user's credentials. The @ref RVerificationDialog "verification dialog" should
     *  invite the user to retry.
     *
     *  @note The original network error can be found under the `NSUnderlyingErrorKey` key, in the error's `userInfo` dictionary.
     *
     *  @warning If RVerificationDialog::handleError: is not implemented or returns `NO` for
     *  this error, the @ref RBuiltinVerificationWorkflow "verification workflow" is terminated and
     *  its completion block called with an `RVerificationWorkflowErrorFailed` error.
     */
    RVerificationWorkflowTransientErrorCouldNotConnectToServer = 1,
    
    /**
     *  The password acquired using biometrics is invalid (probably because the user has
     *  changed it since it was last persisted into the keychain). The
     *  @ref RVerificationDialog "verification dialog" should highlight its password field or
     *  give a hint to the user that they need to enter their password manually.
     *
     *  @note The original biometrics error can be found under the `NSUnderlyingErrorKey` key, in the error's `userInfo` dictionary.
     *
     *  @note If RVerificationDialog::handleError: is not implemented or returns `NO`,
     *  this error is silenced (i.e. it does not terminate the @ref RBuiltinVerificationWorkflow "verification workflow").
     */
    RVerificationWorkflowTransientErrorCouldNotAuthenticateUsingBiometrics,
    
    /**
     *  The password provided by the @ref RVerificationDialog "verification dialog" is invalid.
     *  The @ref RVerificationDialog "verification dialog" should invite the user to enter it again.
     *
     *  @note The original authentication error can be found under the `NSUnderlyingErrorKey` key, in the error's `userInfo` dictionary.
     *
     *  @warning If RVerificationDialog::handleError: is not implemented or returns `NO` for
     *  this error, the @ref RBuiltinVerificationWorkflow "verification workflow" is terminated and
     *  its completion block called with an `RVerificationWorkflowErrorFailed` error.
     */
    RVerificationWorkflowTransientErrorCouldNotAuthenticate,
    
    /**
     *  The client's IP is blacklisted.
     *  The @ref RVerificationDialog "verification dialog" shows an error message and asks user to try again later.
     *
     *  @note The original authentication error can be found under the `NSUnderlyingErrorKey` key, in the error's `userInfo` dictionary.
     *
     *  @note If RVerificationDialog::handleError: is not implemented or returns `NO`,
     *  this error is silenced (i.e. it does not terminate the @ref RBuiltinVerificationWorkflow "verification workflow").
     */
    RVerificationWorkflowTransientErrorNoPermissionToPublishToken,
    
    /**
     *  @deprecated Please use RVerificationWorkflowTransientErrorCouldNotAuthenticateUsingBiometrics instead.
     */
    RVerificationWorkflowTransientErrorCouldNotAuthenticateUsingTouchID DEPRECATED_ATTRIBUTE = RVerificationWorkflowTransientErrorCouldNotAuthenticateUsingBiometrics,
};

/**
 *  Workflow for verifying user credentials, usually prior to checkout.
 *
 *  @class RBuiltinVerificationWorkflow RVerificationWorkflow.h <RAuthentication/RVerificationWorkflow.h>
 *  @ingroup RAuthenticationUI
 */
RAUTH_EXPORT @interface RBuiltinVerificationWorkflow : NSObject
#pragma mark Configuring Biometrics Authentication
/**
 * @return `YES` if verification workflows try to use biometrics when available, `NO` otherwise. Defaults to `YES`.
 *
 * @see RBuiltinVerificationWorkflow::setShouldUseBiometrics:
 */
+ (BOOL)shouldUseBiometrics;

/**
 *  Sets whether to attempt to use biometrics when available or not.
 *
 *  @param useBiometrics Whether to attempt to use biometrics or not.
 *
 *  @see RBuiltinVerificationWorkflow::shouldUseBiometrics
 */
+ (void)setShouldUseBiometrics:(BOOL)useBiometrics;

/**
 * @deprecated Please use RBuiltinVerificationWorkflow::shouldUseBiometrics instead.
 */
+ (BOOL)shouldUseTouchID DEPRECATED_MSG_ATTRIBUTE("Please use shouldUseBiometrics instead.");

/**
 * @deprecated Please use RBuiltinVerificationWorkflow::setShouldUseBiometrics: instead.
 */
+ (void)setShouldUseTouchID:(BOOL)useTouchID DEPRECATED_MSG_ATTRIBUTE("Please use setShouldUseBiometrics instead.");

#pragma mark - Verifying a user
/**
 * Verify a user's credentials.
 *
 * Attempting to initiate a new verification workflow while another one is currently executing will result in the
 * completion block being invoked immediately with an RVerificationWorkflowErrorAlreadyInProgress error.
 *
 * @param username                Identifier of the user whose credentials should be verified.
 *                                The value will be assigned to RUserPasswordAuthenticator::username during the workflow.
 * @param reason                  Reason for asking the user to verify their credentials.
 * @param verificationDialog      A @ref RVerificationDialog "verification dialog". If not set, the
 *                                @ref RBuiltinVerificationDialog "built-in verification dialog" is used.
 * @param authenticator           The @ref RUserPasswordAuthenticator "authenticator" to verify the account
 *                                with and generate the @ref RAuthenticationToken "access token" passed to the
 *                                completion block. This allows applications to request a specific combination of
 *                                scopes for that access token, such as a **checkout** scope. Note that the
 *                                authenticator is copied right away, so any change made to the original instance
 *                                after this call will have no effect on the verification workflow.
 * @param presentationConfiguration Presentation configuration.
 * @param completion              Block to be invoked on the main thread upon completion, cancellation or error.
 */
+ (void)verifyAccountWithUsername:(NSString *)username
                           reason:(NSString *)reason
               verificationDialog:(UIViewController<RVerificationDialog> *__nullable)verificationDialog
                    authenticator:(RUserPasswordAuthenticator *)authenticator
        presentationConfiguration:(nullable RBuiltinWorkflowPresentationConfiguration *)presentationConfiguration
                       completion:(rauthentication_verification_completion_block_t)completion;

/**
 * Convenience method. Verify a user's credentials.
 * (As above but lacking the presenterViewController & presentationStyle & popoverAnchor parameters.)
 *
 * Attempting to initiate a new verification workflow while another one is currently executing will result in the
 * completion block being invoked immediately with an RVerificationWorkflowErrorAlreadyInProgress error.
 *
 * @param username                Identifier of the user whose credentials should be verified.
 *                                The value will be assigned to RUserPasswordAuthenticator::username during the workflow.
 * @param reason                  Reason for asking the user to verify their credentials.
 * @param verificationDialog      A @ref RVerificationDialog "verification dialog". If not set, the
 *                                @ref RBuiltinVerificationDialog "built-in verification dialog" is used.
 * @param authenticator           The @ref RUserPasswordAuthenticator "authenticator" to verify the account
 *                                with and generate the @ref RAuthenticationToken "access token" passed to the
 *                                completion block. This allows applications to request a specific combination of
 *                                scopes for that access token, such as a **checkout** scope. Note that the
 *                                authenticator is copied right away, so any change made to the original instance
 *                                after this call will have no effect on the verification workflow.
 * @param completion              Block to be invoked on the main thread upon completion, cancellation or error.
 */
+ (void)verifyAccountWithUsername:(NSString *)username
                           reason:(NSString *)reason
               verificationDialog:(UIViewController<RVerificationDialog> *__nullable)verificationDialog
                    authenticator:(RUserPasswordAuthenticator *)authenticator
                       completion:(rauthentication_verification_completion_block_t)completion;

/**
 *  Cancels the current verification workflow, if any.
 *
 *  If a verification is underway, it is terminated and its completion block is called with a
 *  RVerificationWorkflowErrorCancelled error.
 *
 *  If there is no active verification workflow, this method has no effect.
 */
+ (void)cancel;
@end

NS_ASSUME_NONNULL_END
