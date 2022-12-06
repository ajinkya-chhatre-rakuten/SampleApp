/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RWCDefines.h>
#import <RakutenWebClientKit/RWCAutoCopyableModel.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Class representing configuration options for a Rakuten web client NSURLRequest.
 *
 *  This configuration object is typically fed into RWCURLRequestSerializable conformers to produce NSURLRequest instances.
 *
 *  @class RWCURLRequestConfiguration RWCURLRequestConfiguration.h <RakutenWebClientKit/RWCURLRequestConfiguration.h>
 *  @ingroup RWCCoreComponents
 */
RWC_EXPORT @interface RWCURLRequestConfiguration : RWCAutoCopyableModel <NSSecureCoding>

/**
 *  The base URL against which any requests should be made
 */
@property (nullable, copy, nonatomic) NSURL *baseURL;

/**
 *  Any additional or overriden HTTP headers which should be included in requests
 */
@property (nullable, copy, nonatomic) NSDictionary RWC_GENERIC(NSString *, NSString *) *HTTPHeaderFields;

/**
 *  The caching policy to apply to any requests made
 */
@property (nonatomic) NSURLRequestCachePolicy cachePolicy;

@end

NS_ASSUME_NONNULL_END

