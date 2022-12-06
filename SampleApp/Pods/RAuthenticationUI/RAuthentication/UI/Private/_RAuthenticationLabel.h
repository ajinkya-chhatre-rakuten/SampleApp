/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>

NS_ASSUME_NONNULL_BEGIN

RAUTH_EXPORT @interface _RAuthenticationLabel : UILabel
@property (nonatomic)                 UIEdgeInsets padding;
@property (nonatomic)                 CGFloat      fontSize;
@property (nonatomic, nullable, copy) NSArray<NSLayoutConstraint *> *additionalConstraintsWhenVisible;
@property (nonatomic, nullable, copy) NSDictionary<NSString *, NSDictionary<NSString *, id> *> *markupStyles;
@end

NS_ASSUME_NONNULL_END
