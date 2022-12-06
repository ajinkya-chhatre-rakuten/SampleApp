/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationUI/RAuthenticationUI.h>
#import "_RAuthenticationNavigationController.h"
#import "_RAuthenticationTracking.h"
#import "_RAuthenticationUIHelpers.h"
#import "_RAuthenticationViewControllerExtension.h"

/* RAUTH_EXPORT */ NSString *const RLoginWorkflowCompletedSuccessfullyNotification   = @"RLoginWorkflowCompletedSuccessfullyNotification";
/* RAUTH_EXPORT */ NSString *const RLoginWorkflowFailedWithErrorNotification         = @"RLoginWorkflowFailedWithErrorNotification";
/* RAUTH_EXPORT */ NSString *const RLoginWorkflowCancelledNotification               = @"RLoginWorkflowCancelledNotification";
/* RAUTH_EXPORT */ NSString *const RLoginWorkflowStartPasswordRetrievalNotification  = @"RLoginWorkflowStartPasswordRetrievalNotification";
/* RAUTH_EXPORT */ NSString *const RLoginWorkflowStartNewAccountCreationNotification = @"RLoginWorkflowStartNewAccountCreationNotification";
/* RAUTH_EXPORT */ NSString *const RLoginWorkflowTransientErrorNotification          = @"RLoginWorkflowTransientErrorNotification";
/* RAUTH_EXPORT */ NSString *const RLoginWorkflowNetworkActivityStartedNotification  = @"RLoginWorkflowNetworkActivityStartedNotification";
/* RAUTH_EXPORT */ NSString *const RLoginWorkflowNetworkActivityStoppedNotification  = @"RLoginWorkflowNetworkActivityStoppedNotification";

/* RAUTH_EXPORT */ NSString *const RLoginWorkflowNotificationAccountKey = @"account";
/* RAUTH_EXPORT */ NSString *const RLoginWorkflowNotificationErrorKey   = @"error";

#pragma mark - Builtin authenticator factories

/* RAUTH_EXPORT */ rauthenticator_factory_block_t RBuiltinJapanIchibaUserAuthenticatorFactory(NSSet *requestedScopes)
{
    return RBuiltinJapanIchibaUserAuthenticatorFactoryWithServiceID(requestedScopes, nil);
}

/* RAUTH_EXPORT */ rauthenticator_factory_block_t RBuiltinJapanIchibaUserAuthenticatorFactoryWithServiceID(NSSet *requestedScopes, NSString *__nullable raeServiceIdentifier)
{
    return ^(RAuthenticationSettings *settings, NSString *username, NSString *password)
    {
        RJapanIchibaUserAuthenticator *authenticator = [RJapanIchibaUserAuthenticator.alloc initWithSettings:settings];
        authenticator.username             = username;
        authenticator.password             = password;
        authenticator.raeServiceIdentifier = raeServiceIdentifier;
        authenticator.requestedScopes      = requestedScopes;
        return authenticator;
    };
}

#pragma mark - Builtin login workflow
@interface RBuiltinLoginWorkflow () <RLoginDialogDelegate, RAccountSelectionDialogDelegate, UINavigationControllerDelegate>
{
@private
    int _isRunning:1;
}

/*
 * Things passed to -initWith… that we need to keep around
 */
@property (nonatomic) UIViewController<RLoginDialog>            *loginDialog;
@property (nonatomic) UIViewController<RAccountSelectionDialog> *accountSelectionDialog;
@property (copy, nonatomic) rauthentication_account_completion_block_t completion;
@property (copy, nonatomic) rauthenticator_factory_block_t authenticatorFactory;
@property (copy, nonatomic, nullable) RBuiltinWorkflowPresentationConfiguration *presentationConfiguration;

/*
 * We keep a strong reference to the RAuthenticator currently being used for
 * logging in, as we want to be able to cancel in from -cancel
 */
@property (nonatomic) RAuthenticator *loginAuthenticator;

/*
 * This is the navigation controller we push the developer-supplied view controllers onto.
 */
@property (nonatomic) _RAuthenticationNavigationController *navigationController;

