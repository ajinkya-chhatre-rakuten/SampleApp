#import "RakutenMemberInformationClient.h"

@implementation RMIName

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDictionary
{
    NSParameterAssert(JSONDictionary);
    
    if ((self = [super init]))
    {
        @try
        {
            _firstName = [RWCParserUtilities stringWithObject:JSONDictionary[@"firstName"]];
            _lastName = [RWCParserUtilities stringWithObject:JSONDictionary[@"lastName"]];
            _nickname = [RWCParserUtilities stringWithObject:JSONDictionary[@"nickName"]];
            _firstNameKatakana = [RWCParserUtilities stringWithObject:JSONDictionary[@"firstNameKataKana"]];
            _lastNameKatakana = [RWCParserUtilities stringWithObject:JSONDictionary[@"lastNameKataKana"]];
        }
        @catch (NSException *exception)
        {
            return nil;
        }
    }
    
    return self;
}

+ (void)parseURLResponse:(NSURLResponse *)response
                    data:(NSData *)data
                   error:(NSError *)error
         completionBlock:(void (^)(id, NSError *))completionBlock
{
    [RWCAppEngineResponseParser parseURLResponse:response data:data error:error completionBlock:^(NSDictionary *RAEResult, NSError *RAEError) {
        RMIName *result = nil;
        if (RAEResult)
        {
            result = [[self alloc] initWithJSONDictionary:RAEResult];
            if (!result)
            {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Exception raised while parsing result",
                                           NSLocalizedFailureReasonErrorKey: @"Invalid server response raised an exception while parsing object."};
                RAEError = [NSError errorWithDomain:RWCAppEngineResponseParserErrorDomain
                                               code:RWCAppEngineResponseParserErrorInvalidResponse
                                           userInfo:userInfo];
            }
        }
        completionBlock(result, RAEError);
    }];
}

@end
