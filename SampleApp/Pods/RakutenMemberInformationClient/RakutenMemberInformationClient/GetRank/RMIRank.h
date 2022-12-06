#import <RakutenWebClientKit/RakutenWebClientKit.h>
#import <RakutenMemberInformationClient/RMIConstants.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Model for requirements to reach a targeted Rakuten Ichiba rank.
 *
 *  @note This model is not exhaustive of requirements for reaching a desired rank. For example, #RMIProfileRankDiamond requires the user
 *        have a Rakuten credit card.
 *
 *  @class RMIRankRequirements RMIRank.h <RakutenMemberInformationClient/RMIRank.h>
 */
RWC_EXPORT @interface RMIRankRequirements : RWCAutoCopyableModel

/**
 *  The rank which the receiver targets.
 */
@property (nonatomic) RMIProfileRank targetRank;

/**
 *  The number of purchases which must be made to attain the targetRank.
 */
@property (nonatomic, nullable) NSNumber *numberOfPurchases;

/**
 *  The number of Rakuten points which must be acquired to attain the targetRank.
 */
@property (nonatomic, nullable) NSNumber *numberOfPoints;

@end

/**
 *  Result model for Rakuten App Engine's MemberInformation/GetRank endpoint.
 *
 *  This class conforms to RWCURLResponseParser and can serialize an instance of itself from appropriate network data generated
 *  by a RMIGetRankRequest.
 *
 *  @class RMIRank RMIRank.h <RakutenMemberInformationClient/RMIRank.h>
 *  @ingroup RMIResponses
 *  @ingroup RMICoreComponents
 */
RWC_EXPORT @interface RMIRank : RWCAutoCopyableModel <RWCURLResponseParser>

/**
 *  The current Rakuten Ichiba rank of the receiver.
 */
@property (nonatomic) RMIProfileRank currentRank;

/**
 *  The current number of purchases made by the receiver.
 *
 *  This can be compared with the requirements of RMIRankRequirements::numberOfPurchases to determine if enough purchases have been
 *  made by the receiver to attain the target rank.
 */
@property (nonatomic, nullable) NSNumber *currentNumberOfPurchases;

/**
 *  The current number of Rakuten points acquired by the receiver.
 *
 *  This can be compared with the requirements of RMIRankRequirements::numberOfPoints to determine if enough Rakuten points have been
 *  acquired by the receiver to attain the target rank.
 */
@property (nonatomic, nullable) NSNumber *currentNumberOfAcquiredPoints;

/**
 *  Defines the requirements for maintaining the receiver's currentRank.
 */
@property (nonatomic, nullable) RMIRankRequirements *currentRankRequirements;

/**
 *  Provides the projected RMIProfileRank for the next month as well as the requirements for achieving that rank.
 */
@property (nonatomic, nullable) RMIRankRequirements *projectedRankRequirements;

/**
 *  Provides the rank above currentRank as wel as the requirements for achieving that rank.
 *
 *  @note When the receiver is serialized from network data this property will be nil if the currentRank is #RMIProfileRankDiamond since
 *        currently there is no higher rank.
 */
@property (nonatomic, nullable) RMIRankRequirements *higherRankRequirements;

/**
 *  The number of months the receiver has maintained their currentRank.
 */
@property (nonatomic, nullable) NSNumber *monthsCurrentRankHasBeenHeld;

/**
 *  YES if the receiver has a Rakuten credit card or NO if they do not or it cannot be determined.
 */
@property (nonatomic) BOOL hasRakutenCreditCard;

/**
 *  The date at which the response was issued.
 *
 *  When serialized from network data this property provides important context for all other properties of the receiver. For example,
 *  if this date points to Jan. 27, 2016, then the projectedRankRequirements refers to the rank the user is expected to have as of
 *  Feb. 1, 2016.
 */
@property (nonatomic, nullable) NSDate *responseDate;

@end

NS_ASSUME_NONNULL_END
