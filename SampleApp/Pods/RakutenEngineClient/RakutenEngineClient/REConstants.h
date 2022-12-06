#import <RakutenWebClientKit/RakutenWebClientKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  @defgroup RGMIConstants Constants
 *
 *  All constants defined in the Rakuten Global Member Information Client library
 *
 *  @{
 */

/**
 *  Version number of the Rakuten Engine Client library
 */
RWC_EXPORT double RakutenEngineClientVersionNumber;

/**
 *  Version string of the Rakuten Engine Client library
 */
RWC_EXPORT const unsigned char RakutenEngineClientVersionString[];

/**
 *  String for the default base URL used by request classes defined in this library
 *
 *  This defaults to https://app.rakuten.co.jp
 */
RWC_EXPORT NSString *REDefaultBaseURLString;

/**
 *  Enumeration of possible lifespans for access and refresh tokens produced by Rakuten App Engine
 *
 *  @enum RETokenLifespan
 */
typedef NS_ENUM(NSInteger, RETokenLifespan)
{
    /**
     *  Token lifespan not specified or set to a custom value not covered by the enumerated values
     */
    RETokenLifespanCustom = 0,
    /**
     *  365 day token lifespan
     */
    RETokenLifespan365Days,
    /**
     *  90 day token lifespan
     */
    RETokenLifespan90Days,
    /**
     *  1 hour token lifespan
     */
    RETokenLifespan1Hour
};

/**
 *  @}
 */

NS_ASSUME_NONNULL_END
