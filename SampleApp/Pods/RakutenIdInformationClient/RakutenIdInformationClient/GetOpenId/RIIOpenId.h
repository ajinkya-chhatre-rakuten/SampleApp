/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Result model for Rakuten App Engine's IdInformation/GetOpenID endpoint.
 *
 *  This class conforms to RWCURLResponseParser and can serialize an instance of itself from appropriate network data generated
 *  by a RIIGetOpenIdRequest.
 *
 *  @class RIIOpenId RIIOpenId.h <RakutenIdInformationClient/RIIOpenId.h>
 *  @ingroup RIIResponses
 *  @ingroup RIICoreComponents
 */
RWC_EXPORT @interface RIIOpenId : RWCAutoCopyableModel <RWCURLResponseParser>

/**
 *  openId of response's info(OpenID API)
 */
@property (copy, nonatomic, nullable) NSString *openId;

@end

NS_ASSUME_NONNULL_END