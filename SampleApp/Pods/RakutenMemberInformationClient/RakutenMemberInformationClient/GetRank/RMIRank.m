#import "RakutenMemberInformationClient.h"

static NSDate *get_date_from_object(id object)
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en-US"];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });
    
    NSString *dateString = [RWCParserUtilities stringWithObject:object];
    return [formatter dateFromString:dateString];
}

static NSNumber *get_unsigned_number_from_object(id object)
{
    uint64_t number = [RWCParserUtilities unsignedIntegerWithObject:object];
    return (number != UINT64_MAX) ? @(number) : nil;
}

static RMIProfileRank get_rank_from_object(id object)
{
    int64_t rankInteger = [RWCParserUtilities integerWithObject:object];
    switch (rankInteger)
    {
        case 1:
            return RMIProfileRankRegular;
        case 2:
            return RMIProfileRankSilver;
        case 3:
            return RMIProfileRankGold;
        case 4:
            return RMIProfileRankPlatinum;
        case 5:
            return RMIProfileRankDiamond;
        default:
            return RMIProfileRankUndefined;
    }
}

static void populate_rank_result_with_json(RMIRank *result, NSDictionary *JSON)
{
    result.currentRank = get_rank_from_object(JSON[@"rank_id"]);
    result.currentNumberOfPurchases = get_unsigned_number_from_object(JSON[@"c_gauge"]);
    result.currentNumberOfAcquiredPoints = get_unsigned_number_from_object(JSON[@"p_gauge"]);
    
    RMIRankRequirements *currentRankRequirements = [RMIRankRequirements new];
    currentRankRequirements.targetRank = result.currentRank;
    currentRankRequirements.numberOfPurchases = get_unsigned_number_from_object(JSON[@"c_retain_threshold"]);
    currentRankRequirements.numberOfPoints = get_unsigned_number_from_object(JSON[@"p_retain_threshold"]);
    result.currentRankRequirements = currentRankRequirements;
    
    RMIRankRequirements *projectedRankRequirements = [RMIRankRequirements new];
    projectedRankRequirements.targetRank = get_rank_from_object(JSON[@"next_month_rank_id"]);
    projectedRankRequirements.numberOfPurchases = get_unsigned_number_from_object(JSON[@"c_next_threshold"]);
    projectedRankRequirements.numberOfPoints = get_unsigned_number_from_object(JSON[@"p_next_threshold"]);
    result.projectedRankRequirements = projectedRankRequirements;
    
    RMIProfileRank higherRank = get_rank_from_object(JSON[@"higher_rank_id"]);
    if (higherRank != RMIProfileGenderUndefined)
    {
        RMIRankRequirements *higherRankRequirements = [RMIRankRequirements new];
        higherRankRequirements.targetRank = higherRank;
        higherRankRequirements.numberOfPurchases = get_unsigned_number_from_object(JSON[@"c_higher_threshold"]);
        higherRankRequirements.numberOfPoints = get_unsigned_number_from_object(JSON[@"p_higher_threshold"]);
        result.higherRankRequirements = higherRankRequirements;
    }
    
    result.monthsCurrentRankHasBeenHeld = get_unsigned_number_from_object(JSON[@"keep_months"]);
    result.hasRakutenCreditCard = [RWCParserUtilities unsignedIntegerWithObject:JSON[@"card_status"]] == 1;
    result.responseDate = get_date_from_object(JSON[@"res_time"]);
}

@implementation RMIRankRequirements
@end

@implementation RMIRank

+ (void)parseURLResponse:(NSURLResponse *)response
                    data:(NSData *)data
                   error:(NSError *)error
         completionBlock:(void (^)(id, NSError *))completionBlock
{
    [RWCAppEngineResponseParser parseURLResponse:response data:data error:error completionBlock:^(NSDictionary *RAEResult, NSError *RAEError) {
        RMIRank *result = nil;
        
        if (RAEResult)
        {
            @try
            {
                NSArray *dataArray = RAEResult[@"data"];
                NSDictionary *JSON = dataArray.firstObject;
                
                // This API is different in that it only seems to use a buried "result_code" key to determine success
                uint64_t resultCode = [RWCParserUtilities unsignedIntegerWithObject:JSON[@"result_code"]];
                if (resultCode != 0)
                {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Invalid result code",
                                               NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Response contained non-zero result code (%@)", JSON[@"result_code"]],
                                               RMIErrorResponseObjectKey: RAEResult};
                    RAEError = [NSError errorWithDomain:RMIErrorDomain code:RMIErrorInvalidResponseCode userInfo:userInfo];
                }
                else
                {
                    result = [[self alloc] init];
                    populate_rank_result_with_json(result, JSON);
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
