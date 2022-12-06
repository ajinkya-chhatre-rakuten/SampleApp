#import "RakutenEngineClient.h"
#import "_RETracking.h"

#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation REClient

- (NSURLSessionDataTask *)tokenWithRequest:(RETokenRequest *)request
                           completionBlock:(void (^)(RETokenResult *__nullable, NSError *__nullable))completionBlock
{
    Class responseParserClass = [RETokenResult class];

    if ([request.context isKindOfClass:[REGlobalPasswordTokenRequestContext class]])
    {
        // This is a bit messy, but seems reasonable since majority of the properties and serialization are shared between the two
        responseParserClass = [REGlobalTokenResult class];
    }
    
    return [self dataTaskForRequestSerializer:request responseParser:responseParserClass completionBlock:^(id result, NSError *error) {
        
        if (error && [request.context isKindOfClass:[REClientCredentialsTokenRequestContext class]])
        {
            // Token request failures in other contexts (e.g. JapanPassword login) will be tracked by RAuthentication
            [_RETracking broadcastClientCredentialsTokenRequestFailureWithError:error];
        }
        
        if ([result isKindOfClass:[REGlobalTokenResult class]] && [request.context isKindOfClass:[REGlobalPasswordTokenRequestContext class]])
        {
            REGlobalPasswordTokenRequestContext *context = request.context;
            REGlobalTokenResult *globalTokenResult = result;
            
            // This is EXTREMELY messy, but there is great value in being able to tell what marketplace a Global access token was made with,
            // and since it is not part of the JSON response we manually inject it here.
            globalTokenResult.marketplaceIdentifierForAccessToken = context.marketplaceIdentifier;
        }
        
        completionBlock(result, error);
    }];
}

- (NSURLSessionDataTask *)revokeTokenWithRequest:(RERevokeTokenRequest *)request completionBlock:(void (^)(BOOL, NSError *__nullable))completionBlock
{
    return [self dataTaskForRequestSerializer:request responseParser:[RWCAppEngineResponseParser class] completionBlock:^(id result, NSError *error) {
        completionBlock(error == nil, error);
    }];
}

- (NSURLSessionDataTask *)validateTokenWithRequest:(REValidateTokenRequest *)request
                                   completionBlock:(void (^)(BOOL, NSError *__nullable))completionBlock
{
    return [self dataTaskForRequestSerializer:request responseParser:[RWCAppEngineResponseParser class] completionBlock:^(id result, NSError *error) {
        completionBlock(error == nil, error);
    }];
}

@end
