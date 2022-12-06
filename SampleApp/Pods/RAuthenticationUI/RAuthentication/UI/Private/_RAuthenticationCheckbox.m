/*
 * © Rakuten, Inc.
 */
#import "_RAuthenticationCheckbox.h"
#import "_RAuthenticationUIValues.h"
#import "_RAuthenticationUIHelpers.h"

#pragma mark - _RAuthenticationCheckbox.Check
@interface RAuthenticationCheckbox__Check : UIView
{
    CGFloat          _lineWidth;
    CGMutablePathRef _path;
}
@property (nonatomic) BOOL checked;
@property (nonatomic) UIFont *font;
@end

@implementation RAuthenticationCheckbox__Check
#pragma mark Class methods
+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

#pragma mark Accessors
- (void)setChecked:(BOOL)checked
{
    if (_checked != checked)
    {
        _checked = checked;
        [self setNeedsDisplay];
    }
}

- (void)setFont:(UIFont *)font
{
    if (![font isEqual:_font])
    {
        _font = font;

        const CGFloat
        dimension = font.lineHeight,
        capHeight = font.capHeight,
        descender = font.descender,
        unit      = capHeight / 32., // tick mark is designed in a 32x32 canvas
        baseline  = dimension + descender,
        center    = .5 * dimension;

        if (_path) CGPathRelease(_path);
        _path = CGPathCreateMutable();

        CGPathMoveToPoint(_path,    0, center - 13. * unit, baseline - 12. * unit);
        CGPathAddLineToPoint(_path, 0, center -  6. * unit, baseline - 5.  * unit);
        CGPathAddLineToPoint(_path, 0, center + 14. * unit, baseline - 27. * unit);

        const BOOL bold = font.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold;
        _lineWidth = (bold ? 9 : 7) * unit;

        [self invalidateIntrinsicContentSize];
    }
}

#pragma mark Life cycle
- (void)dealloc
{
    if (_path) CGPathRelease(_path);
    _path = NULL;
}

- (instancetype)initWithFrame:(CGRect __unused)frame {
    if ((self = [super initWithFrame:CGRectZero]))
    {
        self.opaque = NO;
        self.userInteractionEnabled = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.isAccessibilityElement = NO;
        if (_RAuthenticationUIValues.INPUT_FIELD_BORDER_COLOR)
        {
            self.layer.borderColor = _RAuthenticationUIValues.INPUT_FIELD_BORDER_COLOR.CGColor;
            self.layer.borderWidth = 1;
        }
    }
    return self;
}

#pragma mark UIView
- (CGSize)intrinsicContentSize
{
    const CGFloat dimension = _font.lineHeight;
    return CGSizeMake(dimension, dimension);
}

- (CGSize)sizeThatFits:(CGSize __unused)size
{
    return [self intrinsicContentSize];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    // Clear rect
    CGContextClearRect(context, rect);

    // Fill with background color
    UIColor *backgroundColor = _RAuthenticationUIValues.INPUT_FIELD_BACKGROUND_COLOR;
    if (backgroundColor)
    {
        [backgroundColor setFill];
        CGContextFillRect(context, rect);
    }

    // Draw check if selected
    _RAuthenticationCheckbox *checkbox = (id)self.superview;
    if (checkbox.selected)
    {
        UIColor *checkColor = _RAuthenticationUIValues.INPUT_FIELD_ACCESSORY_COLOR ?: self.tintColor;
        [checkColor setStroke];

        CGContextSetLineWidth(context, _lineWidth);
        CGContextSetLineCap(context, kCGLineCapSquare);
        CGContextSetLineJoin(context, kCGLineJoinMiter);
        CGContextAddPath(context, _path);
        CGContextDrawPath(context, kCGPathStroke);
    }

    CGContextRestoreGState(context);
}
@end


#pragma mark - _RAuthenticationCheckbox

@interface _RAuthenticationCheckbox()
@property (nonatomic) UILabel                        *labelView;
@property (nonatomic) RAuthenticationCheckbox__Check *checkView;
@end


@implementation _RAuthenticationCheckbox
#pragma mark Class methods
+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

#pragma mark Accessors
- (void)setTitle:(NSString *)title
{
    _title = title;
    _labelView.text = title;
}

- (void)setSelected:(BOOL)selected
{
    if (self.selected != selected)
    {
        super.selected = selected;
        _checkView.checked = selected;
    }
}

- (void)setFontSize:(CGFloat)fontSize
{
    if (_fontSize != fontSize)
    {
        _fontSize = fontSize;
        [self resetFont];
    }
}

#pragma mark Life cycle
- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect __unused)frame
{
    if ((self = [super initWithFrame:CGRectZero]))
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.isAccessibilityElement = YES;

        [self addSubview:(_checkView = RAuthenticationCheckbox__Check.new)];
        [_checkView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_checkView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [_checkView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_checkView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

        [self addSubview:(_labelView = UILabel.new)];
        _labelView.isAccessibilityElement = NO;
        _labelView.text = @"";
        _labelView.textAlignment = NSTextAlignmentJustified;
        _labelView.numberOfLines = 0;
        _labelView.lineBreakMode = NSLineBreakByWordWrapping;
        _labelView.translatesAutoresizingMaskIntoConstraints = NO;
        [_labelView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_labelView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [_labelView setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [_labelView setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];

        [self addConstraints:
         @[MakeConstraint(_checkView, self,
                          .attribute  = NSLayoutAttributeLeading),
           MakeConstraint(_checkView, self,
                          .attribute  = NSLayoutAttributeTop),
           MakeConstraint(_labelView, _checkView,
                          .attribute  = NSLayoutAttributeLeading,
                          .from       = NSLayoutAttributeTrailing,
                          .constant   = _RAuthenticationUIValues.TERNARY_SPACING),
           MakeConstraint(_labelView, self,
                          .attribute  = NSLayoutAttributeTrailing),
           MakeConstraint(_labelView, self,
                          .attribute  = NSLayoutAttributeTop),
           MakeConstraint(_labelView, self,
                          .attribute  = NSLayoutAttributeBottom),
           ]];

        self.fontSize = _RAuthenticationUIValues.FONT_SIZE_1;

        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(resetFont)
                                                   name:UIContentSizeCategoryDidChangeNotification
                                                 object:nil];


        [self addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

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
    return _labelView.text;
}

- (void)resetFont
{
    UIFont *font = _RAuthenticationDynamicFont([UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody], _fontSize);
    _labelView.font = font;
    _checkView.font = font;

    [self setNeedsLayout];
    [self setNeedsUpdateConstraints];
}

- (void)tapped
{
    self.selected = !self.selected;
}
@end
