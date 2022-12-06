/*
 * © Rakuten, Inc.
 */
#import "_RAuthenticationTextField.h"
#import "_RAuthenticationUIValues.h"
#import "_RAuthenticationUIHelpers.h"

@implementation _RAuthenticationTextField
+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect __unused)frame
{
    if ((self = [super initWithFrame:CGRectZero]))
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.tintColor = _RAuthenticationUIValues.INPUT_FIELD_ACCESSORY_COLOR;
        CALayer *layer = self.layer;
        layer.cornerRadius = _RAuthenticationUIValues.PRIMARY_CORNER_RADIUS;
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(resetFont)
                                                   name:UIContentSizeCategoryDidChangeNotification
                                                 object:nil];
        [self resetFont];
        self.valid = YES;
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, _RAuthenticationUIValues.PRIMARY_PADDING)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, _RAuthenticationUIValues.PRIMARY_PADDING)];
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    return [super rightViewRectForBounds:UIEdgeInsetsInsetRect(bounds, _RAuthenticationUIValues.PRIMARY_PADDING)];
}

- (void)setValid:(BOOL)valid
{
    _valid = valid;

    UIColor *borderColor = valid
    ? _RAuthenticationUIValues.INPUT_FIELD_BORDER_COLOR
    : _RAuthenticationUIValues.INPUT_FIELD_INVALID_COLOR;

    CALayer *layer = self.layer;
    if (borderColor)
    {
        layer.borderColor = borderColor.CGColor;
        layer.borderWidth = 1;
    }
    else
    {
        layer.borderWidth = 0;
    }

    [self setNeedsDisplay];
}

- (void)resetFont
{
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    self.font = _RAuthenticationDynamicFont(fontDescriptor, _RAuthenticationUIValues.FONT_SIZE_0);

    [self setNeedsLayout];
    [self setNeedsUpdateConstraints];
}
@end
