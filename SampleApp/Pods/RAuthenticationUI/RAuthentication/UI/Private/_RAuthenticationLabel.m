/*
 * © Rakuten, Inc.
 */
#import "_RAuthenticationLabel.h"
#import "_RAuthenticationUIValues.h"
#import "_RAuthenticationUIHelpers.h"


@interface _RAuthenticationLabel ()
@property (nonatomic) NSString *markup;
@end

@implementation _RAuthenticationLabel
#pragma mark Class methods
+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
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
        self.clipsToBounds = NO;
        self.contentMode = UIViewContentModeLeft;
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.numberOfLines = 0;
        self.tintColor = _RAuthenticationUIValues.PRIMARY_TEXT_COLOR;
        self.fontSize = _RAuthenticationUIValues.FONT_SIZE_1;

        [self setContentHuggingPriority:UILayoutPriorityDefaultLow + 1 forAxis:UILayoutConstraintAxisHorizontal];
        [self setContentHuggingPriority:UILayoutPriorityDefaultLow + 1 forAxis:UILayoutConstraintAxisVertical];
        [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(resetAttributes)
                                                   name:UIContentSizeCategoryDidChangeNotification
                                                 object:nil];
    }
    return self;
}

#pragma mark Padding support
- (CGSize)intrinsicContentSize
{
    if (!self.text.length)
    {
        return (CGSize){};
    }

    CGSize size = super.intrinsicContentSize;

    size.width  += _padding.left + _padding.right;
    size.height += _padding.top  + _padding.bottom;

    return size;
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    if (!self.text.length)
    {
        return (CGRect){};
    }

    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, _padding) limitedToNumberOfLines:numberOfLines];
}

- (void)drawTextInRect:(CGRect)rect
{
    if (!self.text.length)
    {
        return;
    }

    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, _padding)];
}

- (void)setPadding:(UIEdgeInsets)padding
{
    _padding = padding;
    [self invalidateIntrinsicContentSize];
}

#pragma mark Misc accessors
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

- (NSString *)text
{
    return self.markup;
}

- (void)setText:(NSString *)text
{
    self.markup = text;
    [self resetAttributes];
}

- (void)setFontSize:(CGFloat)fontSize
{
    if (_fontSize != fontSize)
    {
        _fontSize = fontSize;
        [self resetAttributes];
    }
}

#pragma mark Dynamic restyling
- (void)tintColorDidChange
{
    [super tintColorDidChange];
    [self resetAttributes];
}

- (void)resetAttributes
{
    UIFont *font = _RAuthenticationDynamicFont([UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody], _fontSize);
    super.font = font;

    NSString *markup = self.markup;
    if (markup.length)
    {
        NSMutableParagraphStyle *style = NSParagraphStyle.defaultParagraphStyle.mutableCopy;
        style.lineBreakMode    = self.lineBreakMode;
        style.alignment        = self.textAlignment;
        style.paragraphSpacing = 10;

        NSDictionary *attributes = @{NSFontAttributeName: font,
                                     NSForegroundColorAttributeName: self.tintColor,
                                     NSParagraphStyleAttributeName: style};

        UIFontDescriptor *fontDescriptor = font.fontDescriptor;

        /*
         * For bold text, try to obtain a font that matches our default but with a bold weight.
         * If none is found, drop all traits but 'bold'.
         * As last resort, simply render the text with the normal font.
         */
        UIFont *boldFont =
        [UIFont fontWithDescriptor:[fontDescriptor fontDescriptorWithSymbolicTraits:fontDescriptor.symbolicTraits | UIFontDescriptorTraitBold] size:0]
        ?: [UIFont fontWithDescriptor:[fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:0]
        ?: font;

        /*
         * For italic text, if we can't find a proper font we render the text obliquely rather than
         * dropping our traits.
         */
        UIFont *italicFont = [UIFont fontWithDescriptor:[fontDescriptor fontDescriptorWithSymbolicTraits:fontDescriptor.symbolicTraits | UIFontDescriptorTraitItalic] size:0];

        NSDictionary *styles = @{@"b": @{NSFontAttributeName: boldFont},
                                 @"u": @{NSUnderlineStyleAttributeName: @1},
                                 @"i": italicFont ? @{NSFontAttributeName: italicFont} : @{NSObliquenessAttributeName: @.2}};

        if (self.markupStyles.count)
        {
            NSMutableDictionary *tmp = styles.mutableCopy;
            [tmp addEntriesFromDictionary:self.markupStyles];
            styles = tmp;
        }

        super.attributedText = _RAuthenticationParseMarkup((id)markup, attributes, styles);
    }
    else
    {
        super.attributedText = nil;
    }

    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
    [self setNeedsUpdateConstraints];
}
@end
