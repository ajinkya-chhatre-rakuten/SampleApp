#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  @defgroup RMIConstants Constants
 *
 *  All constants defined in the RakutenMemberInformationClient library
 *
 *  @{
 */

/**
 *  Version number of the RakutenMemberInformationClient library
 */
RWC_EXPORT double RakutenMemberInformationClientVersionNumber;

/**
 *  Version string of the RakutenMemberInformationClient library
 */
RWC_EXPORT const unsigned char RakutenMemberInformationClientVersionString[];

/**
 *  String for the default base URL used by request classes defined in this library
 *
 *  This defaults to https://app.rakuten.co.jp
 */
RWC_EXPORT NSString *const RMIDefaultBaseURLString;

/**
 *  Domain for errors generated by the RakutenMemberInformationClient library
 */
RWC_EXPORT NSString *const RMIErrorDomain;

/**
 *  Key used in the userInfo dictionary of NSErrors to generated with the RMIErrorDomain to extract response objects
 *
 *  @note The returned response object may be partially parsed. No guarantees are made on the type of the response object, so while this
 *  key can be useful in debugging a failing request it should generally not be displayed to the end user.
 */
RWC_EXPORT NSString *const RMIErrorResponseObjectKey;

/**
 *  Enumeration of errors defined in the RakutenMemberInformationClient library
 *
 *  Errors with this code will have the #RMIErrorDomain domain.
 */
typedef NS_ENUM(NSInteger, RMIError)
{
    /**
     *  Error generated when the response code indicates an error.
     *
     *  Errors of this type will have the #RMIErrorResponseObjectKey of their userInfo dictionary filled.
     *
     *  @note This error is specifically used in RMIRank parsed network responses. Standard status code or other conventional RAE
     *        errors will continue to use their domains and error codes.
     */
    RMIErrorInvalidResponseCode = 7000
};


/**
 *  Enumeration of the genders defined by Rakuten App Engine's MemberInformation service
 *
 *  @enum RMIProfileGender
 */
typedef NS_ENUM(NSInteger, RMIProfileGender)
{
    /**
     *  Gender information not provided
     */
    RMIProfileGenderUndefined = 0,
    /**
     *  Male gender
     */
    RMIProfileGenderMale,
    /**
     *  Female gender
     */
    RMIProfileGenderFemale
};

/**
 *  Enumeration of the Rakuten member ranks defined by Rakuten App Engine's MemberInformation service
 *
 *  @enum RMIProfileRank
 */
typedef NS_ENUM(NSInteger, RMIProfileRank)
{
    /**
     *  Rank information not provided
     */
    RMIProfileRankUndefined = 0,
    /**
     *  Regular rank member
     */
    RMIProfileRankRegular,
    /**
     *  Silver rank member
     */
    RMIProfileRankSilver,
    /**
     *  Gold rank member
     */
    RMIProfileRankGold,
    /**
     *  Platinum rank member
     */
    RMIProfileRankPlatinum,
    /**
     *  Diamond rank member
     */
    RMIProfileRankDiamond
};

/**
 *  @}
 */

NS_ASSUME_NONNULL_END