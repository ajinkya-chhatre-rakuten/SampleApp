/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationUI/RAuthenticationUI.h>
#import "_RAuthenticationLabel.h"
#import "_RAuthenticationButton.h"
#import "_RAuthenticationLogoView.h"
#import "_RAuthenticationUIValues.h"
#import "_RAuthenticationTracking.h"
#import "_RAuthenticationUIHelpers.h"

#pragma mark - RBuiltinAccountSelectionDialog

@interface RBuiltinAccountSelectionDialog()<UIAdaptivePresentationControllerDelegate>
@property (nonatomic, strong) RAuthenticationAccount *mostRecentlyUsedAccount;

@property (nonatomic) UIView                 *logo;
@property (nonatomic) _RAuthenticationLabel  *error;
@property (nonatomic) _RAuthenticationLabel  *welcome;
@property (nonatomic) _RAuthenticationButton *login;
@property (nonatomic) _RAuthenticationLabel  *privacyPolicy;
@property (nonatomic) _RAuthenticationLabel  *notYou;
@property (nonatomic) _RAuthenticationButton *useOtherAccount;

- (void)updateUserName;
@end


@implementation RBuiltinAccountSelectionDialog
- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark UIViewController
- (void)loadView
{
    [super loadView];

    /*
     * Content views
     */
    CGSize logoSize;
    [self addContentViews:
     _logo                  = _RAuthenticationCreateLogoView(&logoSize),
     _error                 = _RAuthenticationLabel.new,
     _welcome               = _RAuthenticationLabel.new,
     _login                 = [_RAuthenticationButton buttonWithType:_RAuthenticationPrimaryButtonType],
     _privacyPolicy         = _RAuthenticationLabel.new,
     _notYou                = _RAuthenticationLabel.new,
     _useOtherAccount       = [_RAuthenticationButton buttonWithType:_RAuthenticationSecondaryButtonType],
     nil];

    _logo.translatesAutoresizingMaskIntoConstraints = NO;
    [_logo setContentHuggingPriority:UILayoutPriorityDefaultLow + 2 forAxis:UILayoutConstraintAxisHorizontal];
    [_logo setContentHuggingPriority:UILayoutPriorityDefaultLow + 2 forAxis:UILayoutConstraintAxisVertical];
    [_logo setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_logo setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    _error.hidden = YES;
    _error.tintColor = _RAuthenticationUIValues.INPUT_FIELD_INVALID_COLOR;

    _welcome.fontSize      = _RAuthenticationUIValues.FONT_SIZE_2;
    _welcome.textAlignment = NSTextAlignmentCenter;

    _privacyPolicy.fontSize      = _RAuthenticationUIValues.FONT_SIZE_2;
    _privacyPolicy.textAlignment = NSTextAlignmentCenter;

    _notYou.fontSize      = _RAuthenticationUIValues.FONT_SIZE_2;
    _notYou.textAlignment = NSTextAlignmentCenter;


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
     // Welcome
     MakeConstraint(_welcome, _logo,
                    .attribute = NSLayoutAttributeTop,
                    .from      = NSLayoutAttributeBottom,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING * 2,
                    .priority  = UILayoutPriorityDefaultHigh),
     MakeConstraint(_welcome, container,
                    .attribute = NSLayoutAttributeLeading,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
     MakeConstraint(_welcome, container,
                    .attribute = NSLayoutAttributeCenterX),
     // Login
     MakeConstraint(_login, _welcome,
                    .attribute = NSLayoutAttributeTop,
                    .from      = NSLayoutAttributeBottom,
                    .constant  = _RAuthenticationUIValues.SECONDARY_SPACING),
     MakeConstraint(_login, container,  .attribute = NSLayoutAttributeLeading,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
     MakeConstraint(_login, container,  .attribute = NSLayoutAttributeCenterX),
     // Privacy policy acknowledgement
     MakeConstraint(_privacyPolicy, container,
                    .attribute = NSLayoutAttributeLeading,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
     MakeConstraint(_privacyPolicy, container,
                    .attribute = NSLayoutAttributeCenterX),
     MakeConstraint(_privacyPolicy, _login,
                    .attribute = NSLayoutAttributeTop,
                    .from      = NSLayoutAttributeBottom,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
     // Not You?
     MakeConstraint(_notYou, _login,
                    .attribute = NSLayoutAttributeTop,
                    .from      = NSLayoutAttributeBottom,
                    .constant  = _RAuthenticationUIValues.SECONDARY_SPACING + _RAuthenticationUIValues.PRIMARY_SPACING,
                    .priority  = UILayoutPriorityDefaultHigh),
     MakeConstraint(_notYou, _privacyPolicy,
                    .attribute = NSLayoutAttributeTop,
                    .from      = NSLayoutAttributeBottom,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
     MakeConstraint(_notYou, container,
                    .attribute = NSLayoutAttributeLeading,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
     MakeConstraint(_notYou, container,
                    .attribute = NSLayoutAttributeCenterX),
     // Other account
     MakeConstraint(_useOtherAccount, _notYou,
                    .attribute = NSLayoutAttributeTop,
                    .from      = NSLayoutAttributeBottom,
                    .constant  = _RAuthenticationUIValues.SECONDARY_SPACING),
     MakeConstraint(_useOtherAccount, container,
                    .attribute = NSLayoutAttributeLeading,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
     MakeConstraint(_useOtherAccount, container,
                    .attribute = NSLayoutAttributeCenterX),
     ]];

    [self addStandardFooter];

    _error.additionalConstraintsWhenVisible =
    @[MakeConstraint(_error, _logo,
                     .attribute = NSLayoutAttributeTop,
                     .from      = NSLayoutAttributeBottom,
                     .constant  = _RAuthenticationUIValues.PRIMARY_SPACING * 2),
      MakeConstraint(_error, container,
                     .attribute = NSLayoutAttributeLeading,
                     .constant = _RAuthenticationUIValues.PRIMARY_SPACING),
      MakeConstraint(_error, container,
                     .attribute = NSLayoutAttributeCenterX),
      MakeConstraint(_welcome, _error,
                     .attribute = NSLayoutAttributeTop,
                     .from      = NSLayoutAttributeBottom,
                     .constant  = _RAuthenticationUIValues.SECONDARY_SPACING)
      ];

    /*
     * Logic
     */
    void (^onTap)(UIControl *, SEL) = ^(UIControl *control, SEL selector)
    {
        [control addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    };
    onTap(_login,           @selector(onLoginButtonTapped));
    onTap(_useOtherAccount, @selector(onUseOtherAccountButtonTapped));

    /*
     * Content
     */
    self.title             = _RAuthenticationLocalizedString(@"builtinAccountSelectionDialog.title");
    _login.title           = _RAuthenticationLocalizedString(@"builtinLoginDialog.login(button)");
    _useOtherAccount.title = _RAuthenticationLocalizedString(@"builtinAccountSelectionDialog.manualLogin(button)");
    _privacyPolicy.text    = _RAuthenticationLocalizedString(@"builtinDialogs.privacyPolicyAcknowledgement(date)");

    /*
     * Automation Id's
     */
    _welcome.accessibilityIdentifier            = _RAuthenticationAutomationIds(@"welcomeText");
    _privacyPolicy.accessibilityIdentifier      = _RAuthenticationAutomationIds(@"privacyPolicy");
    _login.accessibilityIdentifier              = _RAuthenticationAutomationIds(@"login");
    _useOtherAccount.accessibilityIdentifier    = _RAuthenticationAutomationIds(@"loginWithDiffAcc");
    _error.accessibilityIdentifier              = _RAuthenticationAutomationIds(@"errorMessage");
}

- (void)viewWillAppear:(BOOL)animated
{
    UIBarButtonItem *skipButton = nil;
    if (!_shouldHideSkipButton)
    {
        skipButton = [UIBarButtonItem.alloc initWithTitle:_RAuthenticationLocalizedString(@"builtinLoginDialog.skip(button)")
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(onSkipButtonTapped)];
    }
    self.navigationItem.rightBarButtonItem = skipButton;

    [self updateUserName];
    
    self.navigationController.presentationController.delegate = self;
    
    [super viewWillAppear:animated];
}

#pragma mark <RAccountSelectionDialog>
@synthesize accountSelectionDialogDelegate = _accountSelectionDialogDelegate;
@synthesize accounts = _accounts;

- (void)setAccounts:(NSArray *)accounts
{
    if (accounts != _accounts)
    {
        _accounts = accounts.copy;

        RAuthenticationAccount *mostRecentlyUsedAccount = nil;
        for (RAuthenticationAccount *account in accounts)
        {
            if (account.name.length &&
                account.password.length &&
                (!mostRecentlyUsedAccount || _RAuthenticationMRUAccountComparator(mostRecentlyUsedAccount, account) == NSOrderedAscending))
            {
                mostRecentlyUsedAccount = account;
            }
        }
        self.mostRecentlyUsedAccount = mostRecentlyUsedAccount;

        [self updateUserName];
    }
}

- (BOOL)handleError:(NSError *)error
{
    // REM-7875: network errors should be shown without closing the login ui
    if ([error.domain isEqualToString:NSURLErrorDomain])
    {
        [self showErrorMessage:error.localizedDescription];
        return YES;
    }
    else if ([error.domain isEqualToString:RWCAppEngineResponseParserErrorDomain])
    {
        // MIDS-395: 🐛Login workflow does not handle errors properly
        // If any error returned from server, show the manual login screen.
        dispatch_async(dispatch_get_main_queue(), ^{
            id<RAccountSelectionDialogDelegate> delegate = self.accountSelectionDialogDelegate;
            if ([delegate respondsToSelector:@selector(accountSelectionDialogWantsToSignInWithAnotherAccount:)])
            {
                [delegate accountSelectionDialogWantsToSignInWithAnotherAccount:self];
            }
        });
        return YES;
    }

    return NO;
}

#pragma mark <UIAdaptivePresentationControllerDelegate>
- (void)presentationControllerDidDismiss:(UIPresentationController *)presentationController
{
    [self onSkipButtonTapped];
}

#pragma mark <RAuthenticationViewControllerFooterDelegate>
- (void)onPrivacyPolicyButtonTapped
{
    [self dismissErrorMessage];

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
    [self dismissErrorMessage];

    if (_helpButtonHandler)
    {
        _helpButtonHandler();
    }
    else
    {
        [self openStandardHelpPage];
    }
}

#pragma mark ▪️Actions
- (void)onSkipButtonTapped
{
    [self dismissErrorMessage];

    id<RAccountSelectionDialogDelegate> delegate = self.accountSelectionDialogDelegate;
    if ([delegate respondsToSelector:@selector(accountSelectionDialogWantsToSkipSignIn:)])
    {
        [delegate accountSelectionDialogWantsToSkipSignIn:self];
    }
}

- (void)onLoginButtonTapped
{
    [_RAuthenticationTracking setLoginMethod:_RAuthenticationLoginMethodOneTapSSO];

    [self dismissErrorMessage];

    id<RAccountSelectionDialogDelegate> delegate = self.accountSelectionDialogDelegate;
    [delegate accountSelectionDialog:self wantsToSignInWithAccount:self.mostRecentlyUsedAccount];
}

- (void)onUseOtherAccountButtonTapped
{
    [self dismissErrorMessage];

    id<RAccountSelectionDialogDelegate> delegate = self.accountSelectionDialogDelegate;
    if ([delegate respondsToSelector:@selector(accountSelectionDialogWantsToSignInWithAnotherAccount:)])
    {
        [delegate accountSelectionDialogWantsToSignInWithAnotherAccount:self];
    }
}

#pragma mark ▪️Other

- (void)updateUserName
{
    if (_mostRecentlyUsedAccount)
    {
        NSString *fullName = _mostRecentlyUsedAccount.userInformation.fullname ?: _mostRecentlyUsedAccount.name;

        _welcome.text = [_RAuthenticationLocalizedString(@"builtinAccountSelectionDialog.welcome")
                         stringByReplacingOccurrencesOfString:@"{FULLNAME}"
                         withString:fullName];
        _notYou.text = [_RAuthenticationLocalizedString(@"builtinAccountSelectionDialog.useOtherAccount")
                        stringByReplacingOccurrencesOfString:@"{FULLNAME}"
                        withString:fullName];
    }
}

#pragma mark ▪️Displaying Errors
- (void)showErrorMessage:(NSString *)message
{
    [self dismissErrorMessage];

    if (!message.length)
    {
        return;
    }
    _error.text = message;
    _error.hidden = NO;
}

- (void)dismissErrorMessage
{
    _error.text = nil;
    _error.hidden = YES;
}

@end
