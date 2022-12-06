#import "RakutenMemberInformationClient.h"

@implementation RMIPoint

+ (void)parseURLResponse:(NSURLResponse *)response
                    data:(NSData *)data
                   error:(NSError *)error
         completionBlock:(void (^)(id, NSError *))completionBlock
{
    [RWCAppEngineResponseParser parseURLResponse:response data:data error:error completionBlock:^(NSDictionary *RAEResult, NSError *RAEError) {
        RMIPoint *result = nil;
        if (RAEResult)
        {
            @try
            {
                result = [[self alloc] init];
                
                int64_t standardPoints = [RWCParserUtilities integerWithObject:RAEResult[@"fixedPoint"]];
                if (standardPoints != INT64_MAX)
                {
                    result.standardPoints = @(standardPoints);
                }
                
                int64_t futurePoints = [RWCParserUtilities integerWithObject:RAEResult[@"futurePoint"]];
                if (futurePoints != INT64_MAX)
                {
                    result.futurePoints = @(futurePoints);
                }
                
                int64_t timeLimitedPoints = [RWCParserUtilities integerWithObject:RAEResult[@"limitedPoint"]];
                if (timeLimitedPoints != INT64_MAX)
                {
                    result.timeLimitedPoints = @(timeLimitedPoints);
                }
                
                int64_t rakutenCash = [RWCParserUtilities integerWithObject:RAEResult[@"cash"]];
                if (rakutenCash != INT64_MAX)
                {
                    result.rakutenCash = @(rakutenCash);
                }
                
                int64_t rankInteger = [RWCParserUtilities integerWithObject:RAEResult[@"rank"]];
                switch (rankInteger)
                {
                    case 1:
                        result.memberRank = RMIProfileRankRegular;
                        break;
                    case 2:
                        result.memberRank = RMIProfileRankSilver;
                        break;
                    case 3:
                        result.memberRank = RMIProfileRankGold;
                        break;
                    case 4:
                        result.memberRank = RMIProfileRankPlatinum;
                        break;
                    case 5:
                        result.memberRank = RMIProfileRankDiamond;
                        break;
                    default:
                        result.memberRank = RMIProfileRankUndefined;
                        break;
                }
            }
            @catch (NSException *exception)
            {
                result = nil;
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Exception raised while parsing result",
                                           NSLocalizedFailureReasonErrorKey: exception.reason ?: @"Invalid server response raised an exception while parsing object."};
                RAEError = [NSError errorWithDomain:RWCAppEngineResponseParserErrorDomain
                                               code:RWCAppEngineResponseParserErrorInvalidResponse
                                           userInfo:userInfo];
            }
        }
        completionBlock(result, RAEError);
    }];
}

@end
