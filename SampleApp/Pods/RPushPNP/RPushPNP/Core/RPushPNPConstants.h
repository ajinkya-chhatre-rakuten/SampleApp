#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  @defgroup RPushPNPConstants Constants
 *
 *  All constants defined in the RPushPNP library.
 *
 *  @{
 */

/**
 *  String for the default base URL used by request classes defined in this library.
 *
 *  This is https://app.rakuten.co.jp
 */
RWC_EXPORT NSString *const RPushPNPDefaultBaseURLString;

/**
 *  String for the default base URL used by request classes defined in this library.
 *
 *  This is https://gateway-api.global.rakuten.com
 */
RWC_EXPORT NSString *const RPushPNPDefaultAPICBaseURLString;

/**
 * Enumeration of status of each record in history data defined by Rakuten App Engine's PushNotificationPlatform service.
 *
 * @enum RPushPNPHistoryRecordStatus
 */
typedef NS_ENUM(NSUInteger, RPushPNPHistoryRecordStatus) {
    /**
     * Notification is unread. Default value.
     */
    RPushPNPHistoryRecordStatusUnread = 0,

    /**
     * Notification has been opened.
     */
    RPushPNPHistoryRecordStatusOpen,

    /**
     * Notification has been read.
     */
    RPushPNPHistoryRecordStatusRead,
};

/**
 *  @}
 */

NS_ASSUME_NONNULL_END
