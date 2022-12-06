/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>

NS_ASSUME_NONNULL_BEGIN

RAUTH_EXPORT @interface _RAuthenticationTextField : UITextField
@property (nonatomic, getter=isValid) BOOL valid;
@end

NS_ASSUME_NONNULL_END
