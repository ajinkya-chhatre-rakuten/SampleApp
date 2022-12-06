/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import "RWCAppEngineResponseParser.h"
#import "RWCParserUtilities.h"

// WARNING: Keep this in sync with RakutenAPIErrorDomain, for backward compatibility
NSString * const RWCAppEngineResponseParserErrorDomain = @"jp.co.rakuten.sdk.rankutenapis";

@implementation RWCAppEngineResponseParser

+ (void)parseURLResponse:(NSURLResponse *)response
                    data:(NSData *)data
                   error:(NSError *)error
         completionBlock:(void (^)(id, NSError *))completionBlock
{
    NSParameterAssert(completionBlock);
    
    if (error)
    {
        completionBlock(nil, error);
        return;
    }
    
    NSDictionary *payload = nil;
    if (data)
    {
        NSError *JSONSerializationError;
        payload = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONSerializationError];
        
        if (!payload)
        {
            completionBlock(nil, JSONSerializationError);
            return;
        }
    }
    
    NSString *errorType = nil;
    NSString *errorDescription = nil;
    NSInteger statusCode = 0;
    
    if ([payload isKindOfClass:[NSDictionary class]])
    {
        // Got a payload. Good!
        errorType = payload[@"error"]; // RAE only
        
        errorDescription =
        // Various RAE APIs
        payload[@"error_description"] ?:
        payload[@"errorMessage"] ?:
        payload[@"statusMessage"] ?:
        // REMS Questionnaire API
        payload[@"Message"];
        
        // Some methods have a statusCode entry as well, which is sometimes a HTTP
        // status code and sometimes the error type
        @try
        {
            uint64_t statusValue = [RWCParserUtilities unsignedIntegerWithObject:payload[@"statusCode"]];
            if (statusValue != UINT64_MAX)
            {
                statusCode = (NSInteger) statusValue;
            }
        }
        @catch (NSException *exception)
        {
            if (!errorType)
            {
                errorType = [RWCParserUtilities stringWithObject:payload[@"statusCode"]];
            }
        }
    }
    
    if (!errorType && (statusCode > 0 || [response isKindOfClass:[NSHTTPURLResponse class]]))
    {
        // No payload? Use known error types as placeholders
        // See https://rakuten.atlassian.net/wiki/pages/viewpage.action?pageId=116263779
        statusCode = statusCode ?: [(NSHTTPURLResponse *)response statusCode];
        switch (statusCode)
        {
            case 400:
                errorType = @"invalid_request";
                break;
                
            case 401:
            case 403:
                errorType = @"access_denied";
                break;
                
            case 404:
                errorType = @"not_found";
                break;
                
            case 409:
                errorType = @"conflict";
                break;
                
            default:
                if (statusCode > 400)
                {
                    errorType = @"invalid_response";
                }
                
                break;
        }
    }
    
    if (!errorType)
    {
        completionBlock(payload, nil);
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NSLocalizedDescriptionKey] = errorType;
    
    if (response.URL)
    {
        userInfo[NSURLErrorKey] = response.URL;
    }
    
    if (errorDescription.length)
    {
        userInfo[NSLocalizedFailureReasonErrorKey] = errorDescription;
    }
    
    RWCAppEngineResponseParserError errorCode = RWCAppEngineResponseParserErrorInvalidResponse;
    
    if ([errorType isEqualToString:@"invalid_request"] ||
        [errorType isEqualToString:@"invalid_client"]  ||
        [errorType isEqualToString:@"invalid_scope"]   ||
        [errorType isEqualToString:@"wrong_parameter"])
    {
        errorCode = RWCAppEngineResponseParserErrorInvalidParameter;
    }
    else if ([errorType isEqualToString:@"unauthorized_grant_type"] ||
             [errorType isEqualToString:@"unauthorized_client"]     ||
             [errorType isEqualToString:@"invalid_token"]           ||
             [errorType isEqualToString:@"invalid_grant"]           ||
             [errorType isEqualToString:@"insufficient_scope"]      ||
             [errorType isEqualToString:@"access_denied"]           ||
             [errorType isEqualToString:@"system_error"]            ||
             [errorType isEqualToString:@"no_permission_for_MFW"])
    {
        errorCode = RWCAppEngineResponseParserErrorUnauthorized;
    }
    else if ([errorType isEqualToString:@"not_found"])
    {
        errorCode = RWCAppEngineResponseParserErrorResourceNotFound;
    }
    else if ([errorType isEqualToString:@"conflict"])
    {
        errorCode = RWCAppEngineResponseParserErrorResourceConflict;
    }
    else if ([errorType isEqualToString:@"success"])
    {
        completionBlock(payload, nil);
        return;
    }
    
    NSError *RAEError = [NSError errorWithDomain:RWCAppEngineResponseParserErrorDomain code:errorCode userInfo:userInfo];
    completionBlock(nil, RAEError);
}

@end

