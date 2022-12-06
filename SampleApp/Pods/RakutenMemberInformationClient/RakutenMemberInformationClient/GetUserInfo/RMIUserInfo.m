#import "RakutenMemberInformationClient.h"

static RMIUserInfo *create_result_from_json(NSDictionary *JSON)
{
    @try
    {
        RMIUserInfo *profile = [[RMIUserInfo alloc] init];
        profile.openID = [RWCParserUtilities stringWithObject:JSON[@"openId"]];
        
        profile.basicInformation = [[RMIBasicInfo alloc] initWithJSONDictionary:JSON];
        if (!profile.basicInformation)
        {
            return nil;
        }
        
        profile.nameInformation = [[RMIName alloc] initWithJSONDictionary:JSON];
        if (!profile.nameInformation)
        {
            return nil;
        }
        
        profile.emailInformation = [[RMIEmail alloc] initWithJSONDictionary:JSON];
        if (!profile.emailInformation)
        {
            return nil;
        }
        
        profile.telephoneInformation = [[RMITelephone alloc] initWithJSONDictionary:JSON];
        if (!profile.telephoneInformation)
        {
            return nil;
        }
        
        profile.addressInformation = [[RMIAddress alloc] initWithJSONDictionary:JSON];
        if (!profile.addressInformation)
        {
            return nil;
        }
        
        return profile;
    }
    @catch (NSException *exception)
    {
        return nil;
    }
}

@implementation RMIUserInfo

+ (void)parseURLResponse:(NSURLResponse *)response
                    data:(NSData *)data
                   error:(NSError *)error
         completionBlock:(void (^)(id, NSError *))completionBlock
{
    [RWCAppEngineResponseParser parseURLResponse:response data:data error:error completionBlock:^(id  parsedResult, NSError *parsedError) {
        RMIUserInfo *result = nil;
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
