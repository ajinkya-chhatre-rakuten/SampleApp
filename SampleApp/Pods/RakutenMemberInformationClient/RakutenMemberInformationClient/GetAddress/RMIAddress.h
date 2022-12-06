#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Result model for Rakuten App Engine's MemberInformation/GetAddress endpoint, as well as general Japan Ichiba member mailing address information.
 *
 *  This class conforms to RWCURLResponseParser and can serialize an instance of itself from appropriate network data generatedn by a RMIGetAddressRequest.
 *
 *  @class RMIAddressModel RMIAddressModel.h <RakutenMemberInformationClient/RMIAddressModel.h>
 *  @ingroup RMIResponses
 *  @ingroup RMICoreComponents
 */
RWC_EXPORT @interface RMIAddress : RWCAutoCopyableModel <RWCURLResponseParser>

/**
 *  The Zip code information of the receiver
 */
@property (copy, nonatomic, nullable) NSString *zipCode;

/**
 *  The prefecture informaiton of the receiver
 */
@property (copy, nonatomic, nullable) NSString *prefecture;

/**
 *  The city informaiton of the receiver
 */
@property (copy, nonatomic, nullable) NSString *city;

/**
 *  The street informaiton of the receiver
 */
@property (copy, nonatomic, nullable) NSString *street;

/**
 *  The full address informaiton of the receiver
 */
@property (copy, nonatomic, nullable) NSString *fullAddress;

/**
 *  Initializes the receiver with RAE produced and decoded JSON.
 *
 *  This method should typically only be called by other RWCURLResponseParser conformers.
 *
 *  @param JSONDictionary The RAE JSON representing the receiver.
 *
 *  @return An initialized instance of the receiver, or nil if there was an issue with the provided JSON.
 */
- (nullable instancetype)initWithJSONDictionary:(NSDictionary *)JSONDictionary;

@end

NS_ASSUME_NONNULL_END
