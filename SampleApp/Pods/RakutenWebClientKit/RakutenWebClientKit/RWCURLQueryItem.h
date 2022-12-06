/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RWCDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Class representing an individual query item used in either a URL query string or as form encoded data.
 *
 *  This class is comparable to NSURLQueryItem, but instead of relying on NSURLComponents for percent encoding, this class is able to
 *  encode and decode itself, which is useful for producing form encoded data.
 *
 *  @class RWCURLQueryItem RWCURLQueryItem.h <RakutenWebClientKit/RWCURLQueryItem.h>
 *  @ingroup RWCUtilities
 */
RWC_EXPORT @interface RWCURLQueryItem : NSObject <NSCopying, NSSecureCoding>

/**
 *  Designated initializer which takes a percent unencoded key and value.
 *
 *  @note This method expects an unencoded key and value, so some caution should be taken not to double-encode strings.
 *
 *  @param key   The percent unencoded key of the query item
 *  @param value The optional percent unencoded value of the query item
 *
 *  @return An initialized instance of the receiver
 */
- (instancetype)initWithPercentUnencodedKey:(NSString *)key percentUnencodedValue:(nullable NSString *)value NS_DESIGNATED_INITIALIZER;

/**
 *  Returns the percent unencoded key.
 */
@property (copy, nonatomic, readonly) NSString *key;

/**
 *  Returns the percent unencoded value if available.
 */
@property (nullable, copy, nonatomic, readonly) NSString *value;

/**
 *  Returns the percent encoded key.
 */
@property (copy, nonatomic, readonly) NSString *percentEncodedKey;

/**
 *  Returns the percent encoded value if available.
 */
@property (nullable, copy, nonatomic, readonly) NSString *percentEncodedValue;

/**
 *  The query string representation of the receiver.
 *
 *  If the receiver has both a key and value, the percent encoded versions will be concatenated together with a "=" separator. Otherwise
 *  this method returns the percent encoded key.
 *
 *  @return A string representing the receiver suitable for use in a query string or encoded into form data
 */
- (NSString *)description;

/**
 *  Compares the receiver to the given query item for ordering.
 *
 *  This is equivalent to comparing the output of @c -description for both the receiver and the given query item.
 *
 *  @param other The other query item to compare against
 *
 *  @return NSOrderedAscending if the receiver should be ordered above the given query item, NSOrderedDescending if the reciever should
 *          be ordered below the given query item, or NSOrderedSame if they have the same ordering
 */
- (NSComparisonResult)compare:(RWCURLQueryItem *)other;

@end

/**
 *  Convenience utilities for RWCURLQueryItem
 */
@interface RWCURLQueryItem (RWCUtilities)

/**
 *  Convenience factory for generating a RWCURLQueryItem.
 *
 *  @see @c RWCURLQueryItem::initWithPercentUnencodedKey:percentUnencodedValue:
 *
 *  @param key   The percent unencoded key of the query item
 *  @param value The optional percent unencoded value of the query item
 *
 *  @return An initialized instance of the receiver
 */
+ (instancetype)queryItemWithPercentUnencodedKey:(NSString *)key percentUnencodedValue:(nullable NSString *)value;

/**
 *  Convenience factory for generating a RWCURLQueryItem from percent encoded strings.
 *
 *  @note This method is a convenience for calling @c -stringByRemovingPercentEncoding on the key and value, then passing them to the
 *        designated initializer.
 *
 *  @param key   The percent encoded key
 *  @param value The percent encoded value if available
 *
 *  @return An initialized instance of the receiver
 */
+ (instancetype)queryItemWithPercentEncodedKey:(NSString *)key percentEncodedValue:(nullable NSString *)value;

/**
 *  Decomposes a query string into an array of RWCURLQueryItem instances.
 *
 *  @see @c RWCURLQueryItem::queryItemWithPercentEncodedKey:percentEncodedValue:
 *
 *  @param percentEncodedQueryString The percent encoded query string to decompose into RWCURLQueryItem instances
 *
 *  @return An array of RWCURLQueryItem instances representing the query string
 */
+ (NSArray RWC_GENERIC(RWCURLQueryItem *) *)queryItemsFromPercentEncodedQueryString:(NSString *)percentEncodedQueryString;

/**
 *  Combines the RWCURLQueryItem instances into a single query string suitable for use in a URL or as form data.
 *
 *  @param queryItems An array of RWCURLQueryItem instances
 *
 *  @return A percent encoded query string representing the given query items
 */
+ (nullable NSString *)queryStringFromQueryItems:(nullable NSArray RWC_GENERIC(RWCURLQueryItem *) *)queryItems;

/**
 *  Combines the RWCURLQueryItem instances and encodes them into form data
 *
 *  @note This method is a convenience for calling @c RWCURLQueryItem::queryStringFromQueryItems: and encoding the resulting string using
 *        NSUTF8StringEncoding
 *  @see @c RWCURLQueryItem::queryStringFromQueryItems:
 *
 *  @param queryItems An array of RWCURLQueryItem instances
 *
 *  @return UTF-8 encoded form data representing the given query items
 */
+ (nullable NSData *)formDataFromQueryItems:(nullable NSArray RWC_GENERIC(RWCURLQueryItem *) *)queryItems;

@end

NS_ASSUME_NONNULL_END

