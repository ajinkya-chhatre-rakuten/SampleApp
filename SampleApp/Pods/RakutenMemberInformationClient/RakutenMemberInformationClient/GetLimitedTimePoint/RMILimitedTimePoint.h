#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *	Model for requirements to get user's time point info.
 *	@class RMITermPointInfo RMILimitedTimePoint.h <RakutenMemberInformationClient/RMILimitedTimePoint.h>
 */
RWC_EXPORT @interface RMITermPointInfo : RWCAutoCopyableModel

/**
 *	The Total number of limited time points that the user has
 */
@property (nonatomic, nullable)	NSNumber	*termPoint;

/**
 *	Date that the limited time points expire
 */
@property (nonatomic, nullable)	NSDate	*termEnd;

@end

/**
 *  Result model for Rakuten App Engine's MemberInformation/GetLimitedTimePoint endpoint.
 *
 *  This class conforms to RWCURLResponseParser and can serialize an instance of itself from appropriate network data generated
 *  by a RMIGetPointRequest.
 *
 *  @class RMILimitedTimePoint RMILimitedTimePoint.h <RakutenMemberInformationClient/RMILimitedTimePoint.h>
 *  @ingroup RMIResponses
 *  @ingroup RMICoreComponents
 */
RWC_EXPORT @interface RMILimitedTimePoint : RWCAutoCopyableModel <RWCURLResponseParser>

/**
 *  The Total number of limited time points held by the user.
 */
@property (nonatomic, nullable)	NSNumber	*termPointTotal;

/**
 *	Returns "true" if user has additional limited term points that are not returned by the API
 */
@property (nonatomic)				BOOL		truncated;

/**
 *	The RMITermPointInfo Object array
 */
@property (nonatomic, nullable)	NSArray	*termPointInfo;

@end

NS_ASSUME_NONNULL_END
