#import <RakutenWebClientKit/RakutenWebClientKit.h>
#import <RPushPNP/RPushPNPBaseRequest.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Class for issuing requests for Rakuten App Engine's PNP/RegisterDevice endpoint.
 *
 *  This class represents both request parameters and NSURLRequest serialization. By default #RPushPNPDefaultBaseURLString is used as the
 *  base URL.
 *
 *  @note Requests made with this class require tokens with the @c "pnp_ios_register" scope.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=48149359
 *
 *  @class RPushPNPRegisterDeviceRequest RPushPNPRegisterDeviceRequest.h <RPushPNP/RPushPNPRegisterDeviceRequest.h>
 */
RWC_EXPORT @interface RPushPNPRegisterDeviceRequest : RPushPNPBaseRequest<RWCURLRequestSerializable, RWCURLQueryItemSerializable, RWCAppEngineScopedEndpoint>

/**
 *  The device name.
 */
@property (copy, nonatomic, nullable) NSString *deviceName;

/**
 *  The segment information to distinguish user
 *
 *  @attention
 *  Since  v2.1.0 of this SDK `options` are sent as a JSON object to the backend.
 *  Therefore you must set your data types explicitly
 *  e.g. `["option1": "some_string", "option2": true]` in Swift; `@{@"option1": @"some_string", @"option2": @YES}` in Obj-C.
 *  The PNP backend will no longer perform any data type conversion. See https://confluence.rakuten-it.com/confluence/display/PNPD/Device+Opts+Pitfall for details.
 */
@property (copy, nonatomic, nullable) NSDictionary *options;

/**
 *  The RAnalytics RP Cookie.
 */
@property (strong, nonatomic, nullable) NSHTTPCookie *rpCookie;

@end

/**
 *  Convenience methods for RPushPNPRegisterDeviceRequest
 */
@interface RPushPNPRegisterDeviceRequest (RPushPNPConvenience)

/**
 *  Convenience factory uses the initialize method of RPushPNPBaseRequest for generating a request for registering device to PushNotificationPlatform.
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
