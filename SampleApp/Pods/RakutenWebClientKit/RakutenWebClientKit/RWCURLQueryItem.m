/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import "RWCURLQueryItem.h"

static NSString *rfc3986_escape_string(NSString *rawString)
{
    NSCParameterAssert([rawString isKindOfClass:[NSString class]]);
    
    static NSCharacterSet *RFC3986UnreservedCharacters = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // See https://www.ietf.org/rfc/rfc3986.txt section 2.2 and 3.4
        NSString *RFC3986ReservedCharacters = @":#[]@!$&'()*+,;=";
        
        NSMutableCharacterSet *unreservedCharacters = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [unreservedCharacters removeCharactersInString:RFC3986ReservedCharacters];
        
        RFC3986UnreservedCharacters = [unreservedCharacters copy];
    });
    
    // Fix for an issue described in https://github.com/AFNetworking/AFNetworking/pull/3028
    static NSUInteger batchSize = 50;
    
    NSMutableString *escapedString = [NSMutableString string];
    NSUInteger currentIndex = 0;
    
    while (currentIndex < rawString.length)
    {
        NSUInteger length = MIN(rawString.length - currentIndex, batchSize);
        NSRange range = [rawString rangeOfComposedCharacterSequencesForRange:NSMakeRange(currentIndex, length)];
        
        NSString *substring = [rawString substringWithRange:range];
        [escapedString appendString:[substring stringByAddingPercentEncodingWithAllowedCharacters:RFC3986UnreservedCharacters]];
        
        currentIndex += range.length;
    }
    
    return [escapedString copy];
}

@implementation RWCURLQueryItem

- (instancetype)initWithPercentUnencodedKey:(NSString *)key percentUnencodedValue:(NSString *)value
{
    NSParameterAssert(key);
    
    if ((self = [super init]))
    {
        _key = [key copy];
        _value = [value copy];
        
        _percentEncodedKey = rfc3986_escape_string(_key);
        
        if (_value)
        {
            _percentEncodedValue = rfc3986_escape_string(_value);
        }
    }
    
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
#pragma clang diagnostic pop

- (NSString *)description
{
    if (self.percentEncodedValue)
    {
        return [NSString stringWithFormat:@"%@=%@", self.percentEncodedKey, self.percentEncodedValue];
    }
    else
    {
        return self.percentEncodedKey;
    }
}

- (NSUInteger)hash
{
    return self.percentEncodedKey.hash ^ self.percentEncodedValue.hash;
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    else if (![object isKindOfClass:[self class]])
    {
        return NO;
    }
    else
    {
        RWCURLQueryItem *other = object;
        return [self.percentEncodedKey isEqualToString:other.percentEncodedKey] && ((!self.percentEncodedValue && !other.percentEncodedValue) || (self.percentEncodedValue && other.percentEncodedValue && [self.percentEncodedValue isEqualToString:other.percentEncodedValue]));
    }
}

- (NSComparisonResult)compare:(RWCURLQueryItem *)other
{
    return [[self description] compare:[other description]];
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.key forKey:NSStringFromSelector(@selector(key))];
    [aCoder encodeObject:self.value forKey:NSStringFromSelector(@selector(value))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *key = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(key))];
    NSString *value = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(value))];
    
    return [self initWithPercentUnencodedKey:key percentUnencodedValue:value];
}

@end


@implementation RWCURLQueryItem (RUtilities)

+ (instancetype)queryItemWithPercentUnencodedKey:(NSString *)key percentUnencodedValue:(NSString *)value
{
    return [[self alloc] initWithPercentUnencodedKey:key percentUnencodedValue:value];
}

+ (instancetype)queryItemWithPercentEncodedKey:(NSString *)key percentEncodedValue:(NSString *)value
{
    // Unclear if the bug affecting stringByAddingPercentEncodingWithAllowedCharacters: also impacts this method.
    return [self queryItemWithPercentUnencodedKey:[key stringByRemovingPercentEncoding]
                            percentUnencodedValue:[value stringByRemovingPercentEncoding]];
}

+ (NSArray *)queryItemsFromPercentEncodedQueryString:(NSString *)percentEncodedQueryString
{
    NSParameterAssert(percentEncodedQueryString);
    
    NSMutableArray *queryItems = [NSMutableArray array];
    
    NSArray *queryItemStrings = [percentEncodedQueryString componentsSeparatedByString:@"&"];
    
    for (NSString *queryItemString in queryItemStrings)
    {
        NSArray *components = [queryItemString componentsSeparatedByString:@"="];
        NSString *key = components.firstObject;
        NSString *value = nil;
        if (components.count > 1)
        {
            value = components.lastObject;
        }
        
        [queryItems addObject:[self queryItemWithPercentEncodedKey:key percentEncodedValue:value]];
    }
    
    return queryItems;
}

+ (NSString *)queryStringFromQueryItems:(NSArray *)queryItems
{
    if (queryItems.count == 0)
    {
        return nil;
    }
    
    NSArray *queryItemStrings = [queryItems valueForKey:@"description"];
    return [queryItemStrings componentsJoinedByString:@"&"];
}

+ (NSData *)formDataFromQueryItems:(NSArray *)queryItems
{
    NSString *queryString = [self queryStringFromQueryItems:queryItems];
    if (!queryString)
    {
        return nil;
    }
    
    return [queryString dataUsingEncoding:NSUTF8StringEncoding];
}

@end

