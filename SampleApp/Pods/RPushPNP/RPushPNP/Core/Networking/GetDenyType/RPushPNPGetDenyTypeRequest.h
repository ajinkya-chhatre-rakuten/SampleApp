#import <RakutenWebClientKit/RakutenWebClientKit.h>
#import <RPushPNP/RPushPNPBaseRequest.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Class for issuing requests for Rakuten App Engine's PNP/CheckDenyType endpoint.
 *
 *  This class represents both request parameters and NSURLRequest serialization. By default #RPushPNPDefaultBaseURLString is used as the
 *  base URL.
 *
 *  @note Requests made with this class require tokens with the @c "pnp_ios_denytype_check" scope.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=48149409
 *
 *  @class RPushPNPGetDenyTypeRequest RPushPNPGetDenyTypeRequest.h <RPushPNP/RPushPNPGetDenyTypeRequest.h>
 */
RWC_EXPORT @interface RPushPNPGetDenyTypeRequest : RPushPNPBaseRequest<RWCURLRequestSerializable, RWCURLQueryItemSerializable, RWCAppEngineScopedEndpoint>

@end

/**
 *  Convenience methods for RPushPNPGetDenyTypeRequest
 */
@interface RPushPNPGetDenyTypeRequest (RPushPNPConvenience)

/**
 *  Convenience factory uses the initialize method of RPushPNPBaseRequest for generating a request for getting denied or acceptable types.
 *
 *  @see RPushPNPBaseRequest::initWithAccessToken:pnpClientIdentifier:pnpClientSecret:deviceIdentifer:
 *
 *  @param accessToken          The OAuth2 token of Rakuten App Engine. Rakuten App Engine supports both Rakuten login user and guest user.
 *  @param pnpClientIdentifier  The client identifier to distinguish pnp client.
 *  @param pnpClientSecret      The password of pnp client.
 *
 *  @return An initialized instance of the receiver
 */
+ (instancetype)requestWithAccessToken:(NSString *)accessToken
                   pnpClientIdentifier:(NSString *)pnpClientIdentifier
                       pnpClientSecret:(NSString *)pnpClientSecret;

@end

NS_ASSUME_NONNULL_END
