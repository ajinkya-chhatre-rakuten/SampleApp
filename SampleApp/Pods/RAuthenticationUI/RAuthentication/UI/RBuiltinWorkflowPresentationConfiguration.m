/*
 * © Rakuten, Inc.
 */
#import "RBuiltinWorkflowPresentationConfiguration.h"

@implementation RBuiltinWorkflowPresentationConfiguration

#pragma mark <NSCopying>
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    RBuiltinWorkflowPresentationConfiguration *copy = [[self.class allocWithZone:zone] init];
    copy.presenterViewController = self.presenterViewController;
    copy.presentationStyle = self.presentationStyle;
    copy.popoverAnchor = self.popoverAnchor;
    return copy;
}

@end
