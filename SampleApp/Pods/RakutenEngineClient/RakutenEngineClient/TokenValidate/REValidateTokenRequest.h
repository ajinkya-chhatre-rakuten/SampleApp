#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Class for issuing requests for Rakuten App Engine's engine/token_validate endpoint.
 *
 *  This class represents both request parameters and NSURLRequest serialization. By default #REDefaultBaseURLString is used as the
 *  base URL.
 *
 *  This API can be used to check if a token is valid (not expired) but also whether the token was granted one or more specified scopes.
 *
 *  @note Requests made with this class require access tokens with the @c \@"tokenvalidate" scope.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=222009371
 *
 *  @class RERevokeTokenRequest RERevokeTokenRequest.h <RakutenEngineToken/RERevokeTokenRequest.h>
 *  @ingroup RERequests
 *  @ingroup RECoreComponents
 */
RWC_EXPORT @interface REValidateTokenRequest : NSObject <RWCAppEngineScopedEndpoint, RWCURLQueryItemSerializable, RWCURLRequestSerializable, NSCopying, NSSecureCoding>

/**
 *  Designated initializer which takes a client's identifier and secret and an access token to validate
 *
 *  @param clientIdentifier The identifier of the client application
 *  @param clientSecret     The secret of the client application
 *  @param accessToken      An access token to validate
 *
 *  @return An initialized instance of the receiver
 */
- (instancetype)initWithClientIdentifier:(NSString *)clientIdentifier
                            clientSecret:(NSString *)clientSecret
                             accessToken:(NSString *)accessToken NS_DESIGNATED_INITIALIZER;

/**
 *  The client application's identifier
 */
@property (copy, nonatomic) NSString *clientIdentifier;

/**
 *  The client application's secret
 */
@property (copy, nonatomic) NSString *clientSecret;

/**
 *  An access token to validate
 *
 *  This access token should have the @c \@"tokenvalidate" scope associated with it.
 */
@property (copy, nonatomic) NSString *accessToken;

/**
 *  A set of NSString instances identifying permissions that should be queried
 *
 *  @note The scopes are validated together, meaning that if the access token does not have access to any of the individual specified
 *        scopes, the token will be considered invalid.
 *
 *  These strings are defined per web-service. If using a RakutenWebClientKit based library, requests requiring scopes are identified by
 *  the RWCAppEngineScopedEndpoint protocol.
 */
@property (copy, nonatomic, nullable) NSSet *scopes;

@end


/**
 *  Convenience methods for REValidateTokenRequest
 */
@interface REValidateTokenRequest (REConvenience)

/**
 *  Convenience factory for generating validate-token requests
 *
 *  @param clientIdentifier The identifier of the client application
 *  @param clientSecret     The secret of the client application
 *  @param accessToken      An access token to validate
 *
 *  @return An initialized instance of the receiver
 */
+ (instancetype)requestWithClientIdentifier:(NSString *)clientIdentifier
                               clientSecret:(NSString *)clientSecret
                                accessToken:(NSString *)accessToken;

@end

NS_ASSUME_NONNULL_END
