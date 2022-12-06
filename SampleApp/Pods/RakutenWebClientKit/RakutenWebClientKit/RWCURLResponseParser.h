/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import <RakutenWebClientKit/RWCDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol whose conformers can parse arbitrary network data into concrete and useful results.
 *
 *  @protocol RWCURLResponseParser RWCURLResponseParser.h <RakutenWebClientKit/RWCURLResponseParser.h>
 *  @ingroup RWCCoreComponents
 */
@protocol RWCURLResponseParser

/**
 *  Parses network response data into results.
 *
 *  This method is not required to resolve synchronously, but the given completion block must be executed at some point.
 *
 *  @param response        The network response object. This can usually be cast to an NSHTTPURLResponse object.
 *  @param data            The network data
 *  @param error           Any network error
 *  @param completionBlock A completion block which must be executed by the receiver when the network response has finished parsing. The
 *                         block takes an arbitrary result object upon success or an error upon failure.
 */
+ (void)parseURLResponse:(nullable NSURLResponse *)response
                    data:(nullable NSData *)data
                   error:(nullable NSError *)error
         completionBlock:(void (^)(id __nullable parsedResult, NSError *__nullable parsedError))completionBlock;

@end

NS_ASSUME_NONNULL_END

