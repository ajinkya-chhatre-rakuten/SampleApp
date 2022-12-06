/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
@import ObjectiveC.runtime;
#import "RakutenWebClientKit.h"

static NSString *const RWCAutoCopyableModelPropertyNameKey = @"RWCAutoCopyableModelPropertyNameKey";
static NSString *const RWCAutoCopyableModelPropertyAttributesKey = @"RWCAutoCopyableModelPropertyAttributesKey";

@implementation RWCAutoCopyableModel

- (NSString *)description
{
    NSSet *propertyKeys = [[self class] _equatablePropertyKeys];
    NSMutableArray *properties = [NSMutableArray array];
    for (NSString *property in propertyKeys)
    {
        [properties addObject:[NSString stringWithFormat:@"%@ = %@", property, [[self valueForKey:property] description]]];
    }
    
    return [NSString stringWithFormat:@"<%@: %p>\n\t%@", [self class], self, [properties componentsJoinedByString:@"\n\t"]];
}

- (NSUInteger)hash
{
    NSUInteger h = 0;
    for (NSString *property in [[self class] _equatablePropertyKeys])
    {
        h ^= [[self valueForKey:property] hash];
    }
    return h;
}

- (BOOL)isEqual:(id)other
{
    if (self == other) return YES;
    if (![other isMemberOfClass:[self class]]) return NO;
    
    for (NSString *key in [[self class] _equatablePropertyKeys])
    {
        id selfValue = [self valueForKey:key];
        id otherValue = [other valueForKey:key];
        
        BOOL equalValues = (!selfValue && !otherValue) || (selfValue && otherValue && [selfValue isEqual:otherValue]);
        if (!equalValues)
        {
            return NO;
        }
    }
    
    return YES;
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] allocWithZone:zone] init];
    
    for (NSString *property in [[self class] _copyablePropertyKeys])
    {
        [copy setValue:[self valueForKey:property] forKey:property];
    }
    
    return copy;
}


#pragma mark - Private

// Returns an NSDictionary with the property name as the key and the property attributes array as the value
+ (NSDictionary *)_allProperties
{
    NSDictionary *cachedProperties = objc_getAssociatedObject(self, _cmd);
    if (cachedProperties) { return cachedProperties; }
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    
    Class cls = self;
    unsigned int count;
    while (![cls isEqual:[RWCAutoCopyableModel class]])
    {
        objc_property_t *props = class_copyPropertyList(cls, &count);
        cls = [cls superclass];
        if (!props) { continue; }
        
        for (unsigned int i = 0; i < count; i++)
        {
            objc_property_t property           = props[i];
            NSString       *propertyName       = @(property_getName(property));
            NSArray        *propertyAttributes = [@(property_getAttributes(property)) componentsSeparatedByString:@","];
            
            properties[propertyName] = propertyAttributes;
        }
        
        free(props);
    }

    cachedProperties = [properties copy];
    objc_setAssociatedObject(self, _cmd, cachedProperties, OBJC_ASSOCIATION_RETAIN);
    return cachedProperties;
}

+ (NSSet *)_equatablePropertyKeys
{
    NSSet *cachedKeys = objc_getAssociatedObject(self, _cmd);
    if (cachedKeys) { return cachedKeys; }
    
    NSMutableSet *keys = [NSMutableSet set];
    
    NSDictionary *properties = [self _allProperties];
    for (NSString *propertyName in properties)
    {
        NSArray *propertyAttributes = properties[propertyName];
        
        // Ignore weak properties
        if ([propertyAttributes containsObject:@"W"]) { continue; }
        
        [keys addObject:propertyName];
    }
    
    cachedKeys = [keys copy];
    objc_setAssociatedObject(self, _cmd, cachedKeys, OBJC_ASSOCIATION_RETAIN);
    return cachedKeys;
}

+ (NSSet *)_copyablePropertyKeys
{
    NSSet *cachedKeys = objc_getAssociatedObject(self, _cmd);
    if (cachedKeys) { return cachedKeys; }
    
    NSMutableSet *keys = [NSMutableSet set];
    
    NSDictionary *properties = [self _allProperties];
    for (NSString *propertyName in properties)
    {
        NSArray *propertyAttributes = properties[propertyName];
        
        // Ignore weak properties
        if ([propertyAttributes containsObject:@"W"]) { continue; }
        if ([propertyAttributes containsObject:@"R"])
        {
            static NSPredicate *predicate;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", @"V"];
            });

            // Ignore readonly properties without a backing Ivar
            if ([propertyAttributes filteredArrayUsingPredicate:predicate].count == 0) { continue; }
        }
        
        [keys addObject:propertyName];
    }
    
    cachedKeys = [keys copy];
    objc_setAssociatedObject(self, _cmd, cachedKeys, OBJC_ASSOCIATION_RETAIN);
    return cachedKeys;
}

@end

