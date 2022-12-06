#import "RakutenMemberInformationClient.h"

@implementation RMIEmail

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDictionary
{
    NSParameterAssert(JSONDictionary);
    
    if ((self = [super init]))
    {
        @try
        {
            _emailAddress = [RWCParserUtilities stringWithObject:JSONDictionary[@"emailAddress"]];
            if (_emailAddress.length == 0)
            {
                _emailAddress = nil;
            }
            
            _mobileEmailAddress = [RWCParserUtilities stringWithObject:JSONDictionary[@"mobileEmail"]];
            if (_mobileEmailAddress.length == 0)
            {
                _mobileEmailAddress = nil;
            }
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
    [RWCAppEngineResponseParser parseURLResponse:response data:data error:error completionBlock:^(NSDictionary *RAEResult, NSError *RAEError)
     {
         RMIEmail *result = nil;
         if (RAEResult) {
             result = [[self alloc] initWithJSONDictionary:RAEResult];
             if (!result)
             {
                 NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"Exception raised while parsing result",
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
