#import "RakutenMemberInformationClient.h"

@implementation RMITelephone

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDictionary
{
    NSParameterAssert(JSONDictionary);
    
    if ((self = [super init]))
    {
        @try
        {
            _telephone = [RWCParserUtilities stringWithObject:JSONDictionary[@"tel"]];
            if (_telephone.length == 0)
            {
                _telephone = nil;
            }
            
            _mobilePhone = [RWCParserUtilities stringWithObject:JSONDictionary[@"keitai"]];
            if (_mobilePhone.length == 0)
            {
                _mobilePhone = nil;
            }
            
            _faxNumber = [RWCParserUtilities stringWithObject:JSONDictionary[@"fax"]];
            if (_faxNumber.length == 0)
            {
                _faxNumber = nil;
            }
        }
        @catch (NSException *exception) {
            return nil;
        }
    }
    
    return self;
}

+ (void)parseURLResponse:(NSURLResponse *)response
                    data:(NSData *)data error:(NSError *)error
         completionBlock:(void (^)(id, NSError *))completionBlock
{
    [RWCAppEngineResponseParser parseURLResponse:response data:data error:error completionBlock:^(NSDictionary *RAEResult, NSError *RAEError) {
        RMITelephone *result = nil;
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
