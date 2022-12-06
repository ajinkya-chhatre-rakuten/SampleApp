#import <RakutenWebClientKit/RakutenWebClientKit.h>
#import <RPushPNP/RPushPNPBaseRequest.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Class for issuing requests for Rakuten App Engine's PNP/UpdateDenyType endpoint.
 *
 *  This class represents both request parameters and NSURLRequest serialization. By default #RPushPNPDefaultBaseURLString is used as the
 *  base URL.
 *
 *  @note Requests made with this class require tokens with the @c "pnp_ios_denytype_update" scope.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=48149390
 *
 *  @class RPushPNPSetDenyTypeRequest RPushPNPSetDenyTypeRequest.h <RPushPNP/RPushPNPSetDenyTypeRequest.h>
 */
RWC_EXPORT @interface RPushPNPSetDenyTypeRequest : RPushPNPBaseRequest<RWCURLRequestSerializable, RWCURLQueryItemSerializable, RWCAppEngineScopedEndpoint>

/**
 *  The filter to specify each Type is denied(1) or acceptable(0).
 */
@property (copy, nonatomic) NSDictionary *pushFilter;
@end

/**
 *  Convenience methods for RPushPNPGetDenyTypeRequest
 */
@interface RPushPNPSetDenyTypeRequest (RPushPNPConvenience)

/**
 *  Convenience factory uses the initialize method of RPushPNPBaseRequest for generating a request for setting denied or acceptable types.
 *
 *  @see RPushPNPBaseRequest::initWithAccessToken:pnpClientIdentifier:pnpClientSecret:deviceIdentifer:
 *
 *  @param accessToken          The OAuth2 token of Rakuten App Engine. Rakuten App Engine supports both Rakuten login user and guest user.
 *  @param pnpClientIdentifier  The client identifier to distinguish pnp client.
 *  @param pnpClientSecret      The password of pnp client.
 *  @param pushFilter           The filter to specify each Type is denied(1) or acceptable(0).
 *
 *  @return An initialized instance of the receiver
 */
+ (instancetype)requestWithAccessToken:(NSString *)accessToken
                   pnpClientIdentifier:(NSString *)pnpClientIdentifier
                       pnpClientSecret:(NSString *)pnpClientSecret
                            pushFilter:(NSDictionary *)pushFilter;

@end

NS_ASSUME_NONNULL_END
