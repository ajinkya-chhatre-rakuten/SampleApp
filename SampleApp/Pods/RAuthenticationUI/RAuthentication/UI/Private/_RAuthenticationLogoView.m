/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationUI/RAuthenticationUI.h>
#import "_RAuthenticationLogoView.h"
#import "_RAuthenticationUIHelpers.h"

RAUTH_EXPORT @interface _RAuthenticationLogoView : UIView @end

@implementation _RAuthenticationLogoView
{
    UIBezierPath *_path;
    UIColor *_color;
    CGSize _viewportSize;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        super.backgroundColor = UIColor.clearColor;
        _color = [UIColor colorWithRed:.75 green:0 blue:0 alpha:1];
        _viewportSize = CGSizeMake(165.87, 49.36);
        _path = [UIBezierPath new];
        [_path moveToPoint: CGPointMake(133.53, 41.37)];
        [_path addLineToPoint: CGPointMake(33.17, 41.37)];
        [_path addLineToPoint: CGPointMake(41.17, 49.36)];
        [_path addLineToPoint: CGPointMake(133.53, 41.37)];
        [_path closePath];
        [_path moveToPoint: CGPointMake(42.47, 9.04)];
        [_path addLineToPoint: CGPointMake(42.47, 10.25)];
        [_path addLineToPoint: CGPointMake(42.54, 10.3)];
        [_path addCurveToPoint: CGPointMake(36.78, 8.37) controlPoint1: CGPointMake(40.86, 9.08) controlPoint2: CGPointMake(38.85, 8.41)];
        [_path addCurveToPoint: CGPointMake(24.28, 22.65) controlPoint1: CGPointMake(29.65, 8.37) controlPoint2: CGPointMake(24.28, 14.78)];
        [_path addCurveToPoint: CGPointMake(36.65, 36.94) controlPoint1: CGPointMake(24.28, 30.52) controlPoint2: CGPointMake(29.62, 36.94)];
        [_path addLineToPoint: CGPointMake(36.6, 36.94)];
        [_path addCurveToPoint: CGPointMake(42.39, 35.11) controlPoint1: CGPointMake(38.67, 36.94) controlPoint2: CGPointMake(40.7, 36.3)];
        [_path addLineToPoint: CGPointMake(42.47, 36.27)];
        [_path addLineToPoint: CGPointMake(48.65, 36.27)];
        [_path addLineToPoint: CGPointMake(48.65, 9.04)];
        [_path addLineToPoint: CGPointMake(42.47, 9.04)];
        [_path closePath];
        [_path moveToPoint: CGPointMake(36.65, 30.37)];
        [_path addCurveToPoint: CGPointMake(30.65, 22.64) controlPoint1: CGPointMake(33.18, 30.37) controlPoint2: CGPointMake(30.65, 26.96)];
        [_path addCurveToPoint: CGPointMake(36.65, 14.92) controlPoint1: CGPointMake(30.65, 18.32) controlPoint2: CGPointMake(33.19, 14.92)];
        [_path addCurveToPoint: CGPointMake(42.57, 22.64) controlPoint1: CGPointMake(40.11, 14.92) controlPoint2: CGPointMake(42.57, 18.33)];
        [_path addCurveToPoint: CGPointMake(36.65, 30.37) controlPoint1: CGPointMake(42.57, 26.95) controlPoint2: CGPointMake(40.12, 30.37)];
        [_path closePath];
        [_path moveToPoint: CGPointMake(91.99, 9.04)];
        [_path addLineToPoint: CGPointMake(91.99, 25.04)];
        [_path addCurveToPoint: CGPointMake(86.92, 30.58) controlPoint1: CGPointMake(91.99, 28.04) controlPoint2: CGPointMake(89.93, 30.58)];
        [_path addCurveToPoint: CGPointMake(81.86, 25.04) controlPoint1: CGPointMake(83.91, 30.58) controlPoint2: CGPointMake(81.86, 28.04)];
        [_path addLineToPoint: CGPointMake(81.86, 9.04)];
        [_path addLineToPoint: CGPointMake(75.68, 9.04)];
        [_path addLineToPoint: CGPointMake(75.68, 25.04)];
        [_path addCurveToPoint: CGPointMake(86.73, 36.95) controlPoint1: CGPointMake(75.68, 31.61) controlPoint2: CGPointMake(80.17, 36.95)];
        [_path addLineToPoint: CGPointMake(86.75, 36.95)];
        [_path addCurveToPoint: CGPointMake(92.05, 35.23) controlPoint1: CGPointMake(88.65, 36.92) controlPoint2: CGPointMake(90.49, 36.32)];
        [_path addLineToPoint: CGPointMake(91.99, 36.27)];
        [_path addLineToPoint: CGPointMake(98.17, 36.27)];
        [_path addLineToPoint: CGPointMake(98.17, 9.04)];
        [_path addLineToPoint: CGPointMake(91.99, 9.04)];
        [_path closePath];
        [_path moveToPoint: CGPointMake(149.56, 36.27)];
        [_path addLineToPoint: CGPointMake(149.56, 20.27)];
        [_path addCurveToPoint: CGPointMake(154.63, 14.74) controlPoint1: CGPointMake(149.56, 17.27) controlPoint2: CGPointMake(151.62, 14.74)];
        [_path addCurveToPoint: CGPointMake(159.69, 20.27) controlPoint1: CGPointMake(157.64, 14.74) controlPoint2: CGPointMake(159.69, 17.27)];
        [_path addLineToPoint: CGPointMake(159.69, 36.27)];
        [_path addLineToPoint: CGPointMake(165.87, 36.27)];
        [_path addLineToPoint: CGPointMake(165.87, 20.27)];
        [_path addCurveToPoint: CGPointMake(154.81, 8.37) controlPoint1: CGPointMake(165.87, 13.71) controlPoint2: CGPointMake(161.38, 8.37)];
        [_path addLineToPoint: CGPointMake(154.78, 8.37)];
        [_path addCurveToPoint: CGPointMake(149.51, 10.08) controlPoint1: CGPointMake(152.89, 8.4) controlPoint2: CGPointMake(151.06, 9)];
        [_path addLineToPoint: CGPointMake(149.56, 9.05)];
        [_path addLineToPoint: CGPointMake(143.38, 9.05)];
        [_path addLineToPoint: CGPointMake(143.38, 36.27)];
        [_path addLineToPoint: CGPointMake(149.56, 36.27)];
        [_path closePath];
        [_path moveToPoint: CGPointMake(6.46, 36.27)];
        [_path addLineToPoint: CGPointMake(6.46, 25.72)];
        [_path addLineToPoint: CGPointMake(11.04, 25.72)];
        [_path addLineToPoint: CGPointMake(18.99, 36.27)];
        [_path addLineToPoint: CGPointMake(27.08, 36.27)];
        [_path addLineToPoint: CGPointMake(17.52, 23.54)];
        [_path addLineToPoint: CGPointMake(17.45, 23.59)];
        [_path addCurveToPoint: CGPointMake(20.33, 7.25) controlPoint1: CGPointMake(22.76, 19.87) controlPoint2: CGPointMake(24.05, 12.56)];
        [_path addCurveToPoint: CGPointMake(10.72, 2.25) controlPoint1: CGPointMake(18.14, 4.12) controlPoint2: CGPointMake(14.55, 2.25)];
        [_path addLineToPoint: CGPointMake(0, 2.25)];
        [_path addLineToPoint: CGPointMake(0, 36.25)];
        [_path addLineToPoint: CGPointMake(6.46, 36.27)];
        [_path closePath];
        [_path moveToPoint: CGPointMake(6.46, 8.71)];
        [_path addLineToPoint: CGPointMake(10.68, 8.71)];
        [_path addLineToPoint: CGPointMake(10.68, 8.71)];
        [_path addCurveToPoint: CGPointMake(15.95, 13.98) controlPoint1: CGPointMake(13.59, 8.71) controlPoint2: CGPointMake(15.95, 11.07)];
        [_path addCurveToPoint: CGPointMake(10.68, 19.25) controlPoint1: CGPointMake(15.95, 16.89) controlPoint2: CGPointMake(13.59, 19.25)];
        [_path addLineToPoint: CGPointMake(6.46, 19.25)];
        [_path addLineToPoint: CGPointMake(6.46, 8.71)];
        [_path closePath];
        [_path moveToPoint: CGPointMake(114.81, 29.82)];
        [_path addLineToPoint: CGPointMake(114.79, 29.84)];
        [_path addCurveToPoint: CGPointMake(112.71, 30.49) controlPoint1: CGPointMake(114.18, 30.26) controlPoint2: CGPointMake(113.45, 30.49)];
        [_path addLineToPoint: CGPointMake(112.76, 30.49)];
        [_path addCurveToPoint: CGPointMake(109.81, 27.44) controlPoint1: CGPointMake(111.1, 30.46) controlPoint2: CGPointMake(109.78, 29.09)];
        [_path addCurveToPoint: CGPointMake(109.83, 27.18) controlPoint1: CGPointMake(109.81, 27.35) controlPoint2: CGPointMake(109.82, 27.26)];
        [_path addLineToPoint: CGPointMake(109.83, 15.5)];
        [_path addLineToPoint: CGPointMake(115.12, 15.5)];
        [_path addLineToPoint: CGPointMake(115.12, 9.04)];
        [_path addLineToPoint: CGPointMake(109.83, 9.04)];
        [_path addLineToPoint: CGPointMake(109.83, 2.25)];
        [_path addLineToPoint: CGPointMake(103.65, 2.25)];
        [_path addLineToPoint: CGPointMake(103.65, 9.04)];
        [_path addLineToPoint: CGPointMake(100.38, 9.04)];
        [_path addLineToPoint: CGPointMake(100.38, 15.5)];
        [_path addLineToPoint: CGPointMake(103.65, 15.5)];
        [_path addLineToPoint: CGPointMake(103.65, 27.25)];
        [_path addLineToPoint: CGPointMake(103.65, 27.17)];
        [_path addCurveToPoint: CGPointMake(112.45, 36.95) controlPoint1: CGPointMake(103.38, 32.3) controlPoint2: CGPointMake(107.33, 36.68)];
        [_path addCurveToPoint: CGPointMake(112.78, 36.96) controlPoint1: CGPointMake(112.56, 36.95) controlPoint2: CGPointMake(112.67, 36.96)];
        [_path addLineToPoint: CGPointMake(112.89, 36.96)];
        [_path addCurveToPoint: CGPointMake(118.83, 35.26) controlPoint1: CGPointMake(114.98, 36.89) controlPoint2: CGPointMake(117.02, 36.3)];
        [_path addLineToPoint: CGPointMake(114.81, 29.82)];
        [_path closePath];
        [_path moveToPoint: CGPointMake(64.01, 21.8)];
        [_path addLineToPoint: CGPointMake(74.61, 9.04)];
        [_path addLineToPoint: CGPointMake(65.95, 9.04)];
        [_path addLineToPoint: CGPointMake(58.54, 18.52)];
        [_path addLineToPoint: CGPointMake(58.54, 0)];
        [_path addLineToPoint: CGPointMake(52.17, 0)];
        [_path addLineToPoint: CGPointMake(52.17, 36.27)];
        [_path addLineToPoint: CGPointMake(58.54, 36.27)];
        [_path addLineToPoint: CGPointMake(58.54, 25.08)];
        [_path addLineToPoint: CGPointMake(67.65, 36.27)];
        [_path addLineToPoint: CGPointMake(76.31, 36.27)];
        [_path addLineToPoint: CGPointMake(64.01, 21.8)];
        [_path closePath];
        [_path moveToPoint: CGPointMake(129.09, 8.37)];
        [_path addCurveToPoint: CGPointMake(116.8, 22.67) controlPoint1: CGPointMake(121.94, 8.37) controlPoint2: CGPointMake(116.8, 14.65)];
        [_path addCurveToPoint: CGPointMake(129.7, 36.98) controlPoint1: CGPointMake(116.8, 31.11) controlPoint2: CGPointMake(123.25, 36.98)];
        [_path addCurveToPoint: CGPointMake(140.65, 30.89) controlPoint1: CGPointMake(132.96, 36.98) controlPoint2: CGPointMake(137.14, 35.86)];
        [_path addLineToPoint: CGPointMake(135.19, 27.73)];
        [_path addCurveToPoint: CGPointMake(123.12, 24.57) controlPoint1: CGPointMake(130.97, 33.96) controlPoint2: CGPointMake(123.93, 30.8)];
        [_path addLineToPoint: CGPointMake(140.92, 24.57)];
        [_path addCurveToPoint: CGPointMake(129.09, 8.37) controlPoint1: CGPointMake(142.44, 14.78) controlPoint2: CGPointMake(136.12, 8.37)];
        [_path closePath];
        [_path moveToPoint: CGPointMake(134.48, 19.16)];
        [_path addLineToPoint: CGPointMake(123.35, 19.16)];
        [_path addCurveToPoint: CGPointMake(134.48, 19.14) controlPoint1: CGPointMake(124.65, 12.76) controlPoint2: CGPointMake(133.28, 12.37)];
        [_path addLineToPoint: CGPointMake(134.48, 19.16)];
        [_path closePath];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextClearRect(context, rect);

    [self.backgroundColor setFill];
    CGContextFillRect(context, rect);

    CGContextConcatCTM(context, CGAffineTransformMakeScale(rect.size.width/_viewportSize.width,
                                                           rect.size.height/_viewportSize.height));
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);

    [_color setFill];
    [_path fill];

    CGContextRestoreGState(context);
}
@end

/* RAUTH_EXPORT */ UIView *_RAuthenticationCreateLogoView(/* out */ CGSize *imageSize)
{
    UIView *view = nil;

    // Does the app provide a custom logo?
    UIImage *logo = [UIImage imageNamed:@"RAuthenticationLogo"];
    if (logo)
    {
        // Use an image view with the custom logo
        view = [UIImageView.alloc initWithImage:logo];
        if (imageSize) *imageSize = logo.size;
    }
    else
    {
        // Use our vector-based view, with a natural size matching the specs
        CGRect rect = CGRectMake(0, 0, 128, 38.1);
        view = [_RAuthenticationLogoView.alloc initWithFrame:rect];
        if (imageSize) *imageSize = rect.size;
    }

    view.contentMode = UIViewContentModeScaleAspectFit;
    return view;
}
