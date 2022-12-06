/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Result model for Rakuten App Engine's IdInformation/GetRa endpoint.
 *
 *  This class conforms to RWCURLResponseParser and can serialize an instance of itself from appropriate network data generated
 *  by a RIIGetRaRequest.
 *
 *  @class RIIRa RIIRa.h <RakutenIdInformationClient/RIIRa.h>
 *  @ingroup RIIResponses
 *  @ingroup RIICoreComponents
 */
RWC_EXPORT @interface RIIRa : RWCAutoCopyableModel <RWCURLResponseParser>

/**
 *  The Ra Key
 */
@property (copy, nonatomic, nullable) NSString *raKey;

@end

NS_ASSUME_NONNULL_END