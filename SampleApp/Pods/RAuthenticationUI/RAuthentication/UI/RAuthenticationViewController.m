/*
 * © Rakuten, Inc.
 */
#import <SafariServices/SafariServices.h>
#import <WebKit/WebKit.h>
#import "RAuthenticationUI.h"
#import "RAuthenticationViewController.h"
#import "_RAuthenticationNavigationController.h"
#import "_RAuthenticationScrollView.h"
#import "_RAuthenticationButton.h"
#import "_RAuthenticationLabel.h"
#import "_RAuthenticationUIValues.h"
#import "_RAuthenticationUIHelpers.h"
#import "_RAuthenticationTracking.h"

@interface RAuthenticationViewController()
@property (nonatomic) NSLayoutConstraint *layoutGuideHeightConstraint;
@property (nonatomic) UIStackView *footerStack;
@property (nonatomic) UIView *headerGuideLastView;
@end

@implementation RAuthenticationViewController
- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *__unused)nibNameOrNil bundle:(NSBundle *__unused)nibBundleOrNil
{
    if ((self = [super initWithNibName:nil bundle:nil]))
    {
        // FIXME: How to forbid subclassing outside of the module?
        // Test self.class against RBuiltinLoginDialog & RBuiltinAccountSelectionDialog?
    }
    return self;
}

- (void)loadView
{
    _RAuthenticationScrollView *container = _RAuthenticationScrollView.new;
    container.backgroundColor  = _RAuthenticationUIValues.PRIMARY_BACKGROUND_COLOR;
    container.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.view = container;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    UIScrollView *scrollView = (UIScrollView *)self.view;
    scrollView.bounces = NO;
    
    // Calculating the height of footer Guide Again.
    // The remaining area visible area
    CGFloat footerGuideHeightConstant = self.view.frame.size.height - (_headerGuideLastView.frame.origin.y + _headerGuideLastView.frame.size.height + _footerStack.frame.size.height + _RAuthenticationUIValues.PRIMARY_SPACING + fabs(scrollView.contentOffset.y));
    _layoutGuideHeightConstraint.constant = MAX(footerGuideHeightConstant, _RAuthenticationUIValues.TERNARY_SPACING);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.title;
    self.navigationItem.backBarButtonItem = [UIBarButtonItem.alloc initWithTitle:@""
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:nil
                                                                          action:nil];
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
#endif
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? UIInterfaceOrientationMaskAllButUpsideDown : UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.view setNeedsUpdateConstraints];
}

- (BOOL)isPortrait
{
    return self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
}

- (void)addContentViews:(UIView *)view, ...
{
    UIView *container = self.view;
    
    va_list args;
    va_start(args, view);
    for (UIView *arg = view; arg; arg = va_arg(args, UIView *))
    {
        [container addSubview:arg];
    }
    va_end(args);
}

