#import "RPushPNPUnreadCount.h"
#import "_RPushPNPHelpers.h"

static RPushPNPUnreadCount *create_result_from_json(NSDictionary *JSON, NSError *__autoreleasing *error) {
    @try {
        RPushPNPUnreadCount *result = [RPushPNPUnreadCount new];
        result.unreadCount = [RWCParserUtilities integerWithObject:JSON[@"unreadCount"]];
        return result;
    }
    @catch (NSException *exception) {
        if (error) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Exception raised while parsing result",
                                       NSLocalizedFailureReasonErrorKey: exception.reason ?: @"Invalid server response raised an exception while parsing object."};
            *error = [NSError errorWithDomain:RWCAppEngineResponseParserErrorDomain
                                         code:RWCAppEngineResponseParserErrorInvalidResponse
                                     userInfo:userInfo];
        }
        return nil;
    }
}

@implementation RPushPNPUnreadCount

#pragma mark - RWCURLResponseParser

+ (void)parseURLResponse:(nullable NSURLResponse *)response
                    data:(nullable NSData *)data
                   error:(nullable NSError *)error
         completionBlock:(void (^)(id __nullable parsedResult, NSError *__nullable parsedError))completionBlock {
    [RWCAppEngineResponseParser parseURLResponse:response
                                            data:data
                                           error:error
                                 completionBlock:^(NSDictionary *RAEResult, NSError *RAEError) {
                                     RPushPNPUnreadCount *result = nil;
                                     if (RAEResult) {
                                         NSError *resultParsingError = nil;
                                         result = create_result_from_json(RAEResult, &resultParsingError);
                                         completionBlock(result, resultParsingError);
                                     }
                                     else {
                                         completionBlock(nil, RAEError);
                                     }
                                 }];
}

@end
