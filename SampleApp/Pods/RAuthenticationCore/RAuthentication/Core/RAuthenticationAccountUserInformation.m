/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationCore.h>
#import "_RAuthenticationHelpers.h"

@implementation RAuthenticationAccountUserInformation
#pragma mark <NSObject>
- (NSUInteger)hash
{
    return _firstName.hash ^ _middleName.hash ^ _lastName.hash;
}

- (BOOL)isEqualToUserInformation:(RAuthenticationAccountUserInformation *)other
{
    if (![other isMemberOfClass:self.class] || other.hash != self.hash) { return NO; }
    return
        _RAuthenticationObjectsEqual(_firstName,  other.firstName)  &&
        _RAuthenticationObjectsEqual(_middleName, other.middleName) &&
        _RAuthenticationObjectsEqual(_lastName,   other.lastName);
}

- (BOOL)isEqual:(id)other
{
    if (other == self) { return YES; }
    if (![other isKindOfClass:self.class]) { return NO; }
    return [self isEqualToUserInformation:(RAuthenticationAccountUserInformation *)other];
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"<%@: %p>"
            @"\n\t                      firstName=%@"
            @"\n\t                     middleName=%@"
            @"\n\t                       lastName=%@"
            @"\n\tshouldAgreeToTermsAndConditions=%@",
            NSStringFromClass(self.class), self,
            _firstName, _middleName, _lastName, @(_shouldAgreeToTermsAndConditions)];
}

#pragma mark <NSCopying>
- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) __strong copy = [[self.class allocWithZone:zone] init];
    copy.firstName                       = self.firstName;
    copy.middleName                      = self.middleName;
    copy.lastName                        = self.lastName;
    copy.shouldAgreeToTermsAndConditions = self.shouldAgreeToTermsAndConditions;
    return copy;
}

#pragma mark <NSSecureCoding>
+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark <NSCoding>
static NSString *const kFirstNameKey  = @"fn";
static NSString *const kMiddleNameKey = @"mn";
static NSString *const kLastNameKey   = @"ln";

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if ((self = [self init]))
    {
        _firstName  = [coder decodeObjectOfClass:NSString.class forKey:kFirstNameKey];
        _middleName = [coder decodeObjectOfClass:NSString.class forKey:kMiddleNameKey];
        _lastName   = [coder decodeObjectOfClass:NSString.class forKey:kLastNameKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.firstName  forKey:kFirstNameKey];
    [coder encodeObject:self.middleName forKey:kMiddleNameKey];
    [coder encodeObject:self.lastName   forKey:kLastNameKey];
}
@end
