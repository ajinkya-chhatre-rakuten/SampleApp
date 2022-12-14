/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RWCDefines.h>
#import <RakutenWebClientKit/RWCURLResponseParser.h>

/**
 *  @addtogroup RWCConstants Constants
 *  @{
 */

/**
 *  The error domain associated with RWCAppEngineResponseParser generated errors
 */
RWC_EXPORT NSString * const RWCAppEngineResponseParserErrorDomain;

/**
 *  Errors generated by RWCAppEngineResponseParser
 *
 *  @enum RWCAppEngineResponseParserError
 */
typedef NS_ENUM(NSInteger, RWCAppEngineResponseParserError)
{
    // WARNING: Keep this in sync with RakutenAPIErrorCode, for backward compatibility

    /**
     *  Error returned when the request was unauthorized
     */
    RWCAppEngineResponseParserErrorUnauthorized = 1,
    /**
     *  Error returned when the request had invalid parameters
     */
    RWCAppEngineResponseParserErrorInvalidParameter = 2,
    /**
     *  Error returned when the requested resource was not found
     */
    RWCAppEngineResponseParserErrorResourceNotFound = 3,
    /**
     *  Error returned when the request produces a conflict in a resource
     */
    RWCAppEngineResponseParserErrorResourceConflict = 4,
    /**
     *  Error returned when response contained invalid or unexpected data
     */
    RWCAppEngineResponseParserErrorInvalidResponse = 5,
};

/**
 *  @}
 */

/**
 *  Conformer of RWCURLResponseParser for parsing network data from Rakuten App Engine (RAE) services.
 *
 *  This response parser takes network data and converts it to JSON. The response and the JSON (if available) are then inspected to find
 *  common RAE errors. If none are found, the JSON is passed as the parsed result. Otherwise the error is returned. Any errors generated
 *  by this class will fall under the #RWCAppEngineResponseParserErrorDomain error domain and have error codes from the
 *  #RWCAppEngineResponseParserError enum. However, if the parser receives an error either from the network or from prior parsing, that
 *  error will be funneled down without alteration.
 *
 *  @class RWCAppEngineResponseParser RWCAppEngineResponseParser.h <RakutenWebClientKit/RWCAppEngineResponseParser.h>
 *  @ingroup RWCAppEngine
 */
RWC_EXPORT @interface RWCAppEngineResponseParser : NSObject <RWCURLResponseParser>
@end

