/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>

NS_ASSUME_NONNULL_BEGIN
@class _RAuthenticationLabel;

typedef NS_ENUM(NSUInteger, _RAuthenticationButtonType)
{
    _RAuthenticationPrimaryButtonType = 0,
    _RAuthenticationSecondaryButtonType,
    _RAuthenticationTernaryButtonType,
};

RAUTH_EXPORT @interface _RAuthenticationButton : UIControl
@property (nonatomic, nullable)       NSString    *title;
@property (nonatomic)                 UIEdgeInsets padding;
@property (nonatomic, nullable, copy) NSArray<NSLayoutConstraint *> *additionalConstraintsWhenVisible;

+ (instancetype)buttonWithType:(_RAuthenticationButtonType)type;
@end

NS_ASSUME_NONNULL_END
