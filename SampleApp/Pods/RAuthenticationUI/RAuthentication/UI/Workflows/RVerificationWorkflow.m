/*
 * © Rakuten, Inc.
 */
#import <LocalAuthentication/LocalAuthentication.h>
#import <RAuthenticationUI/RAuthenticationUI.h>
#import "_RAuthenticationNavigationController.h"
#import "_RAuthenticationTracking.h"
#import "_RAuthenticationUIHelpers.h"
#import "_RAuthenticationViewControllerExtension.h"

/* RAUTH_EXPORT */ NSString *const RVerificationWorkflowErrorDomain          = @"RVerificationWorkflowErrorDomain";
/* RAUTH_EXPORT */ NSString *const RVerificationWorkflowTransientErrorDomain = @"RVerificationWorkflowTransientErrorDomain";

@interface RBuiltinVerificationWorkflow () <RVerificationDialogDelegate>
@property (nonatomic, getter=isInProgress) BOOL                                   inProgress;
@property (nonatomic)                      LAContext                             *localAuthenticationContext;
@property (nonatomic)                      NSOperation                           *tokenOperation;
@property (nonatomic)                      RUserPasswordAuthenticator            *authenticator;
@property (nonatomic)                      UIViewController<RVerificationDialog> *verificationDialog;
@property (nonatomic, copy) rauthentication_verification_completion_block_t       completion;
@property (copy, nonatomic, nullable) RBuiltinWorkflowPresentationConfiguration  *presentationConfiguration;
@end

@implementation RBuiltinVerificationWorkflow
#pragma mark Singleton management
- (instancetype)init
{
    RAUTH_INVALID_METHOD;
}

- (instancetype)initSharedVerificationWorkflow
{
    return ((self = [super init]));
}

+ (instancetype)sharedVerificationWorkflow
{
    static RBuiltinVerificationWorkflow *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^
                  {
                      instance = [self.alloc initSharedVerificationWorkflow];
                  });
    
    return instance;
}

#pragma mark Public methods
static BOOL _shouldUseBiometrics = YES;

+ (BOOL)shouldUseBiometrics
{
    return _shouldUseBiometrics;
}

+ (void)setShouldUseBiometrics:(BOOL)useBiometrics
{
    _shouldUseBiometrics = useBiometrics;
}

+ (BOOL)shouldUseTouchID
{
    return [RBuiltinVerificationWorkflow shouldUseBiometrics];
}

+ (void)setShouldUseTouchID:(BOOL)useTouchID
{
    [RBuiltinVerificationWorkflow setShouldUseBiometrics:useTouchID];
}

+ (void)verifyAccountWithUsername:(NSString *)username
                           reason:(NSString *)reason
               verificationDialog:(UIViewController<RVerificationDialog> *__nullable)verificationDialog
                    authenticator:(RUserPasswordAuthenticator *)authenticator
        presentationConfiguration:(nullable RBuiltinWorkflowPresentationConfiguration *)presentationConfiguration
                       completion:(rauthentication_verification_completion_block_t)completion
{
    NSParameterAssert(username.length);
    NSParameterAssert(reason.length);
    NSParameterAssert(authenticator);
    NSParameterAssert(completion);
    
    [_RAuthenticationTracking broadcastStandardVerificationEvent];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [RBuiltinVerificationWorkflow.sharedVerificationWorkflow _beginVerifyingAccountWithUsername:username
                                                                                             reason:reason
                                                                                 verificationDialog:verificationDialog
                                                                                      authenticator:authenticator
                                                                          presentationConfiguration:presentationConfiguration
                                                                                         completion:completion];
    });
}

+ (void)verifyAccountWithUsername:(NSString *)username
                           reason:(NSString *)reason
               verificationDialog:(UIViewController<RVerificationDialog> *__nullable)verificationDialog
                    authenticator:(RUserPasswordAuthenticator *)authenticator
                       completion:(rauthentication_verification_completion_block_t)completion
{
    [RBuiltinVerificationWorkflow verifyAccountWithUsername:username
                                                     reason:reason
                                         verificationDialog:verificationDialog
                                              authenticator:authenticator
                                  presentationConfiguration:nil
                                                 completion:completion];
}

+ (void)cancel
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [RBuiltinVerificationWorkflow.sharedVerificationWorkflow _cancel];
    });
}

