#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Result model for Rakuten App Engine's MemberInformation/GetPoint endpoint.
 *
 *  This class conforms to RWCURLResponseParser and can serialize an instance of itself from appropriate network data generated
 *  by a RMIGetPointRequest.
 *
 *  @class RMIPoint RMIPoint.h <RakutenMemberInformationClient/RMIPoint.h>
 *  @ingroup RMIResponses
 *  @ingroup RMICoreComponents
 */
RWC_EXPORT @interface RMIPoint : RWCAutoCopyableModel <RWCURLResponseParser>

/**
 *  The number of standard Rakuten points held by the receiver.
 */
@property (nonatomic, nullable) NSNumber *standardPoints;

/**
 *  The number of Rakuten points held by the receiver which are not currently usable but will become usable after a set period.
 *
 *  @deprecated Use futurePoints instead
 */
@property (nonatomic, nullable) NSNumber *pendingStandardPoints DEPRECATED_MSG_ATTRIBUTE("Use futurePoints instead.");

/**
 *  The number of Rakuten points held by the receiver which are not currently usable.
 *  This is the sum of SPU campaign points and pending standard points.
 */
@property (nonatomic, nullable) NSNumber *futurePoints;

/**
 *  The number of Rakuten points held by the receiver which expire after a given date.
 */
@property (nonatomic, nullable) NSNumber *timeLimitedPoints;

/**
 *  The amount of Rakuten Cash held by the receiver.
 */
@property (nonatomic, nullable) NSNumber *rakutenCash;

/**
 *  The Rakuten member rank of the receiver.
 */
@property (nonatomic) RMIProfileRank memberRank;

@end

NS_ASSUME_NONNULL_END
