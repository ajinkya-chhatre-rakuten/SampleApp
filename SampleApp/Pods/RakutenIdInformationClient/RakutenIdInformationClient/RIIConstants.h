/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  @defgroup RIIConstants Constants
 *
 *  All constants defined in the RakutenIdInformationClient library
 *
 *  @{
 */

/**
 *  Version number of the RakutenIdInformationClient library
 */
RWC_EXPORT double RakutenIdInformationClientVersionNumber;

/**
 *  Version string of the RakutenIdInformationClient library
 */
RWC_EXPORT const unsigned char RakutenIdInformationClientVersionString[];

/**
 *  String for the default base URL used by request classes defined in this library
 *
 *  This defaults to https://app.rakuten.co.jp
 */
RWC_EXPORT NSString *const RIIDefaultBaseURLString;

NS_ASSUME_NONNULL_END