- (void)addStandardFooter
{
    BOOL hasPrivacyPolicyButton = [self respondsToSelector:@selector(onPrivacyPolicyButtonTapped)];
    BOOL hasHelpButton          = [self respondsToSelector:@selector(onHelpButtonTapped)];
    
    UIView *container = self.view;
    UIView *lastView  = container.subviews.lastObject;
    _headerGuideLastView = lastView;

    UIView *footerGuide   = UIView.new;
    footerGuide.translatesAutoresizingMaskIntoConstraints = NO;
    footerGuide.isAccessibilityElement = NO;
    [self.view addSubview:footerGuide];

    MakeConstraint(lastView, footerGuide,
                   .attribute = NSLayoutAttributeBottom,
                   .from = NSLayoutAttributeTop).active = YES;
    
    _footerStack = UIStackView.new;
    _footerStack.axis = UILayoutConstraintAxisVertical;
    _footerStack.alignment = UIStackViewAlignmentCenter;
    _footerStack.distribution = UIStackViewDistributionFill;
    _footerStack.spacing = _RAuthenticationUIValues.TERNARY_SPACING;
    _footerStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_footerStack];
    
    [NSLayoutConstraint activateConstraints:
     @[
       MakeConstraint(_footerStack, footerGuide,
                      .attribute = NSLayoutAttributeTop,
                      .from      = NSLayoutAttributeBottom),
       MakeConstraint(_footerStack, container,
                      .attribute = NSLayoutAttributeLeading,
                      .relation  = NSLayoutRelationGreaterThanOrEqual,
                      .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
       MakeConstraint(_footerStack, container,
                      .attribute = NSLayoutAttributeCenterX),
       MakeConstraint(container, _footerStack,
                      .attribute = NSLayoutAttributeBottom,
                      .relation  = NSLayoutRelationGreaterThanOrEqual,
                      .constant  = _RAuthenticationUIValues.PRIMARY_SPACING),
       ]];
    
    if (hasPrivacyPolicyButton || hasHelpButton)
    {
        UIStackView *linkStack = UIStackView.new;
        linkStack.axis = UILayoutConstraintAxisHorizontal;
        linkStack.alignment = UIStackViewAlignmentCenter;
        linkStack.distribution = UIStackViewDistributionFill;
        linkStack.translatesAutoresizingMaskIntoConstraints = NO;
        [_footerStack addArrangedSubview:linkStack];

        MakeConstraint(linkStack, _footerStack, .attribute = NSLayoutAttributeWidth).active = YES;

        if (hasPrivacyPolicyButton)
        {
            _RAuthenticationButton *privacyPolicy = [_RAuthenticationButton buttonWithType:_RAuthenticationTernaryButtonType];
            [linkStack addArrangedSubview:privacyPolicy];
            [privacyPolicy addTarget:self action:@selector(_onPrivacyPolicyButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            privacyPolicy.title = _RAuthenticationLocalizedString(@"builtinDialogs.privacyPolicy(button)");
            privacyPolicy.accessibilityIdentifier = _RAuthenticationAutomationIds(@"privacyPolicy");
        }
        
        if (hasHelpButton)
        {
            _RAuthenticationButton *help = [_RAuthenticationButton buttonWithType:_RAuthenticationTernaryButtonType];
            [linkStack addArrangedSubview:help];
            [help addTarget:self action:@selector(_onHelpButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            help.title = _RAuthenticationLocalizedString(@"builtinDialogs.help(button)");
            help.accessibilityIdentifier = _RAuthenticationAutomationIds(@"help");
        }
    }
    
    _RAuthenticationLabel *copyright = _RAuthenticationLabel.new;
    copyright.tintColor = _RAuthenticationUIValues.COPYRIGHT_COLOR;
    copyright.text = _RAuthenticationLocalizedString(@"builtinDialogs.copyrightFooter");
    copyright.accessibilityIdentifier = _RAuthenticationAutomationIds(@"copyright");
    [_footerStack addArrangedSubview:copyright];
    
    // Calculate Height Constraint.
    _layoutGuideHeightConstraint = MakeConstraint(footerGuide, nil,
                                                  .attribute = NSLayoutAttributeHeight,
                                                  .constant = _RAuthenticationUIValues.TERNARY_SPACING);
    _layoutGuideHeightConstraint.active = YES;
}

- (void)openURL:(NSURL *)url title:(NSString *)title
{
    NSParameterAssert(url);
    NSParameterAssert(title);
    
    SFSafariViewController *web;
    
    if (@available(iOS 11, *)) {
        SFSafariViewControllerConfiguration *configuration = SFSafariViewControllerConfiguration.new;
        configuration.entersReaderIfAvailable = NO;
        configuration.barCollapsingEnabled = NO;
        
        web = [SFSafariViewController.alloc initWithURL:url configuration:configuration];
        
    } else {
        web = [SFSafariViewController.alloc initWithURL:url];
    }
    
    if (@available(iOS 10, *)) {
        web.preferredControlTintColor = _RAuthenticationUIValues.NAVIGATION_BAR_LINK_COLOR;
        
        if (@available(iOS 11, *)) {
            web.dismissButtonStyle = SFSafariViewControllerDismissButtonStyleClose;
        }
    }
    
    web.title = title;
    web.modalPresentationStyle = self.navigationController.modalPresentationStyle;
    [self.navigationController presentViewController:web animated:YES completion:nil];
    if (web.modalPresentationStyle == UIModalPresentationPopover) {
        UIPopoverPresentationController *popControllerParent = [self.navigationController popoverPresentationController];
        UIPopoverPresentationController *popController = [web popoverPresentationController];
        popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        popController.barButtonItem = popControllerParent.barButtonItem;
        popController.sourceView = popControllerParent.sourceView;
    }
}

- (void)openURLWithLocalizedKey:(NSString *)key titleKey:(NSString *)titleKey
{
    NSURL *url = [NSURL URLWithString:_RAuthenticationLocalizedString(key)];
    NSAssert(url, @"Invalid url for key \"authentication.%@\"!", key);
    [self openURL:(id)url title:_RAuthenticationLocalizedString(titleKey)];
}

- (void)openStandardPrivacyPolicyPage
{
    [self openURLWithLocalizedKey:@"builtinDialogs.privacyPolicyURL" titleKey:@"builtinDialogs.privacyPolicyPage(title)"];
}

- (void)openStandardHelpPage
{
    [self openURLWithLocalizedKey:@"builtinDialogs.helpURL" titleKey:@"builtinDialogs.helpPage(title)"];
}

#pragma mark ▪️Actions

- (void)_onPrivacyPolicyButtonTapped
{
    [_RAuthenticationTracking broadcastPrivacyPolicyTappedWithClass:[self class]];
    [self onPrivacyPolicyButtonTapped];
}

- (void)_onHelpButtonTapped
{
    [_RAuthenticationTracking broadcastHelpTappedWithClass:[self class]];
    [self onHelpButtonTapped];
}

@end
