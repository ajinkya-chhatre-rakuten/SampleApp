/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Result model for Rakuten App Engine's IdInformation/GetEncryptedEasyId endpoint.
 *
 *  This class conforms to RWCURLResponseParser and can serialize an instance of itself from appropriate network data generated
 *  by a RIIGetEncryptedEasyIdRequest.
 *
 *  @class RIIEncryptedEasyId RIIEncryptedEasyId.h <RakutenIdInformationClient/RIIEncryptedEasyId.h>
 *  @ingroup RIIResponses
 *  @ingroup RIICoreComponents
 */
RWC_EXPORT @interface RIIEncryptedEasyId : RWCAutoCopyableModel <RWCURLResponseParser>

/**
 *  The encrypted easy ID
 */
@property (copy, nonatomic, nullable) NSString *easyId;

@end

NS_ASSUME_NONNULL_END