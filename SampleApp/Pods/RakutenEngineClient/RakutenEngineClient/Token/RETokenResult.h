#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Result model for Rakuten App Engine's engine/token endpoint.
 *
 *  This class conforms to RWCURLResponseParser and can serialize an instance of itself from appropriate network data generated
 *  by a RETokenRequest.
 *
 *  @class RETokenResult RETokenResult.h <RakutenEngineClient/RETokenResult.h>
 *  @ingroup REResponses
 *  @ingroup RECoreComponents
 */
RWC_EXPORT @interface RETokenResult : RWCAutoCopyableModel <RWCURLResponseParser, NSSecureCoding>

/**
 *  An access token that can be used to authorize requests if valid
 *
 *  What requests the access token can authorize (as well as when the token expires) depends on the scopes granted to the token.
 *
 *  @see scopes
 */
@property (copy, nonatomic, nullable) NSString *accessToken;

/**
 *  A refresh token that can be used with RETokenRequest to regenerate tokens
 *
 *  When valid this token may be used with RETokenResult and RERefreshTokenRequestContext to generate new tokens. When this token expires
 *  depends on what scopes were granted the receiver.
 *
 *  @see scopes
 */
@property (copy, nonatomic, nullable) NSString *refreshToken;

/**
 *  A set of NSString instances representing the permissions granted the access token
 *
 *  These scopes can be compared to RWCAppEngineScopedEndpoint conforming classes to determine if the access token is authorized to make
 *  a given request.
 */
@property (copy, nonatomic, nullable) NSSet RWC_GENERIC(NSString *) *scopes;

/**
 *  An estimated date after which the access token of the receiver will no longer be valid
 *
 *  This property, when present, represents a rough estimate as to the expiration of the access token. Developers should take into account
 *  the length of time granted by the receiver's scopes when deciding the granularity of which to consider this date accurate.
 *
 *  @note A @c nil value does not indicate an expired access token. Rather it means that a estimated expiration date could not be
 *        determined.
 *  @see accessToken
 */
@property (copy, nonatomic, nullable) NSDate *estimatedAccessTokenExpirationDate;

/**
 *  An estimated date after which the refresh token of the receiver will no longer be valid
 *
 *  This property, when present, represents a rough estimate as to the expiration of the refresh token. Developers should take into account
 *  the length of time granted by the receiver's scopes when deciding the granularity of which to consider this date accurate.
 *
 *  @note Unlike the estimated access token expiration date, this property is computed using rough estimates gleaned from the scopes
 *        property. As a result, it is less likely to be present in returned instances and is less accurate. Furthermore, a @c nil value
 *        does not indicate an expired token. Rather it means that an estimated expiration date could not be determined.
 *
 *  @see refreshToken
 */
@property (copy, nonatomic, nullable) NSDate *estimatedRefreshTokenExpirationDate;

@end

NS_ASSUME_NONNULL_END