/*
 * Try to log a user in with a username and password. This will create -loginAuthenticator
 * using -authenticatorFactory
 */
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
               completion:(rauthentication_account_completion_block_t)completion;

/*
 * Try logging in using the specified service identifier. If no service identifier is supplied,
 * then it bypasses account selection altogether and always uses -loginDialog to ask the user
 * their username and password.
 */
- (void)tryLoginWithServiceIdentifier:(NSString *)serviceIdentifier;

/*
 * Try login with an existing account
 */
- (void)tryLoginWithAccount:(RAuthenticationAccount *)account;

/*
 * Cancel and notify (or not).
 * Returns `YES` if the workflow was running, and thus really was cancelled.
 */
- (BOOL)cancelWithNotification:(BOOL)shouldNotifyObservers;
@end


@implementation RBuiltinLoginWorkflow
- (instancetype)init
{
    RAUTH_INVALID_METHOD;
}

- (instancetype)initWithAuthenticationSettings:(RAuthenticationSettings *)authenticationSettings
                                   loginDialog:(UIViewController<RLoginDialog> *)loginDialog
                        accountSelectionDialog:(nullable UIViewController<RAccountSelectionDialog> *)accountSelectionDialog
                          authenticatorFactory:(rauthenticator_factory_block_t)authenticatorFactory
                     presentationConfiguration:(nullable RBuiltinWorkflowPresentationConfiguration *)presentationConfiguration
                                    completion:(nullable rauthentication_account_completion_block_t)completion
{
    NSParameterAssert(authenticationSettings.isValid);
    NSParameterAssert(loginDialog);
    NSParameterAssert(authenticatorFactory);
    if (!authenticationSettings.isValid || !loginDialog || !authenticatorFactory) { return nil; }
    
    if ((self = [super init]))
    {
        /*
         * Wrap the completion so that we clear _isRunning when it gets invoked, as
         * well as dismiss the view controllers if needed.
         */
        typeof(self) __weak weakSelf = self;
        rauthentication_account_completion_block_t wrappedCompletion = ^(RAuthenticationAccount *account, NSError *error)
        {
            if (![self cancelWithNotification:NO]) { return; }
            
            NSString *notificationName;
            NSDictionary *userInfo;
            if (error)
            {
                notificationName = RLoginWorkflowFailedWithErrorNotification;
                userInfo = @{RLoginWorkflowNotificationErrorKey: error};
            }
            else
            {
                notificationName = RLoginWorkflowCompletedSuccessfullyNotification;
                userInfo = @{RLoginWorkflowNotificationAccountKey: account};
            }
            [NSNotificationCenter.defaultCenter postNotificationName:notificationName
                                                              object:weakSelf
                                                            userInfo:userInfo];
            
            if (completion) { completion(account, error); }
        };
        
        _authenticationSettings  = authenticationSettings;
        _loginDialog             = loginDialog;
        _accountSelectionDialog  = accountSelectionDialog;
        _authenticatorFactory    = authenticatorFactory;
        _presentationConfiguration = presentationConfiguration;
        _completion              = wrappedCompletion;
        
        /*
         * If the caller didn't set accountSelectionDialog, but provided a loginDialog that can be used
         * as such, then use that for both the login dialog and account selection:
         */
        if (!_accountSelectionDialog && [_loginDialog conformsToProtocol:@protocol(RAccountSelectionDialog)])
        {
            _accountSelectionDialog = (UIViewController<RAccountSelectionDialog> *)_loginDialog;
        }
        
        /*
         * Sets this workflow as the delegate for both controllers:
         */
        _loginDialog.loginDialogDelegate                       = self;
        _accountSelectionDialog.accountSelectionDialogDelegate = self;
    }
    
    return self;
}

