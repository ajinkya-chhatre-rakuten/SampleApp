#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Result model for Rakuten App Engine's MemberInformation/GetTelephone endpoint, as well as general Japan Ichiba member's telephone, mobile phone and fax number information.
 *
 *  This class conforms to RWCURLResponseParser and can serialize an instance of itself from appropriate network data generated by a RMIGetTelephoneRequest.
 *
 *  @class RMITelephoneModel RMITelephoneModel.h <RakutenMemberInformationClient/RMITelephoneModel.h>
 *  @ingroup RMIResponses
 *  @ingroup RMICoreComponents
 */
RWC_EXPORT @interface RMITelephone : RWCAutoCopyableModel <RWCURLResponseParser>

/**
 *  Telephone number information of the receiver
 */
@property (copy, nonatomic, nullable) NSString *telephone;

/**
 *  Mobile phone number information of the receiver
 */
@property (copy, nonatomic, nullable) NSString *mobilePhone;

/**
 *  Fax number information of the receiver
 */
@property (copy, nonatomic, nullable) NSString *faxNumber;

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