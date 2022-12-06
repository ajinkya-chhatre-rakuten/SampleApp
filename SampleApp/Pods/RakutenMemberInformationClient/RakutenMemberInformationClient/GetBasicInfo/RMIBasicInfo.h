#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Result model for Rakuten App Engine's MemberInformation/GetBasicInfo endpoint.
 *
 *  This class conforms to RWCURLResponseParser and can serialize an instance of itself from appropriate network data generated
 *  by a RMIGetBasicInfoRequest.
 *
 *  @class RMIBasicInfo RMIBasicInfo.h <RakutenMemberInformationClient/RMIBasicInfo.h>
 *  @ingroup RMIResponses
 *  @ingroup RMICoreComponents
 */
RWC_EXPORT @interface RMIBasicInfo : RWCAutoCopyableModel <RWCURLResponseParser>

/**
 *  The gender of the member
 */
@property (nonatomic) RMIProfileGender gender;

/**
 *  The date of birth of the member
 *
 *  Only the day, month, and year properties of the date components will be populated. The components should be interpreted
 *  using the Gregorian calendar.
 */
@property (copy, nonatomic, nullable) NSDateComponents *dateOfBirthComponents;

/**
 *  The nickname of the member
 */
@property (copy, nonatomic, nullable) NSString *nickname;

/**
 *  Prefecture of the member
 */
@property (copy, nonatomic, nullable) NSString *prefecture;

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