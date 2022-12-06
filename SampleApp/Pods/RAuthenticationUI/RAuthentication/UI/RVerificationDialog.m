/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationUI/RAuthenticationUI.h>
#import "_RAuthenticationLabel.h"
#import "_RAuthenticationCheckbox.h"
#import "_RAuthenticationButton.h"
#import "_RAuthenticationLogoView.h"
#import "_RAuthenticationTextField.h"
#import "_RAuthenticationScrollView.h"
#import "_RAuthenticationUIValues.h"
#import "_RAuthenticationUIHelpers.h"

@interface RBuiltinVerificationDialog()<UITextFieldDelegate, UIAdaptivePresentationControllerDelegate>
@property (nonatomic) UIView                     *logo;

@property (nonatomic) _RAuthenticationLabel      *message;

@property (nonatomic) _RAuthenticationTextField  *password;
@property (nonatomic) _RAuthenticationLabel      *passwordError;

@property (nonatomic) _RAuthenticationCheckbox   *showPassword;

@property (nonatomic) _RAuthenticationButton     *resetAccount;

@property (nonatomic) _RAuthenticationButton     *confirm;

@property (nonatomic, null_resettable, copy) NSString  *passwordErrorMessage;
@end

@implementation RBuiltinVerificationDialog
- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)setPasswordResetButtonHandler:(dispatch_block_t)passwordResetButtonHandler
{
    if (passwordResetButtonHandler != _passwordResetButtonHandler)
    {
        _passwordResetButtonHandler = [passwordResetButtonHandler copy];
        _resetAccount.hidden = !passwordResetButtonHandler;
    }
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
     _logo          = _RAuthenticationCreateLogoView(&logoSize),
     _message       = _RAuthenticationLabel.new,
     _password      = _RAuthenticationTextField.new,
     _passwordError = _RAuthenticationLabel.new,
     _showPassword  = _RAuthenticationCheckbox.new,
     _resetAccount  = [_RAuthenticationButton buttonWithType:_RAuthenticationTernaryButtonType],
     _confirm       = [_RAuthenticationButton buttonWithType:_RAuthenticationPrimaryButtonType],
     nil];

    _logo.translatesAutoresizingMaskIntoConstraints = NO;
    [_logo setContentHuggingPriority:UILayoutPriorityDefaultLow + 2 forAxis:UILayoutConstraintAxisHorizontal];
    [_logo setContentHuggingPriority:UILayoutPriorityDefaultLow + 2 forAxis:UILayoutConstraintAxisVertical];
    [_logo setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_logo setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    _message.fontSize      = _RAuthenticationUIValues.FONT_SIZE_1;
    _message.textAlignment = NSTextAlignmentNatural;

    _password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _password.autocorrectionType     = UITextAutocorrectionTypeNo;
    _password.spellCheckingType      = UITextSpellCheckingTypeNo;
    _password.keyboardType           = UIKeyboardTypeASCIICapable;
    _password.secureTextEntry        = !_showPassword.selected;
    _password.clearButtonMode        = UITextFieldViewModeWhileEditing;
    _password.returnKeyType          = UIReturnKeyGo;

    _showPassword.fontSize  = _RAuthenticationUIValues.FONT_SIZE_2;

    _resetAccount.hidden = !_passwordResetButtonHandler;

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
     // Message
     MakeConstraint(_message, _logo,
                    .attribute = NSLayoutAttributeTop,
                    .from      = NSLayoutAttributeBottom,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING * 2,
                    ),
     MakeConstraint(_message, container,
                    .attribute = NSLayoutAttributeLeading,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
     MakeConstraint(_message, container,
                    .attribute = NSLayoutAttributeCenterX),
     // Password error
     MakeConstraint(_passwordError, _message,
                    .attribute = NSLayoutAttributeTop,
                    .from      = NSLayoutAttributeBottom,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
     MakeConstraint(_passwordError, container,
                    .attribute = NSLayoutAttributeLeading,
                    .constant = _RAuthenticationUIValues.PRIMARY_SPACING),
     MakeConstraint(_passwordError, container,
                    .attribute = NSLayoutAttributeCenterX),
     // Password
     MakeConstraint(_password, _passwordError,
                    .attribute = NSLayoutAttributeTop,
                    .from      = NSLayoutAttributeBottom,
                    .constant  = _RAuthenticationUIValues.SECONDARY_SPACING),
     MakeConstraint(_password, container,
                    .attribute = NSLayoutAttributeLeading,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
     MakeConstraint(_password, container,
                    .attribute = NSLayoutAttributeCenterX),
     // Show Password
     MakeConstraint(_showPassword, _password,
                    .attribute = NSLayoutAttributeTop,
                    .from      = NSLayoutAttributeBottom,
                    .constant  = _RAuthenticationUIValues.TERNARY_SPACING),
     MakeConstraint(_showPassword, container,
                    .attribute = NSLayoutAttributeLeading,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
     MakeConstraint(_showPassword, container,
                    .attribute = NSLayoutAttributeCenterX),
     // Confirm
     MakeConstraint(_confirm, _showPassword,
                    .attribute = NSLayoutAttributeTop,
                    .from      = NSLayoutAttributeBottom,
                    .constant  = _RAuthenticationUIValues.SECONDARY_SPACING,
                    .priority  = UILayoutPriorityDefaultHigh),
     MakeConstraint(_confirm, container,  .attribute = NSLayoutAttributeLeading,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
     MakeConstraint(_confirm, container,  .attribute = NSLayoutAttributeCenterX),
     ]];

    [self addStandardFooter];

    _resetAccount.additionalConstraintsWhenVisible =
    @[MakeConstraint(_resetAccount, _showPassword,
                     .attribute = NSLayoutAttributeTop,
                     .from      = NSLayoutAttributeBottom,
                     .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
      MakeConstraint(_resetAccount, container,
                     .attribute = NSLayoutAttributeLeading,
                     .constant = _RAuthenticationUIValues.PRIMARY_SPACING),
      MakeConstraint(_resetAccount, container,
                     .attribute = NSLayoutAttributeCenterX),
      MakeConstraint(_confirm, _resetAccount,
                     .attribute = NSLayoutAttributeTop,
                     .from      = NSLayoutAttributeBottom,
                     .constant  = _RAuthenticationUIValues.SECONDARY_SPACING)
      ];

    /*
     * Logic
     */
    _password.delegate = self;

    void (^onTap)(UIControl *, SEL) = ^(UIControl *control, SEL selector)
    {
        [control addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    };
    onTap(_showPassword,     @selector(onShowPasswordCheckboxValueChanged));
    onTap(_resetAccount,     @selector(onResetAccountButtonTapped));
    onTap(_confirm,          @selector(onConfirmButtonTapped));

    /*
     * Content
     */
    self.title              = _RAuthenticationLocalizedString(@"builtinVerificationDialog.title");
    _password.placeholder   = _RAuthenticationLocalizedString(@"builtinVerificationDialog.password(field).placeholder");
    _resetAccount.title     = _RAuthenticationLocalizedString(@"builtinVerificationDialog.passwordRetrieval(button)");
    _showPassword.title     = _RAuthenticationLocalizedString(@"builtinVerificationDialog.showPassword(switch)");
    _confirm.title          = _RAuthenticationLocalizedString(@"builtinVerificationDialog.confirm(button)");

    /*
     * Automation ID's
     */
    _passwordError.accessibilityIdentifier = _RAuthenticationAutomationIds(@"errorMessage");
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.rightBarButtonItem =
    [UIBarButtonItem.alloc initWithTitle:_RAuthenticationLocalizedString(@"builtinVerificationDialog.cancel(button)")
                                   style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(onSkipButtonTapped)];

    // Reset the content
    self.passwordErrorMessage = nil;
    self.password.text        = nil;
    self.confirm.enabled      = YES;
    self.password.enabled     = YES;

    [self updateMessage];
    
    self.navigationController.presentationController.delegate = self;

    [super viewWillAppear:animated];
}

#pragma mark <RVerificationDialog>
@synthesize verificationDialogDelegate = _verificationDialogDelegate;
@synthesize userDisplayName            = _userDisplayName;

- (void)setUserDisplayName:(NSString *)userDisplayName
{
    if (!_RAuthenticationObjectsEqual(_userDisplayName, userDisplayName))
    {
        _userDisplayName = userDisplayName.copy;
        [self updateMessage];
    }
}

- (void)setReason:(NSString *)reason
{
    if (!_RAuthenticationObjectsEqual(_reason, reason))
    {
        _reason = reason.copy;
        [self updateMessage];
    }
}

- (BOOL)handleError:(NSError *)error
{
    NSParameterAssert([error.domain isEqualToString:RVerificationWorkflowTransientErrorDomain]);

    switch (error.code)
    {
        case RVerificationWorkflowTransientErrorCouldNotConnectToServer:
            self.passwordErrorMessage = _RAuthenticationLocalizedString(@"builtinVerificationDialog.error.networkError");
            return YES;

        case RVerificationWorkflowTransientErrorCouldNotAuthenticateUsingBiometrics:
            self.passwordErrorMessage = _RAuthenticationLocalizedString(@"builtinVerificationDialog.error.passwordRequired");
            return YES;

        case RVerificationWorkflowTransientErrorCouldNotAuthenticate:
            self.passwordErrorMessage = _RAuthenticationLocalizedString(@"builtinVerificationDialog.error.passwordInvalid");
            return YES;

        case RVerificationWorkflowTransientErrorNoPermissionToPublishToken:
            self.passwordErrorMessage = _RAuthenticationLocalizedString(@"builtinDialogs.error.noPermissionToPublishToken");
            return YES;

        default:
            NSAssert(NO, @"Unknown error code: %@", @(error.code));
            break;
    }

    return NO;
}

- (void)networkActivityWillStart
{
    self.confirm.enabled  = NO;
    self.password.enabled = NO;
}

- (void)networkActivityDidEnd
{
    self.confirm.enabled  = YES;
    self.password.enabled = YES;
}

#pragma mark <UIAdaptivePresentationControllerDelegate>
- (void)presentationControllerDidDismiss:(UIPresentationController *)presentationController
{
    [self onSkipButtonTapped];
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

#pragma mark <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    if ([textField isEqual:_password])
    {
        [self onConfirmButtonTapped];
    }
    
    return YES;
}

#pragma mark Private Methods
#pragma mark ▪️Actions

- (void)onSkipButtonTapped
{
    [self.view endEditing:YES];
    [self.verificationDialogDelegate verificationDialogWantsToCancel:self];
}

- (void)onShowPasswordCheckboxValueChanged
{
    _password.secureTextEntry = !_showPassword.selected;
    
    // workaround for textfield rendering bug
    if (_password.isFirstResponder)
    {
        [_password resignFirstResponder];
        [_password becomeFirstResponder];
    }
}

- (void)onResetAccountButtonTapped
{
    [self.view endEditing:YES];
    dispatch_async(dispatch_get_main_queue(), self.passwordResetButtonHandler);
}

- (void)onConfirmButtonTapped
{
    [self.view endEditing:YES];

    NSString *password = self.password.text;
    if (!password.length)
    {
        self.passwordErrorMessage = _RAuthenticationLocalizedString(@"builtinVerificationDialog.error.passwordRequired");
    }
    else
    {
        self.passwordErrorMessage = nil;
        [self.verificationDialogDelegate verificationDialog:self
                                 wantsToProceedWithPassword:password];
    }
}

#pragma mark ▪️Displaying Errors
- (void)setPasswordErrorMessage:(NSString *)passwordErrorMessage
{
    if (passwordErrorMessage)
    {
        _passwordError.text = passwordErrorMessage;
        _passwordError.tintColor = _RAuthenticationUIValues.INPUT_FIELD_INVALID_COLOR;
        _password.valid = NO;
    }
    else
    {
        // No error. Show the message that says the password is required.
        _passwordError.text = _RAuthenticationLocalizedString(@"builtinVerificationDialog.error.passwordRequired");
        _passwordError.tintColor = _RAuthenticationUIValues.PRIMARY_TEXT_COLOR;
        _password.valid = !passwordErrorMessage;
    }
}

#pragma mark ▪️Other

- (void)updateMessage
{
    NSAssert(_reason.length, @"RBuiltinVerificationDialog.reason must be set");
    if (_userDisplayName)
    {
        NSString *text = _RAuthenticationLocalizedString(@"builtinVerificationDialog.message");
        text = [text stringByReplacingOccurrencesOfString:@"{FULLNAME}" withString:_userDisplayName];
        text = [text stringByReplacingOccurrencesOfString:@"{REASON}"   withString:_reason];
        _message.text = text;
    }
    else
    {
        _message.text = _reason;
    }
}
@end