#pragma mark Private methods
- (void)setTokenOperation:(NSOperation *)tokenOperation
{
    NSOperation *old = _tokenOperation;
    _tokenOperation = tokenOperation;
    
    /*
     * If we ever release a network operation that's not complete yet, just cancel it.
     *
     * This can happen in two circumstances:
     * - The workflow is being programmatically cancelled, and .tokenOperation set to
     *   nil in -_completeVerificationWithToken. In this case the completion block will
     *   eventually be called.
     * - A custom dialog doesn't prevent user interation during network requests, and
     *   the user triggers a new request. In this case we silently kill the old one.
     *   The completion block will be invoked when the new one completes.
     */
    if (!old.isCancelled && !old.isFinished && old != tokenOperation)
    {
        [old cancel];
    }
    
    id<RVerificationDialog> dialog = self.verificationDialog;
    _RAuthenticationNavigationBar *navigationBar = (id)self.verificationDialog.navigationController.navigationBar;
    if (!old && tokenOperation)
    {
        if ([dialog respondsToSelector:@selector(networkActivityWillStart)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [dialog networkActivityWillStart];
            });
        }
        
        /*
         * REM-654: while we don't have access to the actual network progress data at this point,
         * the following gives a small indication to the user that something is happening…
         */
        NSProgress *progress = NSProgress.new;
        progress.totalUnitCount        = 100;
        navigationBar.observedProgress = progress;
        
        [self _reportNetworkActivityProgress:.3];
    }
    else if (old && !tokenOperation)
    {
        [self _reportNetworkActivityProgress:1.0];
        
        if ([dialog respondsToSelector:@selector(networkActivityDidEnd)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [dialog networkActivityDidEnd];
            });
        }
        
        navigationBar.observedProgress = nil;
    }
}

- (void)_reportNetworkActivityProgress:(double)fractionComplete
{
    UIViewController<RVerificationDialog> *dialog = self.verificationDialog;
    if ([dialog respondsToSelector:@selector(handleNetworkActivityProgress:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [dialog handleNetworkActivityProgress:fractionComplete];
        });
    }
    
    NSProgress *progress = ((_RAuthenticationNavigationBar *)dialog.navigationController.navigationBar).observedProgress;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Weird: this gets deadlocked in a semaphone if executed on the main thread. Apple bug?
        progress.completedUnitCount = (int64_t)round(fractionComplete * 100.0);
    });
}

- (void)_reportTransientError:(NSError *)error
{
    NSParameterAssert([error.domain isEqualToString:RVerificationWorkflowTransientErrorDomain]);
    
    // If the error is CouldNotAuthenticate and self.localAuthenticationContext is not nil,
    // it means the password obtained in the keychain has been changed and is not valid anymore.
    //
    // We turn that into a CouldNotAuthenticateUsingBiometrics error, so that the dialog can show
    // a more relevant message.
    if (error.code == RVerificationWorkflowTransientErrorCouldNotAuthenticate && self.localAuthenticationContext)
    {
        id errorInfo = @{NSLocalizedDescriptionKey:
                             _RAuthenticationLocalizedString(@"builtinVerificationWorkflow.error.biometricCheckFailed"),
                         NSLocalizedFailureReasonErrorKey:
                             _RAuthenticationLocalizedString(@"builtinVerificationWorkflow.error.biometricCheckFailed.invalidPassword"),
                         NSUnderlyingErrorKey:
                             error};
        
        error = [NSError errorWithDomain:RVerificationWorkflowTransientErrorDomain
                                    code:RVerificationWorkflowTransientErrorCouldNotAuthenticateUsingBiometrics
                                userInfo:errorInfo];
    }
    
    // Release the LAContext instance
    [self _releaseLocalAuthenticationContext];
    
    if ([self.verificationDialog respondsToSelector:@selector(handleError:)])
    {
        if ([self.verificationDialog handleError:error])
        {
            // Error was handled by the dialog
            [_RAuthenticationTracking broadcastEndVerificationEventWithResult:_RAuthenticationTrackingVerificationResultFailed];
            return;
        }
    }
    
    // If the error was not handled by the dialog itself,
    // it will terminate the verification workflow, unless it is a CouldNotAuthenticateUsingBiometrics
    // error (which is harmless).
    if (error.code != RVerificationWorkflowTransientErrorCouldNotAuthenticateUsingBiometrics)
    {
        id errorInfo = @{NSLocalizedDescriptionKey:
                             _RAuthenticationLocalizedString(@"builtinVerificationWorkflow.error.failed"),
                         NSLocalizedFailureReasonErrorKey:
                             _RAuthenticationLocalizedString(@"builtinVerificationWorkflow.error.failed.reason"),
                         NSUnderlyingErrorKey:
                             error};
        
        [self _completeVerificationWithToken:nil
                                       error:[NSError errorWithDomain:RVerificationWorkflowErrorDomain
                                                                 code:RVerificationWorkflowErrorFailed
                                                             userInfo:errorInfo]];
    }
}

