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
#import "_RAuthenticationTracking.h"
#import "_RAuthenticationUIHelpers.h"
@import MobileCoreServices;

#pragma mark Helper Functions

static BOOL isPasswordExtensionAvailable()
{
    if ([NSExtensionItem class]) {
        NSArray*  schemes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"LSApplicationQueriesSchemes"];
        if( schemes && [schemes isKindOfClass:NSArray.class]) {
            for ( NSString* scheme in schemes) {
                if([scheme isEqualToString:@"org-appextension-feature-password-management"]) {
                    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"org-appextension-feature-password-management://"]];
                }
            }
        }
    }
    return NO;
}

static void removeSpaceFromTextField(UITextField *textField)
{
    NSString *original = textField.text;
    NSString *filtered = [[original componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] componentsJoinedByString:@""];
    if (![filtered isEqualToString:original])
    {
        textField.text = filtered;
    }
}

#pragma mark RBuiltinLoginDialog

@interface RBuiltinLoginDialog()<UITextFieldDelegate, UIAdaptivePresentationControllerDelegate>
@property (nonatomic) BOOL isShowingPasswordExtension;

@property (nonatomic) UIView                     *logo;

@property (nonatomic) _RAuthenticationTextField  *username;
@property (nonatomic) _RAuthenticationLabel      *usernameError;

@property (nonatomic) _RAuthenticationTextField  *password;
@property (nonatomic) _RAuthenticationLabel      *passwordError;

@property (nonatomic) _RAuthenticationCheckbox   *showPassword;

@property (nonatomic) _RAuthenticationButton     *resetAccount;

@property (nonatomic) _RAuthenticationButton     *login;
@property (nonatomic) _RAuthenticationLabel      *privacyPolicy;
@property (nonatomic) _RAuthenticationButton     *createNewAccount;
@property (nonatomic) _RAuthenticationLabel      *nonsense;

@property (nonatomic, copy) NSString *presetUsername;
@end

