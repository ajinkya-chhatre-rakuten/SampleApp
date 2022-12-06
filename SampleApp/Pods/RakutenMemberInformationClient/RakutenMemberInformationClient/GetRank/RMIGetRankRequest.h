#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Enumeration of endpoints supported by @ref RMIGetRankRequest.
 *
 *  @ingroup RMIConstants
 *  @enum RMIGetRankEndpoint
 *  @see RMIGetRankRequest.endpoint
 */
typedef NS_ENUM(NSInteger, RMIGetRankEndpoint)
{
    /**
     * If assigned to #endpoint, request that RMIGetRankRequest uses the deprecated `MemberInformation/GetRank` endpoint.
     * @note This endpoint requires the `memberinfo_read_rank` scope.
     */
    RMIGetRankLegacyEndpoint DEPRECATED_MSG_ATTRIBUTE("MemberInformation/GetRank is deprecated. Please migrate your application to using MemberInformation/GetRankSafe instead.") = 0,

    /**
     * If assigned to #endpoint, request that RMIGetRankRequest uses the `MemberInformation/GetRankSafe` endpoint.
     * @note This endpoint requires the `memberinfo_read_rank_safe` scope.
     */
    RMIGetRankSafeEndpoint,
};

/**
 *  Class for issuing requests for Rakuten App Engine's `MemberInformation/GetRank[Safe]` endpoints.
 *
 *  This class represents both request parameters and NSURLRequest serialization. By default #RMIDefaultBaseURLString is used as the
 *  base URL.
 *
 *  @note Requests made with this class require tokens with either the `memberinfo_read_rank` or the `memberinfo_read_rank_safe`
 *        scope, depending on what #endpoint is used.
 *
 *  @class RMIGetRankRequest RMIGetRankRequest.h <RakutenMemberInformationClient/RMIGetRankRequest.h>
 *  @ingroup RMIRequests
 *  @ingroup RMICoreComponents
 *  @see RMIGetRankEndpoint
 */
RWC_EXPORT @interface RMIGetRankRequest : NSObject <RWCURLRequestSerializable, RWCURLQueryItemSerializable, RWCAppEngineScopedEndpoint, NSCopying, NSSecureCoding>

/**
 *  Designated initializer which takes a Japan Ichiba member's access token to locate their rank information.
 *
 *  @param accessToken       The member's access token. This should not be an anonymous or client token.
 *  @param serviceIdentifier The identifier of the service requesting rank information.
 *
 *  @return An initialized instance of the receiver
 */
- (instancetype)initWithAccessToken:(NSString *)accessToken serviceIdentifier:(NSString *)serviceIdentifier NS_DESIGNATED_INITIALIZER;

/**
 *  The member access token both authorizing and identifying the Japan Ichiba member whose rank information is being requested.
 *
 *  @note This token must be permitted to the @c "memberinfo_read_rank" scope or the @c "memberinfo_read_rank_safe" scope,
 *        depending on the value of #endpoint.
 */
@property (copy, nonatomic) NSString *accessToken;

/**
 *  The identifier of the service requesting rank information.
 */
@property (copy, nonatomic) NSString *serviceIdentifier;

/**
 *  Class property. Determines what endpoint to use.
 */
@property (class, nonatomic) RMIGetRankEndpoint endpoint;

@end


/**
 *  Convenience methods for RMIGetRankRequest
 */
@interface RMIGetRankRequest (RMIConvenience)

/**
 *  Convenience factory for generating Japan Ichiba Rakuten point requests.
 *
 *  @see RMIGetRankRequest::initWithAccessToken:serviceIdentifier:
 *
 *  @param accessToken       The member's access token. This should not be an anonymous or client token.
 *  @param serviceIdentifier The identifier of the service requesting rank information.
 *
 *  @return An initialized instance of the receiver
 */
+ (instancetype)requestWithAccessToken:(NSString *)accessToken serviceIdentifier:(NSString *)serviceIdentifier;

@end

NS_ASSUME_NONNULL_END