- (void)_beginVerifyingAccountWithUsername:(NSString *)username
                                    reason:(NSString *)reason
                        verificationDialog:(UIViewController<RVerificationDialog> *__nullable)verificationDialog
                             authenticator:(RUserPasswordAuthenticator *)authenticatorPrototype
                 presentationConfiguration:(nullable RBuiltinWorkflowPresentationConfiguration *)presentationConfiguration
                                completion:(rauthentication_verification_completion_block_t)completion
{
    @synchronized(self)
    {
        if (self.isInProgress)
        {
            id errorInfo = @{NSLocalizedDescriptionKey:
                                 _RAuthenticationLocalizedString(@"builtinVerificationWorkflow.error.alreadyRunning"),
                             NSLocalizedFailureReasonErrorKey:
                                 _RAuthenticationLocalizedString(@"builtinVerificationWorkflow.error.alreadyRunning.reason")};
            
            completion(nil, [NSError errorWithDomain:RVerificationWorkflowErrorDomain
                                                code:RVerificationWorkflowErrorAlreadyInProgress
                                            userInfo:errorInfo]);
            return;
        }
        self.inProgress = YES;
    }
    
    // Build the real authenticator from the passed prototype, setting its username and disabling persistence.
    RUserPasswordAuthenticator *authenticator = authenticatorPrototype.copy;
    authenticator.username          = username;
    authenticator.serviceIdentifier = nil;
    
    // If no custom verification dialog is passed, use the built-in one.
    if (!verificationDialog)
    {
        RBuiltinVerificationDialog *dialog = RBuiltinVerificationDialog.new;
        dialog.reason = reason;
        verificationDialog = dialog;
    }
    verificationDialog.verificationDialogDelegate = self;
    
    // Try to load an account that matches the username for the service passed in the authenticator prototype.
    RAuthenticationAccount *account = nil;
    NSString *serviceIdentifier = authenticatorPrototype.serviceIdentifier;
    if (serviceIdentifier.length)
    {
        account = [RAuthenticationAccount loadAccountWithName:username
                                                      service:serviceIdentifier
                                                        error:0];
    }
    
    // Try to obtain the user's display name(fullname for Japanese, first name for English) from the account, or use `username` as a fallback
    NSString *displayName = account.userInformation.displayname ?: username;
    if ([verificationDialog respondsToSelector:@selector(setUserDisplayName:)])
    {
        verificationDialog.userDisplayName = displayName;
    }
    
    // Finish setting up everything…
    self.completion              = completion;
    self.authenticator           = authenticator;
    self.verificationDialog      = verificationDialog;
    self.presentationConfiguration = presentationConfiguration;
    
    // Present the verification dialog
    _RAuthenticationNavigationController *navigationController = [_RAuthenticationNavigationController.alloc initWithRootViewController:(id)verificationDialog];
    
    typeof(self) __weak weakSelf = self;
    void (^presentationCompletion)(void) =
    ^{
        typeof(weakSelf) __strong strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [_RAuthenticationTracking broadcastStartVerificationEvent];
        
        /*
         * Should we attempt Touch/Face ID?
         *
         * - Not if `shouldUseBiometrics` is `NO`.
         * - Not if we don't have any password to authenticate with.
         */
        if (!RBuiltinVerificationWorkflow.shouldUseBiometrics ||
            !account.password.length)
        {
            return;
        }
        
        // …also, not if the device doesn't support it!
        LAContext *context = LAContext.new;
        if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:0])
        {
            return;
        }
        
        // Check if usage description is provided for Face ID
        if (@available(iOS 11.0, *)) {
            if (context.biometryType == LABiometryTypeFaceID && ![[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSFaceIDUsageDescription"])
            {
                return;
            }
        }
        
        @synchronized(strongSelf)
        {
            // We may have been already cancelled, programmatically.
            if (!strongSelf.isInProgress)
            {
                return;
            }
            
            // We need to keep track of the context to invalidate it when we cancel the workflow programmatically
            // (also to not report a wrong password as such if the password was grabbed in the background,
            // but invite the user to enter it instead).
            strongSelf.localAuthenticationContext = context;
        }
        
        NSString *biometricsMessage = [[_RAuthenticationLocalizedString(@"builtinVerificationWorkflow.touchID.message")
                                     stringByReplacingOccurrencesOfString:@"{FULLNAME}" withString:displayName]
                                    stringByReplacingOccurrencesOfString:@"{REASON}" withString:reason];
        
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:biometricsMessage
                          reply:^(BOOL success, NSError *error)
         {
             // We're on a background queue! Run back where it's safe:
             dispatch_async(dispatch_get_main_queue(), ^{
                 typeof(weakSelf) __strong workflow = weakSelf;
                 if (!workflow) return;
                 
                 if (success)
                 {
                     [workflow _verifyPassword:account.password trackingResultIfSuccess:_RAuthenticationTrackingVerificationResultFingerprint];
                 }
                 else if ([error.domain isEqualToString:LAErrorDomain])
                 {
                     switch (error.code)
                     {
                         case LAErrorSystemCancel:
                         case LAErrorUserCancel:
                             [workflow _cancel];
                             break;
                         case LAErrorUserFallback:
                         {
                             id errorInfo = @{NSLocalizedDescriptionKey:
                                                  _RAuthenticationLocalizedString(@"builtinVerificationWorkflow.error.biometricCheckFailed"),
                                              NSLocalizedFailureReasonErrorKey:
                                                  _RAuthenticationLocalizedString(@"builtinVerificationWorkflow.error.biometricCheckFailed.noPasswordAvailable"),
                                              NSUnderlyingErrorKey:
                                                  error};
                             [workflow _reportTransientError:[NSError errorWithDomain:RVerificationWorkflowTransientErrorDomain
                                                                                 code:RVerificationWorkflowTransientErrorCouldNotAuthenticateUsingBiometrics
                                                                             userInfo:errorInfo]];
                             
                             break;
                         }
                     }
                 }
             });
         }];
    };
    [navigationController presentWithConfiguration:_presentationConfiguration completion:presentationCompletion];
}

