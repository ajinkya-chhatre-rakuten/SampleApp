#import <RakutenWebClientKit/RakutenWebClientKit.h>
#import <RPushPNP/RPushPNPBaseRequest.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Class for issuing requests for Rakuten App Engine's PNP/UnregisterDevice endpoint.
 *
 *  This class represents both request parameters and NSURLRequest serialization. By default #RPushPNPDefaultBaseURLString is used as the
 *  base URL.
 *
 *  @note Requests made with this class require tokens with the @c "pnp_ios_unregister" scope.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=48149369
 *
 *  @class RPushPNPUnregisterDeviceRequest RPushPNPUnregisterDeviceRequest.h <RPushPNP/RPushPNPUnregisterDeviceRequest.h>
 */
RWC_EXPORT @interface RPushPNPUnregisterDeviceRequest : RPushPNPBaseRequest<RWCURLRequestSerializable, RWCURLQueryItemSerializable, RWCAppEngineScopedEndpoint>

@end

/**
 *  Convenience methods for RPushPNPUnregisterDeviceRequest
 */
@interface RPushPNPUnregisterDeviceRequest (RPushPNPConvenience)

/**
 *  Convenience factory uses the initialize method of RPushPNPBaseRequest for generating a request to unregister a device with device identifier.
 *
 *  @see RPushPNPBaseRequest::initWithAccessToken:pnpClientIdentifier:pnpClientSecret:deviceIdentifer:
 *
 *  @param accessToken          The OAuth2 token of Rakuten App Engine. Rakuten App Engine supports both Rakuten login user and guest user.
 *  @param pnpClientIdentifier  The client identifier to distinguish pnp client.
 *  @param pnpClientSecret      The password of pnp client.
 *  @param deviceToken          The device token of APNs(Apple Push Notification Service), as obtained
 *                              in the `-application:didRegisterForRemoteNotificationsWithDeviceToken:` method of the
 *                              application delegate.
 *
 *  @return An initialized instance of the receiver
 */
+ (instancetype)requestWithAccessToken:(NSString *)accessToken
                   pnpClientIdentifier:(NSString *)pnpClientIdentifier
                       pnpClientSecret:(NSString *)pnpClientSecret
                           deviceToken:(NSData *)deviceToken;

@end
NS_ASSUME_NONNULL_END
