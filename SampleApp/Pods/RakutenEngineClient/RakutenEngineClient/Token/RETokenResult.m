#import "RakutenEngineClient.h"

static NSDate *refresh_expiration_from_scopes(NSSet *scopes)
{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar.alloc initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = nil;
    
    if ([scopes containsObject:@"1Hour@Refresh"])
    {
        dateComponents = [NSDateComponents new];
        dateComponents.hour = 1;
    }
    else if ([scopes containsObject:@"90days@Refresh"])
    {
        dateComponents = [NSDateComponents new];
        dateComponents.day = 90;
    }
    else if ([scopes containsObject:@"365days@Refresh"])
    {
        dateComponents = [NSDateComponents new];
        dateComponents.day = 365;
    }
    
    // We use date components to get the proper date by adding hours or days... Of course this assumes that RAE is using the correct
    // calendar math, which is why we name the properties "estimated...TokenExpirationDate"
    return (dateComponents) ? [calendar dateByAddingComponents:dateComponents toDate:date options:0] : nil;
}

@implementation RETokenResult

#pragma mark - RWCURLResponseParser

+ (void)parseURLResponse:(NSURLResponse *)response
                    data:(NSData *)data
                   error:(NSError *)error
         completionBlock:(void (^)(id, NSError *))completionBlock
{
    [RWCAppEngineResponseParser parseURLResponse:response data:data error:error completionBlock:^(NSDictionary *RAEResult, NSError *RAEError) {
        if (RAEResult)
        {
            RETokenResult *result = nil;
            NSError *parsingResultError = nil;
            
            @try
            {
                // We use "self" so that subclasses can be parsed the same way
                result = [self new];
                
                result.accessToken  = [RWCParserUtilities stringWithObject:RAEResult[@"access_token"]];
                result.refreshToken = [RWCParserUtilities stringWithObject:RAEResult[@"refresh_token"]];
                
                NSString *scopesString = [RWCParserUtilities stringWithObject:RAEResult[@"scope"]];
                result.scopes = [NSSet setWithArray:[scopesString componentsSeparatedByString:@","]];
                
                int64_t expire = [RWCParserUtilities integerWithObject:RAEResult[@"expires_in"]];
                if (expire != INT64_MAX)
                {
                    result.estimatedAccessTokenExpirationDate = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval)expire];
                }
                
                // Refresh token expiration isn't included in the response, so we have to try and parse the scopes to roughly guess an expiration
                result.estimatedRefreshTokenExpirationDate = refresh_expiration_from_scopes(result.scopes);
            }
            @catch (NSException *exception)
            {
                result = nil;
                
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Exception raised while parsing result",
                                           NSLocalizedFailureReasonErrorKey: exception.reason ?: @"Invalid server response raised an exception while parsing object."};
                parsingResultError = [NSError errorWithDomain:RWCAppEngineResponseParserErrorDomain
                                                         code:RWCAppEngineResponseParserErrorInvalidResponse
                                                     userInfo:userInfo];
            }
            @finally
            {
                completionBlock(result, parsingResultError);
            }
        }
        else
        {
            completionBlock(nil, RAEError);
        }
    }];
}


#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [self init]))
    {
        _accessToken = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(accessToken))];
        _refreshToken = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(refreshToken))];
        _scopes = [aDecoder decodeObjectOfClass:[NSSet class] forKey:NSStringFromSelector(@selector(scopes))];
        _estimatedAccessTokenExpirationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(estimatedAccessTokenExpirationDate))];
        _estimatedRefreshTokenExpirationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(estimatedRefreshTokenExpirationDate))];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.accessToken forKey:NSStringFromSelector(@selector(accessToken))];
    [aCoder encodeObject:self.refreshToken forKey:NSStringFromSelector(@selector(refreshToken))];
    [aCoder encodeObject:self.scopes forKey:NSStringFromSelector(@selector(scopes))];
    [aCoder encodeObject:self.estimatedAccessTokenExpirationDate forKey:NSStringFromSelector(@selector(estimatedAccessTokenExpirationDate))];
    [aCoder encodeObject:self.estimatedRefreshTokenExpirationDate forKey:NSStringFromSelector(@selector(estimatedRefreshTokenExpirationDate))];
}

@end
