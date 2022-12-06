#import <RakutenWebClientKit/RakutenWebClientKit.h>
#import <RPushPNP/RPushPNPBaseRequest.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Class for issuing requests for Rakuten App Engine's PNP/GetUnreadCount endpoint.
 *
 *  This class represents both request parameters and NSURLRequest serialization. By default #RPushPNPDefaultBaseURLString is used as the
 *  base URL.
 *
 *  @note Requests made with this class require tokens with the @c "pnp_common_getunreadcount" scope.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=240191091
 *
 *  @class RPushPNPGetUnreadCountRequest RPushPNPGetUnreadCountRequest.h <RakutenPushNotificationPlatformClient/RPushPNPGetUnreadCountRequest.h>
 */
RWC_EXPORT @interface RPushPNPGetUnreadCountRequest : RPushPNPBaseRequest<RWCURLRequestSerializable, RWCURLQueryItemSerializable, RWCAppEngineScopedEndpoint, NSCopying, NSSecureCoding>

/**
 *  The push type.
 *
 *  This is a Filter. Unread count of only pushes with the pushtype will be returned.
 */
@property (nonatomic, copy, nullable) NSString *pushType;

@end

/**
 *  Convenience methods for RPushPNPGetUnreadCountRequest
 */
@interface RPushPNPGetUnreadCountRequest (RPushPNPConvenience)

/**
 *  Convenience factory uses the initialize method of RPushPNPBaseRequest for generating a requests for getting the number of unread push notifications.
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
