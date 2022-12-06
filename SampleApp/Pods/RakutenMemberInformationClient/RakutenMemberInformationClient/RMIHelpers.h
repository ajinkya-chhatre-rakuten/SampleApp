/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RMIHelpers : NSObject

/**
 * Try to obtain date from Object.
 *
 * @param object An object
 *
 * @return NSDate Object in the format 'yyyy-MM-dd HH:mm:ss'.
 */
RWC_EXPORT NSDate *RMIGetDateFromObject(id object);

/**
 * Try to obtain date from Object.
 *
 * @param object An object
 *
 * @return NSDate Object in the format 'yyyy-MM-dd HH:mm:ss' in Japan time zone.
 */
RWC_EXPORT NSDate *RMIGetJapanDateFromObject(id object);

/**
 * Try to obtain an NSNumber from Object.
 *
 * @param object An object
 *
 * @return NSNumber Object or nil.
 **/
RWC_EXPORT NSNumber *RMIGetUnsignedNumberFromObject(id object);

@end

NS_ASSUME_NONNULL_END
