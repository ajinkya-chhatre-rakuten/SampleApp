#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Result model for Rakuten App Engine's MemberInformation/GetName endpoint, as well as general Japan Ichiba member name information.
 *
 *  This class conforms to RWCURLResponseParser and can serialize an instance of itself from appropriate network data generated
 *  by a RMIGetNameRequest.
 *
 *  @class RMINameResult RMINameResult.h <RakutenMemberInformationClient/RMINameResult.h>
 *  @ingroup RMIResponses
 *  @ingroup RMICoreComponents
 */
RWC_EXPORT @interface RMIName : RWCAutoCopyableModel <RWCURLResponseParser>

/**
 *  The first name of the receiver
 */
@property (copy, nonatomic, nullable) NSString *firstName;

/**
 *  The last name of the receiver
 */
@property (copy, nonatomic, nullable) NSString *lastName;

/**
 *  The nickname of the receiver
 */
@property (copy, nonatomic, nullable) NSString *nickname;

/**
 *  The katakana representation of the receiver's first name
 */
@property (copy, nonatomic, nullable) NSString *firstNameKatakana;

/**
 *  The katakana representation of the receiver's last name
 */
@property (copy, nonatomic, nullable) NSString *lastNameKatakana;

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
