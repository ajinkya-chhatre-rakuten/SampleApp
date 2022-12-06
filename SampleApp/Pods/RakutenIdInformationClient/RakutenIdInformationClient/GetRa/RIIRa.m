/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import "RakutenIdInformationClient.h"

@implementation RIIRa

+ (void)parseURLResponse:(NSURLResponse *)response
                    data:(NSData *)data
                   error:(NSError *)error
         completionBlock:(void (^)(id, NSError *))completionBlock
{
    [RWCAppEngineResponseParser parseURLResponse:response data:data error:error completionBlock:^(id parsedResult, NSError *parsedError) {
        RIIRa *result = nil;
        if (parsedResult)
        {
            @try
            {
                result = [[RIIRa alloc] init];
                result.raKey = [RWCParserUtilities stringWithObject:parsedResult[@"ra"]];
            }
            @catch (NSException *exception)
            {
                result = nil;
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Exception raised while parsing result",
                                           NSLocalizedFailureReasonErrorKey: @"Invalid server response raised an exception while parsing object."};
                parsedError = [NSError errorWithDomain:RWCAppEngineResponseParserErrorDomain
                                                  code:RWCAppEngineResponseParserErrorInvalidResponse
                                              userInfo:userInfo];
            }
        }
        completionBlock(result, parsedError);
    }];
}

@end