- (instancetype)initWithAuthenticationSettings:(RAuthenticationSettings *)authenticationSettings
                                   loginDialog:(UIViewController<RLoginDialog> *)loginDialog
                        accountSelectionDialog:(UIViewController<RAccountSelectionDialog> *)accountSelectionDialog
                          authenticatorFactory:(rauthenticator_factory_block_t)authenticatorFactory
                       presenterViewController:(UIViewController *)presenterViewController
                                    completion:(rauthentication_account_completion_block_t)completion
{
    RBuiltinWorkflowPresentationConfiguration *presentationConfiguration = RBuiltinWorkflowPresentationConfiguration.new;
    presentationConfiguration.presenterViewController = presenterViewController;
    return [self initWithAuthenticationSettings:authenticationSettings
                                    loginDialog:loginDialog
                         accountSelectionDialog:accountSelectionDialog
                           authenticatorFactory:authenticatorFactory
                      presentationConfiguration:presentationConfiguration
                                     completion:completion];
}

- (instancetype)initWithAuthenticationSettings:(RAuthenticationSettings *)authenticationSettings
                                   loginDialog:(UIViewController<RLoginDialog> *)loginDialog
                        accountSelectionDialog:(UIViewController<RAccountSelectionDialog> *)accountSelectionDialog
                          authenticatorFactory:(rauthenticator_factory_block_t)authenticatorFactory
                                    completion:(rauthentication_account_completion_block_t)completion
{
    return [self initWithAuthenticationSettings:authenticationSettings
                                    loginDialog:loginDialog
                         accountSelectionDialog:accountSelectionDialog
                           authenticatorFactory:authenticatorFactory
                      presentationConfiguration:nil
                                     completion:completion];
}

- (void)start
{
    @synchronized(self)
    {
        /*
         * Only start if we haven't yet. Workflows are neither reentrant nor reusable.
         */
        
        if (!_isRunning)
        {
            _isRunning = YES;
            
            /*
             * Ask the authenticator factory what service identifier should be used.
             * If it returns "nil", then no attempt at using an existing account will be made.
             */
            NSString *serviceIdentifier = _authenticatorFactory(_authenticationSettings, @"", @"").serviceIdentifier;
            [self performSelectorOnMainThread:@selector(tryLoginWithServiceIdentifier:) withObject:serviceIdentifier waitUntilDone:NO];
        }
    }
}

- (void)cancel
{
    [self cancelWithNotification:YES];
}

+ (UINavigationBar *)navigationBarAppearance
{
    return _RAuthenticationNavigationBar.appearance;
}

#pragma mark Private methods

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
               completion:(rauthentication_account_completion_block_t)completion
{
    /*
     * REM-654: while we don't have access to the actual network progress data at this point,
     * the following gives a small indication to the user that something is happening…
     */
    _RAuthenticationNavigationBar *navigationBar = (id)_navigationController.navigationBar;
    NSProgress *progress = NSProgress.new;
    progress.totalUnitCount = 100;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Weird: this gets deadlocked in a semaphore if executed on the main thread. Apple bug?
        progress.completedUnitCount = 30;
    });
    navigationBar.observedProgress = progress;
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    _loginAuthenticator = _authenticatorFactory(_authenticationSettings, username, password);
    NSOperation *operation = _RAuthenticationDispatchGroupOperation(group, 0);
    operation.name = _RAuthenticationSelectorString(self, _cmd);
    [_loginAuthenticator.operationQueue addOperation:operation];
    
    typeof(self) __weak weakSelf = self;
    [_loginAuthenticator loginWithCompletion:^(RAuthenticationAccount *account, NSError *error) {
        [NSNotificationCenter.defaultCenter postNotificationName:RLoginWorkflowNetworkActivityStoppedNotification object:weakSelf];
        
        if (_RAuthenticationShouldProceed(operation, error))
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ progress.completedUnitCount = 100; });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                if (navigationBar.observedProgress == progress) navigationBar.observedProgress = nil;
                
                completion(account, error);
            });
        }
        
        dispatch_group_leave(group);
    }];
    
    [NSNotificationCenter.defaultCenter postNotificationName:RLoginWorkflowNetworkActivityStartedNotification object:self];
}

