/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationCore.h>
#import "_RAuthenticationHelpers.h"

@implementation RAuthenticationAccountPersistenceInformation

#pragma mark <NSObject>
- (NSUInteger)hash
{
    return _accessGroup.hash ^ _creationDate.hash ^ _lastModificationDate.hash ^ _bundleIdentifierOfLastApplication.hash ^ _displayNameOfLastApplication.hash;
}

- (BOOL)isEqualToPersistenceInformation:(RAuthenticationAccountPersistenceInformation *)other
{
    if (![other isMemberOfClass:self.class] || other.hash != self.hash) { return NO; }
    return
        _RAuthenticationObjectsEqual(_accessGroup,                       other.accessGroup)                  &&
        _RAuthenticationObjectsEqual(_creationDate,                      other.creationDate)                 &&
        _RAuthenticationObjectsEqual(_lastModificationDate,              other.lastModificationDate)         &&
        _RAuthenticationObjectsEqual(_displayNameOfLastApplication,      other.displayNameOfLastApplication) &&
        _RAuthenticationObjectsEqual(_bundleIdentifierOfLastApplication, other.bundleIdentifierOfLastApplication);
}

- (BOOL)isEqual:(id)other
{
    if (other == self) { return YES; }
    if (![other isKindOfClass:self.class]) { return NO; }
    return [self isEqualToPersistenceInformation:(RAuthenticationAccountPersistenceInformation *)other];
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"<%@: %p>"
            @"\n\t                      accessGroup=%@"
            @"\n\t                     creationDate=%@"
            @"\n\t             lastModificationDate=%@"
            @"\n\tbundleIdentifierOfLastApplication=%@"
            @"\n\t     displayNameOfLastApplication=%@",
            NSStringFromClass(self.class), self,
            _accessGroup, _creationDate, _lastModificationDate, _bundleIdentifierOfLastApplication, _displayNameOfLastApplication];
}

#pragma mark <NSCopying>
- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) __strong copy = [[self.class allocWithZone:zone] init];
    copy.accessGroup                       = self.accessGroup;
    copy.creationDate                      = self.creationDate;
    copy.lastModificationDate              = self.lastModificationDate;
    copy.bundleIdentifierOfLastApplication = self.bundleIdentifierOfLastApplication;
    copy.displayNameOfLastApplication      = self.displayNameOfLastApplication;
    return copy;
}
@end
