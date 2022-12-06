/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import "RakutenWebClientKit.h"

@implementation RWCURLRequestConfiguration

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
        _baseURL = [aDecoder decodeObjectOfClass:[NSURL class] forKey:NSStringFromSelector(@selector(baseURL))];
        _HTTPHeaderFields = [aDecoder decodeObjectOfClass:[NSDictionary class] forKey:NSStringFromSelector(@selector(HTTPHeaderFields))];
        
        NSNumber *cachePolicy = [aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(cachePolicy))];
        _cachePolicy = [cachePolicy unsignedIntegerValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.baseURL forKey:NSStringFromSelector(@selector(baseURL))];
    [aCoder encodeObject:self.HTTPHeaderFields forKey:NSStringFromSelector(@selector(HTTPHeaderFields))];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.cachePolicy] forKey:NSStringFromSelector(@selector(cachePolicy))];
}

@end