- (void)tryLoginWithServiceIdentifier:(NSString *)serviceIdentifier
{
    NSArray *accounts = nil;
    if (serviceIdentifier.length)
    {
        NSError *error = nil;
        accounts = [RAuthenticationAccount loadAccountsWithService:serviceIdentifier error:&error];
        
        if (error)
        {
            // Failed to read the keychain
            _completion(nil, error);
            return;
        }
    }
    
    UIViewController *viewControllerToPush;
    if (accounts.count)
    {
        [_RAuthenticationTracking broadcastSSOCredentialFound:@"device"];
        if (!_accountSelectionDialog)
        {
            // No account selection dialog: try to log the user in automatically!
            [self tryLoginWithAccount:accounts.firstObject];
            return;
        }
        else
        {
            _accountSelectionDialog.accounts = accounts;
            viewControllerToPush = _accountSelectionDialog;
        }
    }
    else
    {
        viewControllerToPush = _loginDialog;
    }
    
    if (_navigationController)
    {
        BOOL alreadyPushed = NO;
        for (UIViewController *viewController in _navigationController.viewControllers)
        {
            if (viewControllerToPush == viewController)
            {
                alreadyPushed = YES;
                break;
            }
        }
        
        if (alreadyPushed)
        {
            [_navigationController popToViewController:viewControllerToPush animated:YES];
        }
        else
        {
            [_navigationController pushViewController:viewControllerToPush animated:YES];
        }
    }
    else
    {
        _navigationController = [_RAuthenticationNavigationController.alloc initWithRootViewController:viewControllerToPush];
        _navigationController.delegate = self;
        [_navigationController presentWithConfiguration:_presentationConfiguration completion:nil];
    }
}

- (void)tryLoginWithAccount:(RAuthenticationAccount *)account
{
    NSParameterAssert(account);
    
    RBuiltinLoginWorkflow * __block retainedSelf = self;
    [self loginWithUsername:account.name
                   password:account.password
                 completion:^(RAuthenticationAccount *refreshedAccount, NSError *error)
     {
         typeof(retainedSelf) strongSelf = retainedSelf;
         retainedSelf = nil;
         if (strongSelf->_isRunning == false)
         {
             return;
         }
         
         // If the error means the credentials were invalid, we revert to asking the user to log in manually
         if ([error.domain isEqualToString:RWCAppEngineResponseParserErrorDomain] &&
             (error.code == RWCAppEngineResponseParserErrorInvalidParameter ||
              error.code == RWCAppEngineResponseParserErrorUnauthorized))
         {
             // REM-7889: prepare the login dialog
             id<RLoginDialog> loginDialog = strongSelf.loginDialog;
             if ([loginDialog respondsToSelector:@selector(populateWithUsername:)])
             {
                 [loginDialog populateWithUsername:account.name];
             }
             
             // REM-11844: try to delete the account from the keychain
             [account logoutWithSettings:strongSelf.authenticationSettings
                                 options:RAuthenticationLogoutDeleteAccount
                              completion:^(NSError *__unused ignored)
              {
                  [strongSelf tryLoginWithServiceIdentifier:nil];
              }];
             
             return;
         }
         
         // If we have a selection dialog, try handling the error with -handleError: first
         if (error && [strongSelf.accountSelectionDialog respondsToSelector:@selector(handleError:)])
         {
             if ([strongSelf.accountSelectionDialog handleError:error])
             {
                 return;
             }
         }
         
         // …otherwise we just call the completion
         strongSelf.completion(refreshedAccount, error);
     }];
}

- (BOOL)cancelWithNotification:(BOOL)shouldNotifyObservers
{
    @synchronized(self)
    {
        if (_isRunning)
        {
            _isRunning = NO;
            
            [_loginAuthenticator.operationQueue cancelAllOperations];
            _loginAuthenticator = nil;
            
            [_navigationController dismissViewControllerAnimated:YES completion:^{
                if (shouldNotifyObservers)
                {
                    [NSNotificationCenter.defaultCenter postNotificationName:RLoginWorkflowCancelledNotification
                                                                      object:self];
                }
            }];
            _navigationController   = nil;
            _accountSelectionDialog = nil;
            _loginDialog            = nil;
            _completion             = nil;
            
            return YES;
        }
        else
        {
            return NO;
        }
    }
}

