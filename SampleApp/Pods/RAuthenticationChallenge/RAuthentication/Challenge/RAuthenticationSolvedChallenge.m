/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationChallenge/RAuthenticationChallenge.h>

#pragma mark RAuthenticationSolvedChallenge

@implementation RAuthenticationSolvedChallenge

#pragma mark <NSCopying>
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    RAuthenticationSolvedChallenge *copy = [[self.class allocWithZone:zone] init];
    copy.pageId = self.pageId;
    copy.identifier = self.identifier;
    copy.result = self.result;
    return copy;
}

@end
