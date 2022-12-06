/*
 * © Rakuten, Inc.
 */
#import "_RAuthenticationUIValues.h"

@interface _RAuthenticationUIValues ()
@property (readonly, nonatomic) CGFloat         fontSize0;
@property (readonly, nonatomic) CGFloat         fontSize1;
@property (readonly, nonatomic) CGFloat         fontSize2;
@property (readonly, nonatomic) CGFloat         fontSize3;
@property (readonly, nonatomic) CGFloat         primaryCornerRadius;
@property (readonly, nonatomic) UIEdgeInsets    primaryPadding;
@property (readonly, nonatomic) UIColor        *primaryTextColor;
@property (readonly, nonatomic) UIColor        *primaryBackgroundColor;

@property (readonly, nonatomic) UIColor        *navigationBarTitleColor;
@property (readonly, nonatomic) UIColor        *navigationBarLinkColor;
@property (readonly, nonatomic) UIColor        *navigationBarBackgroundColor;

@property (readonly, nonatomic) CGFloat         primarySpacing;
@property (readonly, nonatomic) CGFloat         secondarySpacing;
@property (readonly, nonatomic) CGFloat         ternarySpacing;

@property (readonly, nonatomic) UIColor        *inputFieldBorderColor;
@property (readonly, nonatomic) UIColor        *inputFieldTextColor;
@property (readonly, nonatomic) UIColor        *inputFieldAccessoryColor;
@property (readonly, nonatomic) UIColor        *inputFieldPlaceholderColor;
@property (readonly, nonatomic) UIColor        *inputFieldBackgroundColor;
@property (readonly, nonatomic) UIColor        *inputFieldInvalidColor;

@property (readonly, nonatomic) UIColor        *primaryButtonTextColor;
@property (readonly, nonatomic) UIColor        *primaryButtonBackgroundColor;
@property (readonly, nonatomic) UIColor        *primaryButtonBorderColor;

@property (readonly, nonatomic) UIColor        *secondaryButtonTextColor;
@property (readonly, nonatomic) UIColor        *secondaryButtonBackgroundColor;
@property (readonly, nonatomic) UIColor        *secondaryButtonBorderColor;

@property (readonly, nonatomic) UIColor        *copyrightColor;
@end


@implementation _RAuthenticationUIValues
- (instancetype)init
{
    if ((self = [super init]))
    {
        /*
         * Those were inferred from the "specs" CWD provided us with.
         */
        UIColor *rakutenRed             = [UIColor colorWithRed:.75 green:0 blue:0 alpha:1];

        _fontSize0						= 1;
        _fontSize1						= 15./17.;
        _fontSize2						= 14./17.;
        _fontSize3						= 12./17.;
        _primaryCornerRadius			= 5;
        _primaryPadding					= UIEdgeInsetsMake(14, 14, 14, 14);
        _primaryTextColor				= UIColor.darkTextColor;
        _primaryBackgroundColor			= UIColor.whiteColor;

        _navigationBarTitleColor        = UIColor.darkTextColor;
        _navigationBarLinkColor         = rakutenRed;
        _navigationBarBackgroundColor   = nil;

        _primarySpacing					= 20;
        _secondarySpacing				= 10;
        _ternarySpacing					= 5;

        _inputFieldBorderColor			= UIColor.lightGrayColor;
        _inputFieldTextColor			= UIColor.darkTextColor;
        _inputFieldAccessoryColor		= rakutenRed;
        _inputFieldPlaceholderColor		= UIColor.lightGrayColor;
        _inputFieldBackgroundColor		= UIColor.whiteColor;
        _inputFieldInvalidColor			= rakutenRed;

        _primaryButtonTextColor			= UIColor.whiteColor;
        _primaryButtonBackgroundColor	= rakutenRed;
        _primaryButtonBorderColor		= nil;

        _secondaryButtonTextColor		= UIColor.blackColor;
        _secondaryButtonBackgroundColor	= [UIColor colorWithWhite:0 alpha:.03]; // 3% darken
        _secondaryButtonBorderColor		= UIColor.lightGrayColor;

        _copyrightColor                 = UIColor.lightGrayColor;
    }
    return self;
}

+ (instancetype)instance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

#define R ((_RAuthenticationUIValues *) self.instance)
+ (CGFloat)FONT_SIZE_0                          { return R.fontSize0; }
+ (CGFloat)FONT_SIZE_1                          { return R.fontSize1; }
+ (CGFloat)FONT_SIZE_2                          { return R.fontSize2; }
+ (CGFloat)FONT_SIZE_3                          { return R.fontSize3; }
+ (CGFloat)PRIMARY_CORNER_RADIUS                { return R.primaryCornerRadius; }
+ (UIEdgeInsets)PRIMARY_PADDING                 { return R.primaryPadding; }
+ (UIColor *)PRIMARY_TEXT_COLOR                 { return R.primaryTextColor; }
+ (UIColor *)PRIMARY_BACKGROUND_COLOR           { return R.primaryBackgroundColor; }
+ (UIColor *)NAVIGATION_BAR_TITLE_COLOR         { return R.navigationBarTitleColor; }
+ (UIColor *)NAVIGATION_BAR_LINK_COLOR          { return R.navigationBarLinkColor; }
+ (UIColor *)NAVIGATION_BAR_BACKGROUND_COLOR    { return R.navigationBarBackgroundColor; }
+ (CGFloat)PRIMARY_SPACING                      { return R.primarySpacing; }
+ (CGFloat)SECONDARY_SPACING                    { return R.secondarySpacing; }
+ (CGFloat)TERNARY_SPACING                      { return R.ternarySpacing; }
+ (UIColor *)INPUT_FIELD_BORDER_COLOR           { return R.inputFieldBorderColor; }
+ (UIColor *)INPUT_FIELD_TEXT_COLOR             { return R.inputFieldTextColor; }
+ (UIColor *)INPUT_FIELD_ACCESSORY_COLOR        { return R.inputFieldAccessoryColor; }
+ (UIColor *)INPUT_FIELD_PLACEHOLDER_COLOR      { return R.inputFieldPlaceholderColor; }
+ (UIColor *)INPUT_FIELD_BACKGROUND_COLOR       { return R.inputFieldBackgroundColor; }
+ (UIColor *)INPUT_FIELD_INVALID_COLOR          { return R.inputFieldInvalidColor; }
+ (UIColor *)PRIMARY_BUTTON_TEXT_COLOR          { return R.primaryButtonTextColor; }
+ (UIColor *)PRIMARY_BUTTON_BACKGROUND_COLOR    { return R.primaryButtonBackgroundColor; }
+ (UIColor *)PRIMARY_BUTTON_BORDER_COLOR        { return R.primaryButtonBorderColor; }
+ (UIColor *)SECONDARY_BUTTON_TEXT_COLOR        { return R.secondaryButtonTextColor; }
+ (UIColor *)SECONDARY_BUTTON_BACKGROUND_COLOR  { return R.secondaryButtonBackgroundColor; }
+ (UIColor *)SECONDARY_BUTTON_BORDER_COLOR      { return R.secondaryButtonBorderColor; }
+ (UIColor *)COPYRIGHT_COLOR                    { return R.copyrightColor; }
#undef R
@end