- (void)_verifyPassword:(NSString *)password trackingResultIfSuccess:(_RAuthenticationTrackingVerificationResult)trackingResultIfSuccess
{
    /*
     * Issue the token request.
     *
     * Note we keep a strong reference to the operation so that we can cancel it later, and
     * we also store the password in the authenticator instance only for the duration of the
     * request.
     */
    typeof(self) __weak weakSelf = self;
    self.authenticator.password = password;
    self.tokenOperation =
    [self.authenticator requestTokenWithCompletion:^(RAuthenticationToken *token, NSError * error)
     {
         typeof(weakSelf) __strong strongSelf = weakSelf;
         if (!strongSelf) return;
         
         strongSelf.tokenOperation = nil;
         strongSelf.authenticator.password = nil;
         
         // Success: we've got a token
         if (token)
         {
             [strongSelf _completeVerificationWithToken:token error:nil];
             if (trackingResultIfSuccess == _RAuthenticationTrackingVerificationResultFingerprint || trackingResultIfSuccess == _RAuthenticationTrackingVerificationResultPassword)
             {
                 [_RAuthenticationTracking broadcastEndVerificationEventWithResult:trackingResultIfSuccess];
             }
         }
         
         // Failure: report the error
         else
         {
             NSInteger code;
             id        info;
             
             NSString *domain      = error.domain,
             *description = error.localizedDescription,
             *reason      = error.userInfo[NSLocalizedFailureReasonErrorKey];
             
             if ([domain isEqualToString:NSURLErrorDomain])
             {
                 code = RVerificationWorkflowTransientErrorCouldNotConnectToServer;
                 info = @{NSLocalizedDescriptionKey:
                              _RAuthenticationLocalizedString(@"builtinVerificationWorkflow.error.networkError"),
                          NSLocalizedFailureReasonErrorKey:
                              _RAuthenticationLocalizedString(@"builtinVerificationWorkflow.error.networkError.reason"),
                          NSUnderlyingErrorKey:
                              error};
             }
             else if ([domain isEqualToString:RWCAppEngineResponseParserErrorDomain] && [description isEqualToString:@"invalid_client"]  && [reason isEqualToString:@"client has no permission to publish token"])
             {
                 code = RVerificationWorkflowTransientErrorNoPermissionToPublishToken;
                 info = @{NSLocalizedDescriptionKey:description,
                          NSLocalizedFailureReasonErrorKey:reason,
                          NSUnderlyingErrorKey:error};
             }
             else
             {
                 code = RVerificationWorkflowTransientErrorCouldNotAuthenticate;
                 info = @{NSLocalizedDescriptionKey:
                              _RAuthenticationLocalizedString(@"builtinVerificationWorkflow.error.couldNotAuthenticate"),
                          NSLocalizedFailureReasonErrorKey:
                              _RAuthenticationLocalizedString(@"builtinVerificationWorkflow.error.couldNotAuthenticate.reason"),
                          NSUnderlyingErrorKey:
                              error};
             }
             
             [strongSelf _reportNetworkActivityProgress:1.0];
             [strongSelf _reportTransientError:[NSError errorWithDomain:RVerificationWorkflowTransientErrorDomain
                                                                   code:code
                                                               userInfo:info]];
         }
     }];
    
    if (self.tokenOperation)
    {
        [self _reportNetworkActivityProgress:0.3];
    }
    else
    {
        [self _completeVerificationWithToken:nil
                                       error:[NSError errorWithDomain:RVerificationWorkflowErrorDomain
                                                                 code:RVerificationWorkflowErrorInvalidAuthenticator
                                                             userInfo:@
                                              {NSLocalizedDescriptionKey:
                                                  _RAuthenticationLocalizedString(@"builtinVerificationWorkflow.error.invalidAuthenticator"),
                                              NSLocalizedFailureReasonErrorKey:
                                                  _RAuthenticationLocalizedString(@"builtinVerificationWorkflow.error.invalidAuthenticator.reason")}]];
    }
}

