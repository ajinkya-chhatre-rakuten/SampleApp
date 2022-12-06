#import "RakutenMemberInformationClient.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

static RMICreditCard *create_result_from_json(NSDictionary *JSON)
{
    @try
    {
        RMICreditCard *creditCard = [[RMICreditCard alloc] init];
        creditCard.issuerName = [RWCParserUtilities stringWithObject:JSON[@"cardName"]];
        creditCard.ownerName = [RWCParserUtilities stringWithObject:JSON[@"cardOwner"]];
        creditCard.number = [RWCParserUtilities stringWithObject:JSON[@"cardNumber"]];
        
        NSString *expirationDateString = [RWCParserUtilities stringWithObject:JSON[@"cardExp"]];
        if (expirationDateString)
        {
            NSArray *expirationComponents = [expirationDateString componentsSeparatedByString:@"/"];
            NSDateComponents *components = [NSDateComponents new];
            components.year = [expirationComponents[0] integerValue];
            components.month = [expirationComponents[1] integerValue];
            
            creditCard.expirationDateComponents = components;
        }
        
        return creditCard;
    }
    @catch (NSException *exception)
    {
        return nil;
    }
}

@implementation RMICreditCard

+ (void)parseURLResponse:(NSURLResponse *)response
                    data:(NSData *)data
                   error:(NSError *)error
         completionBlock:(void (^)(id, NSError *))completionBlock
{
    [RWCAppEngineResponseParser parseURLResponse:response data:data error:error completionBlock:^(id parsedResult, NSError *parsedError) {
        RMICreditCard *result = nil;
        if (parsedResult)
        {
            result = create_result_from_json(parsedResult);
            if (!result)
            {
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

#pragma clang diagnostic pop
