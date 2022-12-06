/*
 * © Rakuten, Inc.
 */
#import "_RAuthenticationButton.h"
#import "_RAuthenticationLabel.h"
#import "_RAuthenticationUIValues.h"
#import "_RAuthenticationUIHelpers.h"

@interface _RAuthenticationButton ()
@property (nonatomic, readonly) _RAuthenticationLabel *label;
@end

@implementation _RAuthenticationButton
#pragma mark Class methods
+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

+ (instancetype)buttonWithType:(_RAuthenticationButtonType)type
{
    _RAuthenticationButton *button = self.new;
    UIColor *borderColor = nil;
    switch (type)
    {
        case _RAuthenticationPrimaryButtonType:
            button.tintColor       = _RAuthenticationUIValues.PRIMARY_BUTTON_TEXT_COLOR;
            button.backgroundColor = _RAuthenticationUIValues.PRIMARY_BUTTON_BACKGROUND_COLOR;
            button.padding         = _RAuthenticationUIValues.PRIMARY_PADDING;
            borderColor            = _RAuthenticationUIValues.PRIMARY_BUTTON_BORDER_COLOR;
            break;

        case _RAuthenticationSecondaryButtonType:
            button.tintColor       = _RAuthenticationUIValues.SECONDARY_BUTTON_TEXT_COLOR;
            button.backgroundColor = _RAuthenticationUIValues.SECONDARY_BUTTON_BACKGROUND_COLOR;
            button.padding         = _RAuthenticationUIValues.PRIMARY_PADDING;
            borderColor            = _RAuthenticationUIValues.SECONDARY_BUTTON_BORDER_COLOR;
            break;

        case _RAuthenticationTernaryButtonType:
            button.tintColor       = _RAuthenticationUIValues.PRIMARY_TEXT_COLOR;
            button.padding         = _RAuthenticationUIValues.PRIMARY_PADDING;
            button.label.fontSize  = _RAuthenticationUIValues.FONT_SIZE_2;
            break;

        default:
            break;
    }

    if (borderColor)
    {
        button.layer.borderColor  = borderColor.CGColor;
        button.layer.borderWidth  = 1;
    }

    return button;
}


#pragma mark Life cycle
- (void)dealloc
{
    [self stopObservingState];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect __unused)frame
{
    if ((self = [super initWithFrame:CGRectZero]))
    {
        self.isAccessibilityElement = YES;
        [self buildInternalViewHierarchy];
        [self startObservingState];
    }
    return self;
}

#pragma mark Accessors
- (NSString *)title
{
    return _label.text;
}

- (void)setTitle:(NSString *)title
{
    _label.text = title;
}

- (UIEdgeInsets)padding
{
    return _label.padding;
}

- (void)setPadding:(UIEdgeInsets)padding
{
    _label.padding = padding;
}

- (void)setHidden:(BOOL)hidden
{
    if (super.hidden != hidden)
    {
        super.hidden = hidden;

        if (_additionalConstraintsWhenVisible.count)
        {
            if (hidden)
            {
                [NSLayoutConstraint deactivateConstraints:_additionalConstraintsWhenVisible];
            }
            else
            {
                [NSLayoutConstraint activateConstraints:_additionalConstraintsWhenVisible];
            }
        }
    }
}

- (void)setAdditionalConstraintsWhenVisible:(NSArray *)additionalConstraintsWhenVisible
{
    if (_additionalConstraintsWhenVisible.count)
    {
        [NSLayoutConstraint deactivateConstraints:_additionalConstraintsWhenVisible];
    }

    _additionalConstraintsWhenVisible = additionalConstraintsWhenVisible.copy;

    if (_additionalConstraintsWhenVisible.count && !self.hidden)
    {
        [NSLayoutConstraint activateConstraints:_additionalConstraintsWhenVisible];
    }
}

#pragma mark State management
+ (NSArray *)observedStates
{
    static NSArray *keyPaths;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyPaths = @[@"enabled", @"highlighted", @"selected"];
    });
    return keyPaths;
}


static void* RAuthenticationButtonKVOContext = &RAuthenticationButtonKVOContext;
- (void)startObservingState
{
    NSArray *observedStates = [self.class observedStates];
    for (id keyPath in observedStates)
    {
        [self addObserver:self
               forKeyPath:keyPath
                  options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                  context:RAuthenticationButtonKVOContext];
    }
}

- (void)stopObservingState
{
    NSArray *observedStates = [self.class observedStates];
    for (id keyPath in observedStates)
    {
        [self removeObserver:self
                  forKeyPath:keyPath
                     context:RAuthenticationButtonKVOContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id __unused)object
                        change:(NSDictionary*)change
                       context:(void *)context
{
    if (context == RAuthenticationButtonKVOContext)
    {
        BOOL newValue  = [change[NSKeyValueChangeNewKey] boolValue];
        if (newValue != [change[NSKeyValueChangeOldKey] boolValue])
        {
            [self applyPaletteForCurrentState];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark View management
- (void)buildInternalViewHierarchy
{
    _label = _RAuthenticationLabel.new;
    _label.isAccessibilityElement = NO;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.numberOfLines = 0;
    _label.lineBreakMode = NSLineBreakByWordWrapping;
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.fontSize      = _RAuthenticationUIValues.FONT_SIZE_0;
    [_label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [_label setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [_label setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];

    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.clipsToBounds      = YES;
    self.tintColor          = _RAuthenticationUIValues.PRIMARY_TEXT_COLOR;
    self.layer.cornerRadius = _RAuthenticationUIValues.PRIMARY_CORNER_RADIUS;

    [self addSubview:_label];
    [self addConstraints:@[MakeConstraint(_label, self,     .attribute  = NSLayoutAttributeLeading),
                           MakeConstraint(_label, self,     .attribute  = NSLayoutAttributeCenterX),
                           MakeConstraint(_label, self,     .attribute  = NSLayoutAttributeTop),
                           MakeConstraint(_label, self,     .attribute  = NSLayoutAttributeCenterY),
                           ]];
}

- (void)applyPaletteForCurrentState
{
    UIControlState state = self.state;
    if (state & UIControlStateDisabled)
    {
        self.alpha = .5;
        self.label.backgroundColor = [UIColor colorWithWhite:0 alpha:.4];
    }
    else if (state & UIControlStateHighlighted)
    {
        /*
         * Highlighted palette is just 80% alpha on the title and 20% darkening on the background
         */
        CGFloat r, g, b, a;
        [self.tintColor getRed:&r green:&g blue:&b alpha:&a];
        a *= .8;
        self.label.tintColor       = [UIColor colorWithRed:r green:g blue:g alpha:a];
        self.label.backgroundColor = [UIColor colorWithWhite:0 alpha:.2];
        self.alpha = 1;
    }
    else
    {
        self.label.tintColor = nil;
        self.label.backgroundColor = UIColor.clearColor;
        self.alpha = 1;
    }
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    [self applyPaletteForCurrentState];
}

#pragma mark Accessibility
- (UIAccessibilityTraits)accessibilityTraits
{
    UIAccessibilityTraits traits = UIAccessibilityTraitButton;
    if (!self.enabled)
    {
        traits |= UIAccessibilityTraitNotEnabled;
    }
    if (self.selected)
    {
        traits |= UIAccessibilityTraitSelected;
    }

    return traits;
}

- (NSString *)accessibilityLabel
{
    return self.label.text;
}
@end

