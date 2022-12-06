/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationUI/RAuthenticationUI.h>
#import "_RAuthenticationNavigationController.h"
#import "_RAuthenticationUIHelpers.h"
#import "_RAuthenticationViewControllerExtension.h"

@interface RBuiltinLogoutWorkflow ()
@property (copy, nonatomic, nullable) RBuiltinWorkflowPresentationConfiguration *presentationConfiguration;
@end

@implementation RBuiltinLogoutWorkflow
- (instancetype)initWithSettings:(RAuthenticationSettings *)settings
       presentationConfiguration:(nullable RBuiltinWorkflowPresentationConfiguration *)presentationConfiguration
{
    NSParameterAssert([settings isValid]);
    if ((self = [super init]))
    {
        _settings   = settings.copy;
        _presentationConfiguration = presentationConfiguration;
    }
    return self;
}

- (instancetype)initWithSettings:(RAuthenticationSettings *)settings
         presenterViewController:(UIViewController *)presenterViewController
{
    RBuiltinWorkflowPresentationConfiguration *presentationConfiguration = RBuiltinWorkflowPresentationConfiguration.new;
    presentationConfiguration.presenterViewController = presenterViewController;
    return [self initWithSettings:settings
        presentationConfiguration:presentationConfiguration];
}

- (instancetype)initWithSettings:(RAuthenticationSettings *)settings
{
    return [self initWithSettings:settings presentationConfiguration:nil];
}

- (instancetype)init
{
    RAUTH_INVALID_METHOD;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) __strong copy = [[self.class allocWithZone:zone] initWithSettings:self.settings];
    copy.privacyPolicyPagePresenter = self.privacyPolicyPagePresenter;
    copy.helpPagePresenter = self.helpPagePresenter;
    return copy;
}

- (void)logout:(RAuthenticationAccount *)account completion:(void (^)(BOOL cancelled))completion
{
    NSParameterAssert(account);
    NSParameterAssert(completion);
    
    RAuthenticationSettings *settings = self.settings;
    
    rauthentication_presenter_t        privacyPolicyPagePresenter = self.privacyPolicyPagePresenter;
    rauthentication_presenter_t        helpPagePresenter          = self.helpPagePresenter;
    rauthentication_logout_preflight_t preflight                  = self.preflight;
    
    void (^logout)(RAuthenticationLogoutOptions) = ^(RAuthenticationLogoutOptions options)
    {
        [account logoutWithSettings:settings options:options completion:^(NSError *error)
         {
             completion(NO);
         }];
    };
    
    RBuiltinLogoutDialog    *dialog     = RBuiltinLogoutDialog.new;
    typeof(dialog) __weak    weakDialog = dialog;
    if (privacyPolicyPagePresenter)
    {
        dialog.privacyPolicyButtonHandler = ^{
            privacyPolicyPagePresenter((id)weakDialog.navigationController);
        };
    }
    
    if (helpPagePresenter)
    {
        dialog.helpButtonHandler = ^{
            self.helpPagePresenter((id)weakDialog.navigationController);
        };
    }
    dialog.cancelButtonHandler = ^{
        completion(YES);
    };
    
    dialog.logoutOptionHandler = ^(RAuthenticationLogoutOptions options) {
        if (preflight)
        {
            preflight(^(BOOL canceled)
                      {
                          if (canceled)
                          {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  completion(YES);
                              });
                          }
                          else
                          {
                              logout(options);
                          }
                      });
        }
        else
        {
            logout(options);
        }
    };
    
    _RAuthenticationNavigationController *navigationController = [_RAuthenticationNavigationController.alloc initWithRootViewController:dialog];
    [navigationController presentWithConfiguration:_presentationConfiguration completion:nil];
}
@end
