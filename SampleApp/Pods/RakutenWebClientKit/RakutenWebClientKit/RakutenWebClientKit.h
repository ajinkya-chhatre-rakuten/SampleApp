/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RWCDefines.h>

/**
 *  @defgroup RWCConstants Constants
 *
 *  All Rakuten Web Client Kit constants.
 *
 *  @{
 */

/**
 *  Version number of Rakuten Web Client Kit.
 */
RWC_EXPORT double RakutenWebClientKitVersionNumber;

/**
 *  Version string of Rakuten Web Client Kit
 */
RWC_EXPORT const unsigned char RakutenWebClientKitVersionString[];

/**
 *  @}
 */

/**
 *  @defgroup RWCCoreComponents Core Components
 *
 *  Collection of core classes and protocols that make up Rakuten Web Client Kit
 */
#import <RakutenWebClientKit/RWCURLRequestConfiguration.h>
#import <RakutenWebClientKit/RWCURLRequestSerializable.h>
#import <RakutenWebClientKit/RWCURLResponseParser.h>
#import <RakutenWebClientKit/RWClient.h>

/**
 *  @defgroup RWCAppEngine Rakuten App Engine (RAE) Utilities
 *
 *  Utilities specific for interacting with Rakuten App Engine (RAE) services
 */
#import <RakutenWebClientKit/RWCAppEngineScopedEndpoint.h>
#import <RakutenWebClientKit/RWCAppEngineResponseParser.h>

/**
 *  @defgroup RWCUtilities Utilities
 *
 *  General utilities for interacting with Rakuten web services
 */
#import <RakutenWebClientKit/RWCParserUtilities.h>
#import <RakutenWebClientKit/RWCAutoCopyableModel.h>
#import <RakutenWebClientKit/RWCURLQueryItem.h>
#import <RakutenWebClientKit/RWCURLQueryItemSerializable.h>
#import <RakutenWebClientKit/RWCURLSessionTaskOperation.h>

