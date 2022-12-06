/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
#import "RWCParserUtilities.h"

@implementation RWCParserUtilities

+ (int64_t)integerWithObject:(id)object
{
    if ([object isKindOfClass:[NSNumber class]])
    {
        NSNumber *numberValue = object;
        return numberValue.longLongValue;
    }
    else if ([object isKindOfClass:[NSNull class]])
    {
        object = nil;
    }
    else if ([object isKindOfClass:[NSString class]])
    {
        NSString *stringValue = object;
        if (stringValue.length)
        {
            char *invalid;
            int64_t value = strtoll(stringValue.UTF8String, &invalid, 10);
            if (!*invalid)
            {
                return value;
            }
            if ([stringValue isEqualToString:@"true"])  { return 1ll; }
            if ([stringValue isEqualToString:@"false"]) { return 0ll; }
        }
        else
        {
            // Empty string is treated as missing value
            object = nil;
        }
    }
    
    if (object)
    {
        [NSException raise:NSInvalidArgumentException format:@"Doesn't represent an integer: %@", object];
    }
    
    return INT64_MAX;
}

+ (uint64_t)unsignedIntegerWithObject:(id)object
{
    if ([object isKindOfClass:[NSNumber class]])
    {
        NSNumber *numberValue = object;
        return numberValue.unsignedLongLongValue;
    }
    else if ([object isKindOfClass:[NSNull class]])
    {
        object = nil;
    }
    else if ([object isKindOfClass:[NSString class]])
    {
        NSString *stringValue = object;
        if (stringValue.length)
        {
            char *invalid;
            uint64_t value = strtoull(stringValue.UTF8String, &invalid, 10);
            if (!*invalid)
            {
                return value;
            }
            if ([stringValue isEqualToString:@"true"])  { return 1ull; }
            if ([stringValue isEqualToString:@"false"]) { return 0ull; }
        }
        else
        {
            // Empty string is treated as missing value
            object = nil;
        }
    }
    
    if (object)
    {
        [NSException raise:NSInvalidArgumentException format:@"Doesn't represent an integer: %@", object];
    }
    
    return UINT64_MAX;
}

+ (NSString *)stringWithObject:(id)object
{
    if (![object isKindOfClass:[NSString class]])
    {
        if ([object isKindOfClass:[NSNull class]])
        {
            return nil;
        }
        else if ([object respondsToSelector:@selector(stringValue)])
        {
            object = [object stringValue];
        }
        else if (object)
        {
            [NSException raise:NSInvalidArgumentException format:@"Cannot be coerced to a NSString: %@", object];
            object = nil;
        }
    }
    
    return [object length] ? object : nil;
}

@end

