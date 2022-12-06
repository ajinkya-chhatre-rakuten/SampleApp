/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationUI/RAuthenticationUI.h>
#import "_RAuthenticationButton.h"
#import "_RAuthenticationLogoView.h"
#import "_RAuthenticationNavigationController.h"
#import "_RAuthenticationUIValues.h"
#import "_RAuthenticationUIHelpers.h"
#import "_RAuthenticationTracking.h"

@interface RBuiltinLogoutDialog()<UIAdaptivePresentationControllerDelegate>
@property (nonatomic) UIView                 *logo;
@property (nonatomic) _RAuthenticationButton *logout;
@property (nonatomic) _RAuthenticationButton *logoutFromAllApps;
@end

@implementation RBuiltinLogoutDialog

#pragma mark UIViewController
- (void)loadView
{
    [super loadView];

    /*
     * Content views
     */
    CGSize logoSize;
    [self addContentViews:
     _logo              = _RAuthenticationCreateLogoView(&logoSize),
     _logout            = [_RAuthenticationButton buttonWithType:_RAuthenticationSecondaryButtonType],
     _logoutFromAllApps = [_RAuthenticationButton buttonWithType:_RAuthenticationSecondaryButtonType],
     nil];

    _logo.translatesAutoresizingMaskIntoConstraints = NO;
    [_logo setContentHuggingPriority:UILayoutPriorityDefaultLow + 2 forAxis:UILayoutConstraintAxisHorizontal];
    [_logo setContentHuggingPriority:UILayoutPriorityDefaultLow + 2 forAxis:UILayoutConstraintAxisVertical];
    [_logo setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_logo setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    /*
     * Layout rules
     */
    UIView *container = self.view;

    [NSLayoutConstraint activateConstraints:@[
                                         // Logo
                                         MakeConstraint(_logo, container,
                                                        .attribute = NSLayoutAttributeTop,
                                                        .constant = _RAuthenticationUIValues.PRIMARY_SPACING),
                                         MakeConstraint(_logo, container,
                                                        .attribute = NSLayoutAttributeLeading,
                                                        .relation = NSLayoutRelationGreaterThanOrEqual,
                                                        .constant = _RAuthenticationUIValues.PRIMARY_SPACING),
                                         MakeConstraint(_logo, nil, // use the natural height whenever possible
                                                        .attribute = NSLayoutAttributeHeight,
                                                        .constant  = logoSize.height),
                                         MakeConstraint(_logo, container, // on small screens, keep the logo inside the container at all cost
                                                        .attribute = NSLayoutAttributeWidth,
                                                        .relation  = NSLayoutRelationLessThanOrEqual,
                                                        .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
                                         MakeConstraint(_logo, _logo, // aspect ratio must always be constant
                                                        .attribute  = NSLayoutAttributeWidth,
                                                        .from       = NSLayoutAttributeHeight,
                                                        .multiplier = logoSize.width / logoSize.height),
                                         MakeConstraint(_logo, container,
                                                        .attribute = NSLayoutAttributeCenterX),
                                         // Logout
                                         MakeConstraint(_logout, _logo,
                                                        .attribute = NSLayoutAttributeTop,
                                                        .from      = NSLayoutAttributeBottom,
                                                        .constant  = _RAuthenticationUIValues.PRIMARY_SPACING * 2),
                                         MakeConstraint(_logout, container,  .attribute = NSLayoutAttributeLeading,
                                                        .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
                                         MakeConstraint(_logout, container,  .attribute = NSLayoutAttributeCenterX),
                                         // Logout from all apps
                                         MakeConstraint(_logoutFromAllApps, _logout,
                                                        .attribute = NSLayoutAttributeTop,
                                                        .from      = NSLayoutAttributeBottom,
                                                        .constant  = _RAuthenticationUIValues.SECONDARY_SPACING + _RAuthenticationUIValues.PRIMARY_SPACING),
                                         MakeConstraint(_logoutFromAllApps, container,
                                                        .attribute = NSLayoutAttributeLeading,
                                                        .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
                                         MakeConstraint(_logoutFromAllApps, container,
                                                        .attribute = NSLayoutAttributeCenterX),
                                         ]];

    [self addStandardFooter];

    /*
     * Logic
     */
    void (^onTap)(UIControl *, SEL) = ^(UIControl *control, SEL selector)
    {
        [control addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    };
    onTap(_logout,            @selector(onLogoutButtonTapped));
    onTap(_logoutFromAllApps, @selector(onLogoutFromAllAppsButtonTapped));

    /*
     * Content
     */
    self.title               = _RAuthenticationLocalizedString(@"builtinLogoutDialog.title");
    _logout.title            = _RAuthenticationLocalizedString(@"builtinLogoutDialog.revokeAccessToken(button)");
    _logoutFromAllApps.title = _RAuthenticationLocalizedString(@"builtinLogoutDialog.logoutCompletely(button)");

    /*
     * Automation ID
     */
    _logout.accessibilityIdentifier             = _RAuthenticationAutomationIds(@"logout");
    _logoutFromAllApps.accessibilityIdentifier  = _RAuthenticationAutomationIds(@"logoutFromAllApps");
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.rightBarButtonItem =
    [UIBarButtonItem.alloc initWithTitle:_RAuthenticationLocalizedString(@"builtinLogoutDialog.cancel(button)")
                                   style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(onSkipButtonTapped)];

    self.navigationController.presentationController.delegate = self;
    
    [super viewWillAppear:animated];
}

#pragma mark <UIAdaptivePresentationControllerDelegate>
- (void)presentationControllerDidDismiss:(UIPresentationController *)presentationController
{
    if (self.cancelButtonHandler) self.cancelButtonHandler();
}

#pragma mark <RAuthenticationViewControllerFooterDelegate>
- (void)onPrivacyPolicyButtonTapped
{
    if (_privacyPolicyButtonHandler)
    {
        _privacyPolicyButtonHandler();
    }
    else
    {
        [self openStandardPrivacyPolicyPage];
    }
}

- (void)onHelpButtonTapped
{
    if (_helpButtonHandler)
    {
        _helpButtonHandler();
    }
    else
    {
        [self openStandardHelpPage];
    }
}

- (void)logoutWithOptions:(RAuthenticationLogoutOptions)options
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.logoutOptionHandler) self.logoutOptionHandler(options);
    }];
}

#pragma mark ▪️Actions
- (void)onSkipButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.cancelButtonHandler) self.cancelButtonHandler();
    }];
}

