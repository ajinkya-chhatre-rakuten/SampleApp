#import <RakutenWebClientKit/RakutenWebClientKit.h>
#import <RPushPNP/RPushPNPConstants.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Model of a record in response to GetPushedHistoryRequest
 *
 *  @class RPushPNPHistoryRecordModel RPushPNPHistoryData.h <RPushPNP/RPushPNPHistoryData.h>
 */
RWC_EXPORT @interface RPushPNPHistoryRecordModel : RWCAutoCopyableModel

/**
 *  The request identifier.
 */
@property (copy, nonatomic) NSString *requestIdentifier;

/**
 *  The device name.
 */
@property (copy, nonatomic, nullable) NSString *deviceName;

/**
 *  The registration date.
 */
@property (copy, nonatomic) NSDate *registrationDate;

/**
 *  The device family, iOS or android or metro.
 */
@property (copy, nonatomic) NSString *deviceFamily;

/**
 *  The status of target history record
 */
@property (nonatomic) RPushPNPHistoryRecordStatus status;

/**
 *  The alert message.
 */
@property (copy, nonatomic, nullable) NSString *alertMessage;

/**
 *  The badge number.
 */
@property (copy, nonatomic, nullable) NSNumber *badgeNumber;

/**
 *  The sound name.
 */
@property (copy, nonatomic, nullable) NSString *soundName;

/**
 *  The custom data.
 */
@property (copy, nonatomic, nullable) NSDictionary<NSString *, id> *customKeyedValues;

/**
 *  The data of history record.
 */
@property (copy, nonatomic, nullable) NSDictionary<NSString *, id> *data;

/**
 *  The push type.
 */
@property (copy, nonatomic, nullable) NSString *pushType;

@end

/**
 *  Result model for Rakuten App Engine's PNP/GetPushedHistory endpoint.
 *
 *  This class conforms to RWCURLResponseParser and can serialize an instance of itself from appropriate network data generated by a RPushPNPGetPushedHistoryRequest.
 *
 *  @class RPushPNPHistoryData RPushPNPHistoryData.h <RPushPNP/RPushPNPHistoryData.h>
 */
@interface RPushPNPHistoryData : RWCAutoCopyableModel <RWCURLResponseParser>

/**
 *  An array of history records
 */
@property (copy, nonatomic, readonly, nullable) NSArray<RPushPNPHistoryRecordModel *> *records;

@end

NS_ASSUME_NONNULL_END
