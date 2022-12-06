/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */
@import Foundation;

/**
 *  @defgroup RWCMacros Macros
 *
 *  All macros defined in Rakuten Web Client Kit
 *
 *  @{
 */

/**
 *  Exports a global. Also works if the SDK is built as a dynamic framework (iOS 8+).
 *
 *  Example:
 *  @code
 *  RWC_EXPORT NSString *const RFoo;
 *  RWC_EXPORT \@interface RMyPublicClass : NSObject { ... }
 *  @endcode
 */
#ifdef __cplusplus
#define RWC_EXPORT extern "C" __attribute__((visibility ("default")))
#else
#define RWC_EXPORT extern __attribute__((visibility ("default")))
#endif

#if __has_feature(objc_generics)

/**
 *  Enable generics in an Xcode 6 compatible way.
 *
 *  Example:
 *  @code
 *  \@interface Foo RWC_GENERIC(__covariant TheType:id<Bar>): NSObject
 *  - (RWC_GENERIC_TYPE(TheType))getBar;
 *  - (void)doBazWithBar:(RWC_GENERIC_TYPE(TheType) __nullable)bar;
 *  - (NSArray RWC_GENERIC(TheType) *)createBarsWithStrings:(NSArray RWC_GENERIC(NSString *) *)strings;
 *  \@end
 *  @endcode
 */
#define RWC_GENERIC(...) <__VA_ARGS__>

/**
 * Enable generics in an Xcode 6 compatible way.
 *
 *  Example:
 *  @code
 *  \@interface Foo RWC_GENERIC(__covariant TheType:id<Bar>): NSObject
 *  - (RWC_GENERIC_TYPE(TheType))getBar;
 *  - (void)doBazWithBar:(RWC_GENERIC_TYPE(TheType) __nullable)bar;
 *  - (NSArray RWC_GENERIC(TheType) *)createBarsWithStrings:(NSArray RWC_GENERIC(NSString *) *)strings;
 *  \@end
 *  @endcode
 */
#define RWC_GENERIC_TYPE(type) type

#else

#define RWC_GENERIC(...)
#define RWC_GENERIC_TYPE(type) id

#endif


/**
 *  @}
 */

