#import "RakutenMemberInformationClient.h"

@implementation RMIAddress

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDictionary
{
    NSParameterAssert(JSONDictionary);
    
    if ((self = [super init]))
    {
        @try
        {
            _zipCode = [RWCParserUtilities stringWithObject:JSONDictionary[@"zip"]];
            _prefecture = [RWCParserUtilities stringWithObject:JSONDictionary[@"prefecture"]];
            _city = [RWCParserUtilities stringWithObject:JSONDictionary[@"city"]];
            _street = [RWCParserUtilities stringWithObject:JSONDictionary[@"street"]];
            _fullAddress = [RWCParserUtilities stringWithObject:JSONDictionary[@"fullAddress"]];
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
        RMIAddress *result = nil;
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