- (void)_cancel
{
    id errorInfo = @{NSLocalizedDescriptionKey:
                         _RAuthenticationLocalizedString(@"builtinVerificationWorkflow.error.cancelled"),
                     NSLocalizedFailureReasonErrorKey:
                         _RAuthenticationLocalizedString(@"builtinVerificationWorkflow.error.cancelled.reason")};
    
    [self _completeVerificationWithToken:nil
                                   error:[NSError errorWithDomain:RVerificationWorkflowErrorDomain
                                                             code:RVerificationWorkflowErrorCancelled
                                                         userInfo:errorInfo]];
}

- (void)_completeVerificationWithToken:(RAuthenticationToken *)token error:(NSError *)error
{
    /*
     * Dismiss the view controller.
     *
     * [REM-8922] The dismissal isn't animated unless the call is made asynchronously.
     */
    rauthentication_verification_completion_block_t completion = self.completion;
    __block _RAuthenticationNavigationController *navigationController = (id)self.verificationDialog.navigationController;
    dispatch_async(dispatch_get_main_queue(), ^{
        [navigationController dismissViewControllerAnimated:YES completion:^{
            navigationController = nil;
            
            completion(token, error);
        }];
    });
    
    @synchronized(self)
    {
        self.tokenOperation     = nil;
        self.authenticator      = nil;
        self.completion         = nil;
        self.verificationDialog = nil;
        self.inProgress         = NO;
        
        [self _releaseLocalAuthenticationContext];
    }
    
    if (error)
    {
        if (error.code == RVerificationWorkflowErrorCancelled)
        {
            [_RAuthenticationTracking broadcastEndVerificationEventWithResult:_RAuthenticationTrackingVerificationResultCanceled];
        }
        else
        {
            [_RAuthenticationTracking broadcastEndVerificationEventWithResult:_RAuthenticationTrackingVerificationResultFailed];
        }
    }
}

- (void)_releaseLocalAuthenticationContext
{
    [_localAuthenticationContext invalidate];
    _localAuthenticationContext = nil;
}

#pragma mark <RVerificationDialogDelegate>
- (void)verificationDialog:(UIViewController<RVerificationDialog> *__unused)verificationDialog wantsToProceedWithPassword:(NSString *)password
{
    [self _releaseLocalAuthenticationContext];
    [self _verifyPassword:password trackingResultIfSuccess:_RAuthenticationTrackingVerificationResultPassword];
}

- (void)verificationDialogWantsToCancel:(UIViewController<RVerificationDialog> *__unused)verificationDialog
{
    [self _cancel];
}
@end