#pragma mark NSObject
- (void)dealloc
{
    [self cancelWithNotification:NO];
}

#pragma mark <RLoginDialogDelegate>
- (void)loginDialog:(UIViewController<RLoginDialog> *)loginDialog wantsToSignInWithUsername:(NSString *)username password:(NSString *)password
{
    [_RAuthenticationTracking setLoginMethod:_RAuthenticationLoginMethodManualPassword];
    
    RBuiltinLoginWorkflow * __block retainedSelf = self;
    [self loginWithUsername:username
                   password:password
                 completion:^(RAuthenticationAccount *account, NSError *error)
     {
         typeof(retainedSelf) __strong strongSelf = retainedSelf;
         retainedSelf = nil;
         if (strongSelf->_isRunning == false)
         {
             return;
         }
         
         if (error)
         {
             BOOL shouldSendNotification = YES;
             if ([loginDialog respondsToSelector:@selector(handleError:)])
             {
                 shouldSendNotification = ![loginDialog handleError:error];
             }
             
             if (shouldSendNotification)
             {
                 [NSNotificationCenter.defaultCenter postNotificationName:RLoginWorkflowTransientErrorNotification
                                                                   object:strongSelf
                                                                 userInfo:@{RLoginWorkflowNotificationErrorKey: error}];
             }
             return;
         }
         
         strongSelf.completion(account, error);
     }];
}

- (void)loginDialogWantsToRetrieveForgottenPassword:(UIViewController<RLoginDialog> * __unused)loginDialog
{
    [NSNotificationCenter.defaultCenter postNotificationName:RLoginWorkflowStartPasswordRetrievalNotification
                                                      object:self];
}

- (void)loginDialogWantsToCreateNewAccount:(UIViewController<RLoginDialog> * __unused)loginDialog
{
    [NSNotificationCenter.defaultCenter postNotificationName:RLoginWorkflowStartNewAccountCreationNotification
                                                      object:self];
}

- (void)loginDialogWantsToSkipSignIn:(UIViewController<RLoginDialog> * __unused)loginDialog
{
    [self cancelWithNotification:YES];
}

#pragma mark <RAccountSelectionDialogDelegate>
- (void)accountSelectionDialog:(UIViewController<RAccountSelectionDialog>*)accountSelectionDialog
      wantsToSignInWithAccount:(RAuthenticationAccount *)account
{
    [_RAuthenticationTracking setLoginMethod:_RAuthenticationLoginMethodOneTapSSO];
    
    [self tryLoginWithAccount:account];
}

- (void)accountSelectionDialogWantsToSignInWithAnotherAccount:(UIViewController<RAccountSelectionDialog> * __unused)accountSelectionDialog
{
    // REM-7889: prepare the login dialog
    id<RLoginDialog> loginDialog = self.loginDialog;
    if ([loginDialog respondsToSelector:@selector(populateWithUsername:)])
    {
        [loginDialog populateWithUsername:nil];
    }
    
    [self tryLoginWithServiceIdentifier:nil];
}

- (void)accountSelectionDialogWantsToSkipSignIn:(UIViewController<RAccountSelectionDialog> * __unused)accountSelectionDialog
{
    [self cancelWithNotification:YES];
}

- (void)accountSelectionDialogWantsToCreateNewAccount:(UIViewController<RAccountSelectionDialog> * __unused)accountSelectionDialog;
{
    [NSNotificationCenter.defaultCenter postNotificationName:RLoginWorkflowStartNewAccountCreationNotification
                                                      object:self];
}

#pragma mark <UINavigationControllerDelegate>
- (void)navigationController:(UINavigationController * __unused)navigationController
      willShowViewController:(RAuthenticationViewController *)viewController
                    animated:(BOOL __unused)animated
{
    ((_RAuthenticationNavigationBar *)viewController.navigationController.navigationBar).observedProgress = nil;
    [_loginAuthenticator.operationQueue cancelAllOperations];
}

@end
