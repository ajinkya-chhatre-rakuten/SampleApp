/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RWCDefines.h>

NS_ASSUME_NONNULL_BEGIN

@class RWCURLQueryItem;

/**
 *  Protocol whose conforming instances can be serialized into an array of RWCURLQueryItem instances.
 *
 *  @protocol RWCURLQueryItemSerializable RWCURLQueryItemSerializable.h <RakutenWebClientKit/RWCURLQueryItemSerializable.h>
 *  @ingroup RWCUtilities
 */
@protocol RWCURLQueryItemSerializable

/**
 *  Serializes the receiver into an array of RWCURLQueryItem instances.
 *
 *  @param error An optional error pointer which should be filled if the receiver fails to serialize
 *
 *  @return An array of RWCURLQueryItem instances or nil if the receiver could not be serialized
 */
- (nullable NSArray RWC_GENERIC(RWCURLQueryItem *) *)serializeQueryItemsWithError:(out NSError **)error;

@end

NS_ASSUME_NONNULL_END

