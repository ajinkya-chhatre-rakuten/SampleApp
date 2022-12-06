#import <RakutenWebClientKit/RakutenWebClientKit.h>
#import <RPushPNP/RPushPNPBaseRequest.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Class for issuing requests for Rakuten App Engine's PNP/SetHistoryStatusRead and PNP/SetHistoryStatusUnread endpoints.
 *
 *  This class represents both request parameters and NSURLRequest serialization. By default #RPushPNPDefaultBaseURLString is used as the
 *  base URL.
 *
 *  @note Requests made with this class require tokens with the @c "pnp_common_sethistorystatus" scope.
 *  @see https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=252742932 and https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=275983498
 *
 *  @class RPushPNPSetHistoryStatusRequest RPushPNPSetHistoryStatusRequest.h <RPushPNP/RPushPNPSetHistoryStatusRequest.h>
 */
RWC_EXPORT @interface RPushPNPSetHistoryStatusRequest : RPushPNPBaseRequest<RWCURLRequestSerializable, RWCURLQueryItemSerializable, RWCAppEngineScopedEndpoint, NSCopying, NSSecureCoding>

/**
 *  The request identifier, if it is not passed, all history records for the deviceId/easyId/globalId/userId will be updated.
 */
@property (copy, nonatomic, nullable) NSString *requestIdentifier;

/**
 *  The mark to specify read or unread.
 */
@property (nonatomic) BOOL markAsRead;

/**
 *  The push type.
 *
 *  This is a Filter. If provided, the status of the pushes with the pushType will be set to 'read' or 'unread'.
 */
@property (nonatomic, copy, nullable) NSString *pushType;

/**
 *  The register date start.
 *
 *  This is a Filter. If provided, the status of the pushes scheduled to sent on this date and onwards will be set to 'read' or 'unread'.
 */
@property (nonatomic, copy, nullable) NSDate *registerDateStart;

/**
 *  The register date end.
 *
 *  This is a Filter. If provided, the status of the pushes scheduled to sent before this date will be set to 'read' or 'unread'.
 */
@property (nonatomic, copy, nullable) NSDate *registerDateEnd;

@end

/**
 *  Convenience methods for RPushPNPSetHistoryStatusRequest.
 */
@interface RPushPNPSetHistoryStatusRequest (RPushPNPConvenience)

/**
 *  Convenience factory uses the initialize method of RPushPNPBaseRequest for generating a request to set status of history record.
 *
 *  @see RPushPNPBaseRequest::initWithAccessToken:pnpClientIdentifier:pnpClientSecret:deviceIdentifer:
 *
 *  @param accessToken          The OAuth2 token of Rakuten App Engine. Rakuten App Engine supports both Rakuten login user and guest user.
 *  @param pnpClientIdentifier  The client identifier to distinguish pnp client.
 *  @param pnpClientSecret      The password of pnp client.
 *  @param deviceToken          The device token of APNs(Apple Push Notification Service), as obtained
 *                              in the `-application:didRegisterForRemoteNotificationsWithDeviceToken:` method of the
 *                              application delegate.
 *  @param markAsRead           The mark to specify read or unread.
 *
 *  @return An initialized instance of the receiver.
 */
+ (instancetype)requestWithAccessToken:(NSString *)accessToken
                   pnpClientIdentifier:(NSString *)pnpClientIdentifier
                       pnpClientSecret:(NSString *)pnpClientSecret
                           deviceToken:(NSData *)deviceToken
                            markAsRead:(BOOL)markAsRead;

@end

NS_ASSUME_NONNULL_END