- (void)onLogoutButtonTapped
{
    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:_RAuthenticationLocalizedString(@"builtinLogoutDialog.confirmLogoutAlert.title")
                                                                    message:[_RAuthenticationLocalizedString(@"builtinLogoutDialog.confirmLogoutAlert.message")
                                                                             stringByReplacingOccurrencesOfString:@"{APP_NAME}"
                                                                             withString:_RAuthenticationApplicationName()]
                                                             preferredStyle:UIAlertControllerStyleAlert];

    [dialog addAction:[UIAlertAction actionWithTitle:_RAuthenticationLocalizedString(@"builtinLogoutDialog.confirmLogoutAlert.cancel(button)")
                                               style:UIAlertActionStyleCancel
                                             handler:nil]];

    [dialog addAction:[UIAlertAction actionWithTitle:_RAuthenticationLocalizedString(@"builtinLogoutDialog.confirmLogoutAlert.proceed(button)")
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction * _Nonnull action) {
                                                 [self logoutWithOptions:RAuthenticationLogoutRevokeAccessToken];
                                             }]];

    [self presentViewController:dialog animated:YES completion:nil];
}

- (void)onLogoutFromAllAppsButtonTapped
{
    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:_RAuthenticationLocalizedString(@"builtinLogoutDialog.confirmLogoutFromAllAlert.title")
                                                                    message:_RAuthenticationLocalizedString(@"builtinLogoutDialog.confirmLogoutFromAllAlert.message")
                                                             preferredStyle:UIAlertControllerStyleAlert];

    [dialog addAction:[UIAlertAction actionWithTitle:_RAuthenticationLocalizedString(@"builtinLogoutDialog.confirmLogoutFromAllAlert.cancel(button)")
                                               style:UIAlertActionStyleCancel
                                             handler:nil]];

    [dialog addAction:[UIAlertAction actionWithTitle:_RAuthenticationLocalizedString(@"builtinLogoutDialog.confirmLogoutFromAllAlert.proceed(button)")
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction * _Nonnull action) {
                                                 [self logoutWithOptions:RAuthenticationLogoutCompletely];
                                             }]];

    [self presentViewController:dialog animated:YES completion:nil];
}
@end
