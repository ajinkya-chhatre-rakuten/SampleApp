#import "RakutenEngineClient.h"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation REGlobalTokenResult

#pragma mark - RWCURLResponseParser

+ (void)parseURLResponse:(NSURLResponse *)response
                    data:(NSData *)data
                   error:(NSError *)error
         completionBlock:(void (^)(id, NSError *))completionBlock
{
    [super parseURLResponse:response data:data error:error completionBlock:^(REGlobalTokenResult *result, NSError *parsedError) {
        if (result && [result isKindOfClass:[REGlobalTokenResult class]])
        {
            // Unfortunately we need to re-deszerialize the JSON since we can't access the output of RWCAppEngineResponseParser from here
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parsedError];
            if (JSON)
            {
                result.didMemberAcceptMarketplaceTermsAndConditions = [RWCParserUtilities unsignedIntegerWithObject:JSON[@"is_first_time"]] != 1ull;
            }
        }
        
        completionBlock(result, parsedError);
    }];
}


#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    // Subclasses of NSSecureCoding conformers must explicitly define their conformance
    return YES;
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        _didMemberAcceptMarketplaceTermsAndConditions = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(didMemberAcceptMarketplaceTermsAndConditions))];
        _marketplaceIdentifierForAccessToken = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(marketplaceIdentifierForAccessToken))];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeBool:self.didMemberAcceptMarketplaceTermsAndConditions forKey:NSStringFromSelector(@selector(didMemberAcceptMarketplaceTermsAndConditions))];
    [aCoder encodeObject:self.marketplaceIdentifierForAccessToken forKey:NSStringFromSelector(@selector(marketplaceIdentifierForAccessToken))];
}

@end
