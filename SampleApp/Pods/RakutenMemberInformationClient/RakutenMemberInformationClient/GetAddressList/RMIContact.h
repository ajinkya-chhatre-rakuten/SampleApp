#import <RakutenWebClientKit/RakutenWebClientKit.h>
#import <RakutenMemberInformationClient/RMIConstants.h>

NS_ASSUME_NONNULL_BEGIN

@class RMIName;
@class RMIEmail;
@class RMITelephone;

/**
 *  Result model for Rakuten App Engine's MemberInformation/GetAddressList endpoint.
 *
 *  This class conforms to RWCURLResponseParser and can serialize an array of instances of itself from appropriate network data generated
 *  by a RMIGetAddressListRequest.
 *
 *  @class RMIContact RMIContact.h <RakutenMemberInformationClient/RMIContact.h>
 *  @ingroup RMIResponses
 *  @ingroup RMICoreComponents
 */
RWC_EXPORT @interface RMIContact : RWCAutoCopyableModel <RWCURLResponseParser>

/**
 *  Identifier of the receiver.
 */
@property (copy, nonatomic, nullable) NSString *contactIdentifier;

/**
 *  Name information of the receiver.
 */
@property (copy, nonatomic, nullable) RMIName *nameInformation;

/**
 *  Gender of the receiver.
 */
@property (nonatomic) RMIProfileGender gender;

/**
 *  Date of birth components of the receiver.
 *
 *  Only the day, month, and year properties of the date components will be populated. The components should be interpreted
 *  using the Gregorian calendar.
 */
@property (copy, nonatomic, nullable) NSDateComponents *dateOfBirthComponents;

/**
 *  Relation identifier of the receiver.
 */
@property (copy, nonatomic, nullable) NSString *relationIdentifier;

/**
 *  Country code of the receiver's nationality.
 */
@property (copy, nonatomic, nullable) NSString *nationalityCode;

/**
 *  Organization the receiver belongs to.
 */
@property (copy, nonatomic, nullable) NSString *organization;

/**
 *  Job title of the receiver.
 */
@property (copy, nonatomic, nullable) NSString *jobTitle;

/**
 *  Country code of the receiver's address.
 */
@property (copy, nonatomic, nullable) NSString *countryCode;

/**
 *  Zip code of the receiver's address.
 */
@property (copy, nonatomic, nullable) NSString *zipCode;

/**
 *  State/province code of the receiver's address.
 */
@property (copy, nonatomic, nullable) NSString *stateCode;

/**
 *  State/province of the receiver's address.
 */
@property (copy, nonatomic, nullable) NSString *state;

/**
 *  City of the receiver's address.
 */
@property (copy, nonatomic, nullable) NSString *city;

/**
 *  Street of the receiver's address
 */
@property (copy, nonatomic, nullable) NSString *street;

/**
 *  Email information of the receiver
 */
@property (copy, nonatomic, nullable) RMIEmail *emailInformation;

/**
 *  Telephone information of the receiver
 */
@property (copy, nonatomic, nullable) RMITelephone *telephoneInformation;

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
