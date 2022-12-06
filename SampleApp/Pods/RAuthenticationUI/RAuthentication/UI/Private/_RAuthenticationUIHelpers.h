/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationUI/RAuthenticationUI.h>
#import "_RAuthenticationHelpers.h"

NS_ASSUME_NONNULL_BEGIN

/*
 * Load a localized string, allowing the application to override the tables for e.g.\ changing
 * some localizations or provide support for languages we do not have lcoalizations for.
 *
 * @param key The key for the string.
 *
 * @return A localized version of the string designated by `key`:
 *         - If `key` is `nil`, returns nil.
 *         - If `key` is found in the `RAuthentication` table in the main bundle, returns its associated string.
 *
 *         Else, prefix the key with `authentication`, then:
 *         - If `key` is found in a table named `RAuthentication` in the main bundle, returns its associated string.
 *         - If `key` is found in the default `Localizable` table in the main bundle, returns its associated string.
 *         - If the above doesn't apply and `key` exist in the SDK table, returns its associated string.
 *         - If none of the above applies, returns `key` as a fallback.
 */
RAUTH_EXPORT NSString *_RAuthenticationLocalizedString(NSString *key);

RAUTH_EXPORT NSString *_RAuthenticationAutomationIds(NSString *key);

/*
 * Returns the module's asset bundle, which holds the Rakuten logo and
 * the localization files.
 */
RAUTH_EXPORT NSBundle *_RAuthenticationAssetsBundle(void);

#pragma mark - UI utilities

#if !(TARGET_OS_WATCH)
/*
 * This relies on C99 initializers to make constraints a bit less verbose and more readable.
 */
typedef struct
{
    NSLayoutAttribute attribute, from;
    NSLayoutRelation  relation;
    CGFloat           multiplier;
    CGFloat           constant;
    UILayoutPriority  priority;
    const char*       identifier;
} _rauthentication_constraint_attributes_t;
RAUTH_EXPORT NSLayoutConstraint *_RAuthenticationMakeConstraintImpl(id first, id __nullable second, _rauthentication_constraint_attributes_t constraint);
#define MakeConstraint(f,s,a...) _RAuthenticationMakeConstraintImpl(f, s, (_rauthentication_constraint_attributes_t){a})

#endif

/*
 * Grab a font using rem units, using the user-set base font since.
 */
RAUTH_EXPORT UIFont *_RAuthenticationDynamicFont(UIFontDescriptor *__nullable descriptor, CGFloat rem);

/*
 * Convert xml-like markup into an attributed string.
 */
RAUTH_EXPORT NSAttributedString *__nullable
_RAuthenticationParseMarkup(NSString *__nullable markup,
                            NSDictionary<NSString *, id> *__nullable genericAttributes,
                            NSDictionary<NSString *, id> *__nullable namedAttributes);

#pragma mark Misc private declarations

@protocol RAuthenticationViewControllerFooterDelegate<NSObject>
@optional
- (void)onPrivacyPolicyButtonTapped;
- (void)onHelpButtonTapped;
@end

@interface RAuthenticationViewController ()<RAuthenticationViewControllerFooterDelegate>
- (BOOL)isPortrait;
- (void)addContentViews:(UIView *)view, ... NS_REQUIRES_NIL_TERMINATION;
- (void)addStandardFooter;
- (void)openURL:(NSURL *)url title:(NSString *)title;
- (void)openURLWithLocalizedKey:(NSString *)key titleKey:(NSString *)titleKey;
- (void)openStandardPrivacyPolicyPage;
- (void)openStandardHelpPage;
@end

@interface RAuthenticationAccountUserInformation (Helper)
- (nullable NSString*)fullname;
- (nullable NSString*)displayname;
@end

NS_ASSUME_NONNULL_END