@implementation RBuiltinLoginDialog
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
     _logo             = _RAuthenticationCreateLogoView(&logoSize),
     _usernameError    = _RAuthenticationLabel.new,
     _username         = _RAuthenticationTextField.new,
     _passwordError    = _RAuthenticationLabel.new,
     _password         = _RAuthenticationTextField.new,
     _showPassword     = _RAuthenticationCheckbox.new,
     _resetAccount     = [_RAuthenticationButton buttonWithType:_RAuthenticationTernaryButtonType],
     _login            = [_RAuthenticationButton buttonWithType:_RAuthenticationPrimaryButtonType],
     _privacyPolicy    = _RAuthenticationLabel.new,
     _createNewAccount = [_RAuthenticationButton buttonWithType:_RAuthenticationSecondaryButtonType],
     _nonsense         = _RAuthenticationLabel.new,
     nil];

    _logo.translatesAutoresizingMaskIntoConstraints = NO;
    [_logo setContentHuggingPriority:UILayoutPriorityDefaultLow + 2 forAxis:UILayoutConstraintAxisHorizontal];
    [_logo setContentHuggingPriority:UILayoutPriorityDefaultLow + 2 forAxis:UILayoutConstraintAxisVertical];
    [_logo setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_logo setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    _usernameError.hidden = YES;
    _usernameError.tintColor = _RAuthenticationUIValues.INPUT_FIELD_INVALID_COLOR;

    _username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _username.autocorrectionType     = UITextAutocorrectionTypeNo;
    _username.clearButtonMode        = UITextFieldViewModeWhileEditing;
    _username.keyboardType           = UIKeyboardTypeEmailAddress;
    _username.returnKeyType          = UIReturnKeyNext;

    _passwordError.hidden = YES;
    _passwordError.tintColor = _RAuthenticationUIValues.INPUT_FIELD_INVALID_COLOR;

    _password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _password.autocorrectionType     = UITextAutocorrectionTypeNo;
    _password.spellCheckingType      = UITextSpellCheckingTypeNo;
    _password.keyboardType           = UIKeyboardTypeASCIICapable;
    _password.secureTextEntry        = !_showPassword.selected;
    _password.clearButtonMode        = UITextFieldViewModeWhileEditing;
    _password.returnKeyType          = UIReturnKeyGo;

    // Add password extension button, only if password app extension available.
    if (isPasswordExtensionAvailable())
    {
        UIButton *passwordExtension = UIButton.new;
        UIImage *passwordExtensionIcon = [UIImage imageNamed:@"RAuthenticationPasswordExtension"];
        if (passwordExtensionIcon) {
            [passwordExtension setImage:passwordExtensionIcon forState:UIControlStateNormal];
        }
        else
        {
            [passwordExtension setTitle:_RAuthenticationLocalizedString(@"builtinLoginDialog.password(field).passwordmanager") forState:UIControlStateNormal];
            [passwordExtension setTitleColor:_RAuthenticationUIValues.INPUT_FIELD_PLACEHOLDER_COLOR forState:UIControlStateNormal];
        }
        [passwordExtension sizeToFit];
        [passwordExtension addTarget:self action:@selector(onPasswordExtensionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _password.rightView = passwordExtension;
        _password.rightViewMode = UITextFieldViewModeUnlessEditing;
    }

    _showPassword.fontSize  = _RAuthenticationUIValues.FONT_SIZE_2;
    
    _privacyPolicy.fontSize      = _RAuthenticationUIValues.FONT_SIZE_2;
    _privacyPolicy.textAlignment = NSTextAlignmentCenter;

    _nonsense.fontSize      = _RAuthenticationUIValues.FONT_SIZE_3;
    _nonsense.textAlignment = NSTextAlignmentCenter;

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
     // Username
     MakeConstraint(_username, _logo,
                    .attribute = NSLayoutAttributeTop,
                    .from      = NSLayoutAttributeBottom,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING * 2,
                    .priority  = UILayoutPriorityDefaultHigh),
     MakeConstraint(_username, container,
                    .attribute = NSLayoutAttributeLeading,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
     MakeConstraint(_username, container,
                    .attribute = NSLayoutAttributeCenterX),
     // Password
     MakeConstraint(_password, _username,
                    .attribute = NSLayoutAttributeTop,
                    .from      = NSLayoutAttributeBottom,
                    .constant  = _RAuthenticationUIValues.TERNARY_SPACING,
                    .priority  = UILayoutPriorityDefaultHigh),
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
     // Reset Account
     MakeConstraint(_resetAccount, _showPassword,
                    .attribute = NSLayoutAttributeTop,
                    .from      = NSLayoutAttributeBottom,
                    .constant  = _RAuthenticationUIValues.SECONDARY_SPACING),
     MakeConstraint(_resetAccount, container,
                    .attribute = NSLayoutAttributeLeading,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
     MakeConstraint(_resetAccount, container,
                    .attribute = NSLayoutAttributeCenterX),
     // Login
     MakeConstraint(_login, _resetAccount,
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
     // Create new account
     MakeConstraint(_createNewAccount, _login,
                    .attribute = NSLayoutAttributeTop,
                    .from      = NSLayoutAttributeBottom,
                    .constant  = _RAuthenticationUIValues.SECONDARY_SPACING,
                    .priority  = UILayoutPriorityDefaultHigh),
     MakeConstraint(_createNewAccount, _privacyPolicy,
                    .attribute = NSLayoutAttributeTop,
                    .from      = NSLayoutAttributeBottom,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
     MakeConstraint(_createNewAccount, container,
                    .attribute = NSLayoutAttributeLeading,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
     MakeConstraint(_createNewAccount, container,
                    .attribute = NSLayoutAttributeCenterX),
     // Nonsense
     MakeConstraint(_nonsense, _createNewAccount,
                    .attribute = NSLayoutAttributeTop,
                    .from      = NSLayoutAttributeBottom,
                    .constant  = _RAuthenticationUIValues.SECONDARY_SPACING),
     MakeConstraint(_nonsense, container,
                    .attribute = NSLayoutAttributeLeading,
                    .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
     MakeConstraint(_nonsense, container,
                    .attribute = NSLayoutAttributeCenterX),
     ]];

    [self addStandardFooter];

    _usernameError.additionalConstraintsWhenVisible =
    @[MakeConstraint(_usernameError, _logo,
                     .attribute = NSLayoutAttributeTop,
                     .from      = NSLayoutAttributeBottom,
                     .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
      MakeConstraint(_usernameError, container,
                     .attribute = NSLayoutAttributeLeading,
                     .constant = _RAuthenticationUIValues.PRIMARY_SPACING),
      MakeConstraint(_usernameError, container,
                     .attribute = NSLayoutAttributeCenterX),
      MakeConstraint(_username, _usernameError,
                     .attribute = NSLayoutAttributeTop,
                     .from      = NSLayoutAttributeBottom,
                     .constant  = _RAuthenticationUIValues.SECONDARY_SPACING)
      ];

    _passwordError.additionalConstraintsWhenVisible =
    @[MakeConstraint(_passwordError, _username,
                     .attribute = NSLayoutAttributeTop,
                     .from      = NSLayoutAttributeBottom,
                     .constant  = _RAuthenticationUIValues.SECONDARY_SPACING),
      MakeConstraint(_passwordError, container,
                     .attribute = NSLayoutAttributeLeading,
                     .constant = _RAuthenticationUIValues.PRIMARY_SPACING),
      MakeConstraint(_passwordError, container,
                     .attribute = NSLayoutAttributeCenterX),
      MakeConstraint(_password, _passwordError,
                     .attribute = NSLayoutAttributeTop,
                     .from      = NSLayoutAttributeBottom,
                     .constant  = _RAuthenticationUIValues.SECONDARY_SPACING)
      ];

    /*
     * Logic
     */
    _username.delegate = self;
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(textFieldValueChanged:)
                                               name:UITextFieldTextDidChangeNotification
                                             object:_username];

    _password.delegate = self;

    void (^onTap)(UIControl *, SEL) = ^(UIControl *control, SEL selector)
    {
        [control addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    };
    onTap(_showPassword,     @selector(onShowPasswordCheckboxValueChanged));
    onTap(_resetAccount,     @selector(onResetAccountButtonTapped));
    onTap(_login,            @selector(onLoginButtonTapped));
    onTap(_createNewAccount, @selector(onCreateNewAccountButtonTapped));

    /*
     * Content
     */
    self.title              = _RAuthenticationLocalizedString(@"builtinLoginDialog.title");
    _username.placeholder   = _RAuthenticationLocalizedString(@"builtinLoginDialog.username(field).placeholder");
    _password.placeholder   = _RAuthenticationLocalizedString(@"builtinLoginDialog.password(field).placeholder");
    _resetAccount.title     = _RAuthenticationLocalizedString(@"builtinLoginDialog.passwordRetrieval(button)");
    _showPassword.title     = _RAuthenticationLocalizedString(@"builtinLoginDialog.showPassword(switch)");
    _login.title            = _RAuthenticationLocalizedString(@"builtinLoginDialog.login(button)");
    _privacyPolicy.text     = _RAuthenticationLocalizedString(@"builtinDialogs.privacyPolicyAcknowledgement(date)");
    _createNewAccount.title = _RAuthenticationLocalizedString(@"builtinLoginDialog.newUserRegistration(button)");
    _nonsense.text          = _RAuthenticationLocalizedString(@"builtinLoginDialog.message");

    /*
     * Testability
     */
    _logo.accessibilityIdentifier               = _RAuthenticationAutomationIds(@"logo");
    _username.accessibilityIdentifier           = _RAuthenticationAutomationIds(@"username");
    _password.accessibilityIdentifier           = _RAuthenticationAutomationIds(@"password");
    _resetAccount.accessibilityIdentifier       = _RAuthenticationAutomationIds(@"forgetPasswordLink");
    _showPassword.accessibilityIdentifier       = _RAuthenticationAutomationIds(@"showPassword");
    _login.accessibilityIdentifier              = _RAuthenticationAutomationIds(@"login");
    _privacyPolicy.accessibilityIdentifier      = _RAuthenticationAutomationIds(@"privacyPolicy");
    _createNewAccount.accessibilityIdentifier   = _RAuthenticationAutomationIds(@"createNewAccount");
    _nonsense.accessibilityIdentifier           = _RAuthenticationAutomationIds(@"earnSuperPoints");
    _usernameError.accessibilityIdentifier      = _RAuthenticationAutomationIds(@"errorUsername");
    _passwordError.accessibilityIdentifier      = _RAuthenticationAutomationIds(@"errorPassword");
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

    // Reset the content
    [self dismissErrorMessage];
    _username.text  = _presetUsername;
    _password.text  = nil;
    _presetUsername = nil;
    
    // Request shared web credential
    if (!_isShowingPasswordExtension) {
        SecRequestSharedWebCredential(NULL, NULL, ^(CFArrayRef  _Nullable credentials, CFErrorRef  _Nullable error) {
            if (error != NULL) {
                _RAuthenticationLog(@"Failed to request shared web credential: %@", error);
                return;
            }
            if (CFArrayGetCount(credentials) > 0)
            {
                NSDictionary *value = CFBridgingRelease(CFArrayGetValueAtIndex(credentials, 0));
                NSString *username = value[(__bridge id)kSecAttrAccount];
                NSString *password = value[(__bridge id)kSecSharedPassword];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.username.text  = username;
                    self.password.text  = password;
                    removeSpaceFromTextField(self.username);
                    [_RAuthenticationTracking broadcastLoginCredentialFound:@"icloud"];
                });
            }
        });
    }

    self.navigationController.presentationController.delegate = self;
    
    [super viewWillAppear:animated];
}

#pragma mark <RLoginDialog>
@synthesize loginDialogDelegate = _loginDialogDelegate;

- (void)setLoginDialogDelegate:(id<RLoginDialogDelegate>)loginDialogDelegate
{
    _loginDialogDelegate = loginDialogDelegate;
}

- (BOOL)handleError:(NSError *)error
{
    NSString *domain      = error.domain,
             *description = error.localizedDescription,
             *reason      = error.userInfo[NSLocalizedFailureReasonErrorKey];

    if ([domain isEqualToString:RWCAppEngineResponseParserErrorDomain])
    {
        BOOL credentialsDontMatch = [description isEqualToString:@"invalid_grant"]   && [reason isEqualToString:@"username/password is wrong"];
        BOOL invalidValues        = [description isEqualToString:@"invalid_request"] && [reason isEqualToString:@"required parameter is wrong"];

        if (credentialsDontMatch || invalidValues)
        {
            [self showErrorMessage:_RAuthenticationLocalizedString(@"builtinLoginDialog.error.username_password_invalid") forTextField:nil];
            return YES;
        }

        BOOL isBlacklisted        = [description isEqualToString:@"invalid_client"]  && [reason isEqualToString:@"client has no permission to publish token"];
        if (isBlacklisted)
        {
            [self showErrorMessage:_RAuthenticationLocalizedString(@"builtinDialogs.error.noPermissionToPublishToken") forTextField:nil];
            return YES;
        }
    }
    else if ([error.domain isEqualToString:NSURLErrorDomain])
    {
        [self showErrorMessage:error.localizedDescription forTextField:nil];
        return YES;
    }

    return NO;
}

- (void)populateWithUsername:(NSString *)username
{
    if (!self.view.window || self.view.window.isHidden)
    {
        // If the view is not attached to a visible window yet, -viewWillAppear will wipe its state clean
        // so we need to cache the value until then
        _presetUsername = username;
    }
    else
    {
        // Otherwise we just set the field
        self.username.text = username;
    }
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

#pragma mark <UITextFieldDelegate>

- (void)textFieldValueChanged:(NSNotification *)notification
{
    /*
     * The username cannot contain any space.
     * This is for buffered input methods.
     */
    // Replace space before user selected candidate word will break Chinese IME.
    // See https://jira.rakuten-it.com/jira/browse/MEMSDK-85
    // If there is no marked text, the value of the markedTextRange is nil.
    // Marked text is provisionally inserted text that requires user confirmation;
    // it occurs in multistage text input.
    UITextField *textField = (UITextField *)notification.object;
    if (textField == _username && textField.markedTextRange == nil) {
        removeSpaceFromTextField(textField);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange __unused)range replacementString:(NSString *)string
{
    /*
     * The username cannot contain any space.
     * This is for direct input methods.
     */
    if (textField == _username)
    {
        return [string rangeOfCharacterFromSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length == 0;
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    if ([textField isEqual:_username])
    {
        [_password becomeFirstResponder];
    }
    else if ([textField isEqual:_password])
    {
        [self onLoginButtonTapped];
    }

    return YES;
}

#pragma mark ▪️Actions

- (void)onSkipButtonTapped
{
    [self.view endEditing:YES];

    id<RLoginDialogDelegate> delegate = self.loginDialogDelegate;
    if ([delegate respondsToSelector:@selector(loginDialogWantsToSkipSignIn:)])
    {
        [delegate loginDialogWantsToSkipSignIn:self];
    }
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
    [_RAuthenticationTracking broadcastForgotPasswordTappedWithClass:[self class]];
    
    [self.view endEditing:YES];

    id<RLoginDialogDelegate> delegate = self.loginDialogDelegate;
    if ([delegate respondsToSelector:@selector(loginDialogWantsToRetrieveForgottenPassword:)])
    {
        [delegate loginDialogWantsToRetrieveForgottenPassword:self];
    }
}

- (void)onPasswordExtensionButtonTapped
{
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithItem:@{ @"url_string": @"https://member.id.rakuten.co.jp" } typeIdentifier:@"org.appextension.find-login-action"];
    NSExtensionItem *extensionItem = NSExtensionItem.new;
    extensionItem.attachments = @[ itemProvider ];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[ extensionItem ]  applicationActivities:nil];
    activityViewController.popoverPresentationController.sourceView = _password.rightView;

    _isShowingPasswordExtension = YES;
    activityViewController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        self.isShowingPasswordExtension = NO;
        if (!returnedItems.firstObject || !((NSExtensionItem *)returnedItems.firstObject).attachments.firstObject) {
            if (activityError) _RAuthenticationLog(@"Failed to findLoginForURLString: %@", activityError);
            return;
        }
        NSItemProvider *itemProvider = ((NSExtensionItem *)returnedItems.firstObject).attachments.firstObject;
        if (![itemProvider hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypePropertyList]) {
            _RAuthenticationLog(@"Unexpected data returned by App Extension: extension item attachment does not conform to kUTTypePropertyList type identifier");
            return;
        }
        [itemProvider loadItemForTypeIdentifier:(__bridge NSString *)kUTTypePropertyList options:nil completionHandler:^(NSDictionary *itemDictionary, NSError *itemProviderError) {
            if (itemDictionary) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.username.text = itemDictionary[@"username"];
                    self.password.text = itemDictionary[@"password"];
                    removeSpaceFromTextField(self.username);
                    [_RAuthenticationTracking broadcastLoginCredentialFound:@"password-manager"];
                });
            }
            else
            {
                _RAuthenticationLog(@"Failed to loadItemForTypeIdentifier: %@", itemProviderError);
                return;
            }
        }];
    };
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)onLoginButtonTapped
{
    [_RAuthenticationTracking setLoginMethod:_RAuthenticationLoginMethodManualPassword];

    [self.view endEditing:YES];

    NSString    *errorString      = nil;
    UITextField *limitToTextField = nil;

    if (!_username.text.length && !_password.text.length)
    {
        errorString = @"builtinLoginDialog.error.username_password_required";
    }
    else if (!_username.text.length)
    {
        errorString    = @"builtinLoginDialog.error.username_required";
        limitToTextField = _username;
    }
    else if (!_password.text.length)
    {
        errorString    = @"builtinLoginDialog.error.password_required";
        limitToTextField = _password;
    }

    if (errorString)
    {
        [self showErrorMessage:_RAuthenticationLocalizedString(errorString) forTextField:limitToTextField];
    }
    else
    {
        [self dismissErrorMessage];

        id<RLoginDialogDelegate> delegate = self.loginDialogDelegate;
        NSString *username = self.username.text,
                 *password = self.password.text;
        [delegate loginDialog:self wantsToSignInWithUsername:username password:password];
    }
}

- (IBAction)onCreateNewAccountButtonTapped
{
    [_RAuthenticationTracking broadcastCreateAccountTappedWithClass:[self class]];
    
    [self.view endEditing:YES];

    id<RLoginDialogDelegate> delegate = self.loginDialogDelegate;
    if ([delegate respondsToSelector:@selector(loginDialogWantsToCreateNewAccount:)])
    {
        [delegate loginDialogWantsToCreateNewAccount:self];
    }
}

#pragma mark ▪️Displaying Errors
- (void)showErrorMessage:(NSString *)message forTextField:(UITextField *)textField
{
    [self dismissErrorMessage];

    if (!message.length)
    {
        return;
    }

    UILabel *label = _usernameError;

    if (textField == _password)
    {
        _password.valid = NO;
        label = _passwordError;
    }
    else
    {
        _username.valid = NO;
        if (!textField)
        {
            _password.valid = NO;
        }
    }
    label.accessibilityIdentifier = _RAuthenticationAutomationIds(@"errorMessage");
    label.text = message;
    label.hidden = NO;
}

- (void)dismissErrorMessage
{
    _usernameError.text = nil;
    _passwordError.text = nil;
    _usernameError.hidden = YES;
    _passwordError.hidden = YES;
    _username.valid = YES;
    _password.valid = YES;
}

@end
