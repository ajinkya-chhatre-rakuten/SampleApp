/*
 * © Rakuten, Inc.
 */
#import <Foundation/Foundation.h>
#import "_RAuthenticationUIHelpers.h"

/* RAUTH_EXPORT */ NSString *_RAuthenticationLocalizedString(NSString *key)
{
    static NSString *tableName = @"RAuthentication";
    static NSString *notFound = @"__not_found__";

    // Lookup the string in RAuthentication.strings in the main bundle:
    // (unprefixed, for backward compatibility with RAuthentication <4)
    NSString *result = [NSBundle.mainBundle localizedStringForKey:key value:notFound table:tableName];
    if (result && ![result isEqualToString:notFound])
    {
        return result;
    }

    // Prefix the string and look it up in Localizable.strings in the main bundle:
    key = [@"authentication." stringByAppendingString:key];
    result = [NSBundle.mainBundle localizedStringForKey:key value:notFound table:nil];
    if (result && ![result isEqualToString:notFound])
    {
        return result;
    }

    // Lookup the string in Localizable.strings in the assets bundle:
    result = [_RAuthenticationAssetsBundle() localizedStringForKey:key value:notFound table:nil];
    if (result && ![result isEqualToString:notFound])
    {
        return result;
    }

    // Fallback to English in the assets bundle:
    static NSBundle *fallbackBundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *fallbackBundlePath = [_RAuthenticationAssetsBundle() pathForResource:@"en" ofType:@"lproj"];
        fallbackBundle = [NSBundle bundleWithPath:fallbackBundlePath];
    });
    result = [fallbackBundle localizedStringForKey:key value:notFound table:nil];
    if (![result isEqualToString:notFound])
    {
        return result;
    }

    return key;
}

/* RAUTH_EXPORT */ NSString *_RAuthenticationAutomationIds(NSString *key)
{
    static NSString *notFound = @"__not_found__";

    // Lookup the string in AutomationIds.strings in the asset bundle:
    NSString *result = [_RAuthenticationAssetsBundle() localizedStringForKey:key value:notFound table:@"AutomationIds"];
    if (result && ![result isEqualToString:notFound])
    {
        return [@"jp.co.rakuten.sdk.ecosystemdemo:id/" stringByAppendingString:result];
    }
    return key;
}

/* RAUTH_EXPORT */ NSBundle *_RAuthenticationAssetsBundle(void)
{
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        // Can't use [NSBundle mainBundle] here, because it returns the path to XCTest.framework
        // when running unit tests. Also, if the SDK is being bundled as a dynamic framework,
        // then it comes in its own bundle.
        NSBundle *classBundle = [NSBundle bundleForClass:RBuiltinAccountSelectionDialog.class];

        // If RAuthenticationAssets.bundle cannot be found, we revert to using the class bundle
        NSString *assetsPath = [classBundle.resourcePath stringByAppendingPathComponent:@"RAuthenticationAssets.bundle"];
        bundle = [NSBundle bundleWithPath:assetsPath] ?: classBundle;
    });
    return bundle;
}

#if !(TARGET_OS_WATCH)
/* RAUTH_EXPORT */ NSLayoutConstraint *_RAuthenticationMakeConstraintImpl(id first, id __nullable second, _rauthentication_constraint_attributes_t constraint)
{
    if (constraint.multiplier == 0) constraint.multiplier = 1;
    if (constraint.priority   == 0) constraint.priority   = UILayoutPriorityRequired;
    if (!constraint.from)           constraint.from       = constraint.attribute;

    // Only 'first' is nonnull. Defaults are as follow:
    //
    // constraint.attribute  = NSLayoutAttributeNotAnAttribute
    // constraint.relation   = NSLayoutRelationEqual
    // constraint.from       = constraint.attribute
    // constraint.constant   = 0
    // constraint.multiplier = 1
    // constraint.priority   = UILayoutPriorityRequired

    NSLayoutConstraint *result = [NSLayoutConstraint constraintWithItem:first
                                                              attribute:constraint.attribute
                                                              relatedBy:constraint.relation
                                                                 toItem:second
                                                              attribute:constraint.from
                                                             multiplier:constraint.multiplier
                                                               constant:constraint.constant];
    result.priority = constraint.priority;
    if (constraint.identifier)
    {
        result.identifier = [NSString stringWithUTF8String:constraint.identifier];
    }
    return result;
}
#endif

/* RAUTH_EXPORT */ UIFont *_RAuthenticationDynamicFont(UIFontDescriptor *__nullable descriptor, CGFloat rem)
{
    UIFont *base = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    CGFloat pointSize = round(MAX(12., base.pointSize * rem));
    if (descriptor)
    {
        return [UIFont fontWithDescriptor:(id)descriptor size:pointSize];
    }
    else
    {
        return [base fontWithSize:pointSize];
    }
}

/* RAUTH_EXPORT */ NSAttributedString *__nullable
_RAuthenticationParseMarkup(NSString *__nullable markup,
                                             NSDictionary *__nullable genericAttributes,
                                             NSDictionary *__nullable namedAttributes)
{
    if (!markup) return nil;
    if (!genericAttributes) genericAttributes = @{};
    if (!namedAttributes)   namedAttributes   = @{};

    NSMutableAttributedString *builder = [NSMutableAttributedString.alloc initWithString:(id)markup attributes:genericAttributes];

    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"<([^>]+)>(.*?)</\\1>"
                                                          options:NSRegularExpressionDotMatchesLineSeparators
                                                            error:nil];
    });

    NSString *text = markup;
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, markup.length)];
    if (matches.count)
    {
        [builder beginEditing];
        for (NSTextCheckingResult *match in matches.reverseObjectEnumerator)
        {
            NSRange          range = [match rangeAtIndex:0];
            NSDictionary *subStyle = namedAttributes[[text substringWithRange:[match rangeAtIndex:1]]];
            NSString     *fragment = [markup substringWithRange:[match rangeAtIndex:2]];
            if (!fragment.length) { continue; }

            if (subStyle.count)
            {
                NSMutableDictionary *tmp = genericAttributes.mutableCopy;
                [tmp addEntriesFromDictionary:subStyle];
                subStyle = tmp;
            }
            else
            {
                subStyle = genericAttributes;
            }

            NSAttributedString *attributedFragment = _RAuthenticationParseMarkup(fragment, subStyle, namedAttributes);

            [builder replaceCharactersInRange:range
                         withAttributedString:attributedFragment];
        }
        [builder endEditing];
    }
    return builder;
}

@implementation RAuthenticationAccountUserInformation (Helper)

- (NSString*)fullname
{
    if (self.firstName.length && self.lastName.length)
    {
        if (self.middleName.length)
        {
            return [NSString stringWithFormat:_RAuthenticationLocalizedString(@"format.fullname(firstName, middleName, lastName)"), self.firstName, self.middleName, self.lastName];
        }
        else
        {
            return [NSString stringWithFormat:_RAuthenticationLocalizedString(@"format.fullname(firstName, lastName)"), self.firstName, self.lastName];
        }
    }
    return nil;
}

- (NSString*)displayname
{
    if (!self.firstName.length)
    {
        return nil;
    }
    if (!self.lastName.length)
    {
        return self.firstName;
    }
    if (self.firstName.length && self.lastName.length)
    {
        return [NSString stringWithFormat:_RAuthenticationLocalizedString(@"format.displayname(firstName, lastName)"), self.firstName, self.lastName];
    }
    return nil;
}

@end
