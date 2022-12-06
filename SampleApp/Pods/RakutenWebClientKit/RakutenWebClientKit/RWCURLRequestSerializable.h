/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RWCDefines.h>

NS_ASSUME_NONNULL_BEGIN

@class RWCURLRequestConfiguration;

/**
 *  Protocol for classes whose instances can be serialized into NSURLRequest instances.
 *
 *  @protocol RWCURLRequestSerializable RWCURLRequestSerializable.h <RakutenWebClientKit/RWCURLRequestSerializable.h>
 *  @ingroup RWCCoreComponents
 */
@protocol RWCURLRequestSerializable

/**
 *  Serializes the receiver into an NSURLRequest.
 *
 *  @param configuration An optional configuration object which should influence attributes of the resulting request
 *  @param error         An optional error pointer which should be filled upon failure to serialize a request
 *
 *  @return An NSURLRequest serialized from the receiver, or nil if an error occured preventing the serialization
 */
- (nullable NSURLRequest *)serializeURLRequestWithConfiguration:(nullable RWCURLRequestConfiguration *)configuration
                                                          error:(out NSError **)error;

@end

NS_ASSUME_NONNULL_END

