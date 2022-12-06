/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RWCDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Utilities for parsing values from arbitrary objects.
 *
 *  @warning All methods defined in this class will throw an exception if the object is available and cannot be parsed into the desired type.
 *
 *  @class RWCParserUtilities RWCParserUtilities.h <RakutenWebClientKit/RWCParserUtilities.h>
 *  @ingroup RWCUtilities
 */
RWC_EXPORT @interface RWCParserUtilities : NSObject

/**
 * Try to obtain an integer from various inputs.
 *
 * @param object An object
 *
 * @return A 64-bit integer value if @c object represents an integer or a boolean. Strings such as @c \@"42" or  @c \@"false" are
 *         successfully converted. If no value is found, returns @c INT64_MAX.
 *
 * @exception NSInvalidArgumentException The object couldn't be coerced to an integer.
 */
+ (int64_t)integerWithObject:(nullable id)object;

/**
 * Try to obtain an unsigned integer from various inputs.
 *
 * @param object An object
 *
 * @return A 64-bit unsigned integer value if @c object represents an unsigned integer or a boolean. Strings such as @c \@"42" or
 *         @c \@"false" are successfully converted. If no value is found, returns @c UINT64_MAX.
 *
 * @exception NSInvalidArgumentException The object couldn't be coerced to an unsigned integer.
 */
+ (uint64_t)unsignedIntegerWithObject:(nullable id)object;

/**
 * Try to obtain a string from various inputs.
 *
 * @param object An object
 *
 * @return The @c object itself if was an NSString instance, the string representation if it responds to @c -stringValue, or @c nil if the
 *         @c object was @c nil.
 *
 * @exception NSInvalidArgumentException The object is non-nil and cannot be coerced to a string.
 */
+ (nullable NSString *)stringWithObject:(nullable id)object;

@end

NS_ASSUME_NONNULL_END

