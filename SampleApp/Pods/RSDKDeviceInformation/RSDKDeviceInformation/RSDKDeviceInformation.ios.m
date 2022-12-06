/*
 * © Rakuten, Inc.
 * authors: "Rakuten Ecosystem Mobile" <ecosystem-mobile@mail.rakuten.com>
 */

@import UIKit.UIDevice;
@import CoreTelephony;
@import MediaAccessibility;
@import MessageUI;
@import MobileCoreServices;
@import SystemConfiguration;
@import Darwin.POSIX.sys.utsname;
#import <CommonCrypto/CommonCrypto.h>
#import <RSDKDeviceInformation/RSDKDeviceInformation.h>

// After we open source parts of the SDK, this should become a set of public cocoapod libraries
// for passively monitoring the last known position, carrier name and network type.
RDI_PUBLIC @interface _REJapanPasswordTokenRequestContextLocationHelper : NSObject<CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D lastKnownCoordinate;
@end

@implementation _REJapanPasswordTokenRequestContextLocationHelper
- (instancetype)init
{
    if ((self = [super init]))
    {
        _lastKnownCoordinate = kCLLocationCoordinate2DInvalid;
        
        _locationManager = CLLocationManager.new;
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        _locationManager.distanceFilter  = kCLLocationAccuracyThreeKilometers;
        _locationManager.delegate = self;
        
        NSNotificationCenter* events = NSNotificationCenter.defaultCenter;
        [events addObserver:self selector:@selector(updateState)      name:UIApplicationDidBecomeActiveNotification  object:nil];
        [events addObserver:self selector:@selector(handleBackground) name:UIApplicationWillResignActiveNotification object:nil];
        
        [self updateState];
    }
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [_locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager * __unused)manager didChangeAuthorizationStatus:(CLAuthorizationStatus __unused)status
{
    [self updateState];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSInteger count = locations.count;
    while (count > 0)
    {
        CLLocationCoordinate2D coordinate = locations[--count].coordinate;
        if (CLLocationCoordinate2DIsValid(coordinate))
        {
            _lastKnownCoordinate = coordinate;
            break;
        }
    }
}

- (void)updateState
{
    CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
    if (CLLocationManager.locationServicesEnabled &&
        (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse))
    {
        [_locationManager startUpdatingLocation];
    }
    else
    {
        [_locationManager stopUpdatingLocation];
    }
}

- (void)handleBackground
{
    if (CLLocationManager.authorizationStatus != kCLAuthorizationStatusAuthorizedAlways)
    {
        [_locationManager stopUpdatingLocation];
    }
}
@end

#define RSDKDeviceInformationDomain @"jp.co.rakuten.ios.sdk.deviceinformation"

#ifndef RMSDK_DEVICE_INFORMATION_VERSION
#warning "RMSDK_DEVICE_INFORMATION_VERSION not defined. Code that depend on it might fail."
#define RMSDK_DEVICE_INFORMATION_VERSION 0.0.0
#endif

#define RDI_EXPAND_AND_QUOTE0(s) #s
#define RDI_EXPAND_AND_QUOTE(s) RDI_EXPAND_AND_QUOTE0(s)

/* RDI_PUBLIC */ const NSString* const RSDKDeviceInformationVersion = @ RDI_EXPAND_AND_QUOTE(RMSDK_DEVICE_INFORMATION_VERSION);;

static __attribute__((constructor)) void register_version()
{
    @autoreleasepool
    {
        NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
        [defaults setObject:RSDKDeviceInformationVersion forKey:@ "com.rakuten.remsdk.versions.RSDKDeviceInformation"];
        [defaults synchronize];
    }
}

static NSString *const keychainAccessGroup = RSDKDeviceInformationDomain;
static NSString *const probeKey = RSDKDeviceInformationDomain @"probe";
static NSString *const uuidKey  = RSDKDeviceInformationDomain @"uuid";

#pragma mark - Globals

static SCNetworkReachabilityFlags _latestReachabilityFlags = 0;
static CTTelephonyNetworkInfo *_telephonyNetworkInfo = nil;
static NSString *_carrierName = nil;
static _REJapanPasswordTokenRequestContextLocationHelper *_locationHelper = nil;

static void _reachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void __unused *info)
{
    _latestReachabilityFlags = flags;
}

static NSString *hexadecimal(const NSData *data)
{
    const unsigned char *bytes = data.bytes;
    NSUInteger length = data.length;
    NSMutableString *output = [NSMutableString stringWithCapacity:(length << 1)];
    for (NSUInteger offset = 0; offset < length; ++offset)
    {
        [output appendFormat:@"%02x", bytes[offset]];
    }
    return output.copy;
}

static void raiseException(NSString * const value, NSString * const message)
{
    [NSException raise:value
                format:@"\n%@\nPlease refer to the API reference documentation at https://documents.developers.rakuten.com/ios-sdk/deviceinformation-latest\n\n", message];
}

static void checkMissingAccessControl(OSStatus status)
{
    // errSecNoAccessForItem is not defined for iOS, only OS X.
    // Normally it would be found in <Security/SecBase.h>.
    if (status == /* errSecNoAccessForItem */ -25243)
    {
        raiseException(NSObjectInaccessibleException, @"Your application is lacking the proper keychain-access-group entitlements.");
    }
}

@implementation RSDKDeviceInformation

+ (void)load
{
    CFRunLoopRef loop = CFRunLoopGetMain();
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "www.rakuten.com");
    SCNetworkReachabilitySetCallback(reachability, _reachabilityCallback, 0);
    SCNetworkReachabilityScheduleWithRunLoop(reachability, loop, kCFRunLoopCommonModes);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags))
            _latestReachabilityFlags = flags;
    });
    
    void (^setCarrier)(CTCarrier *) = ^(CTCarrier *carrier) {
        NSString *name = carrier.carrierName;
        name = [name substringToIndex:MIN(32ul, name.length)];
        if (name.length) _carrierName = name;
    };
    
    _telephonyNetworkInfo = [CTTelephonyNetworkInfo new];
    setCarrier(_telephonyNetworkInfo.subscriberCellularProvider);
    _telephonyNetworkInfo.subscriberCellularProviderDidUpdateNotifier = ^(CTCarrier *carrier) {
        setCarrier(carrier);
    };
    
    _locationHelper = [_REJapanPasswordTokenRequestContextLocationHelper new];
    
    atexit_b(^{
        SCNetworkReachabilityUnscheduleFromRunLoop(reachability, loop, kCFRunLoopCommonModes);
        CFRelease(reachability);
        
        _telephonyNetworkInfo = nil;
        _locationHelper       = nil;
    });
}

+ (NSString *)uniqueDeviceIdentifier
{
    /*
     * Because the keychain might not be available when this is called,
     * we can't use dispatch_once() here.
     */
    @synchronized(self)
    {
        /*
         * If we already have a value, return it.
         */

        static NSString *value = nil;

        if (value)
        {
            return value;
        }

        CFTypeRef result;
        OSStatus status;

#if !TARGET_IPHONE_SIMULATOR
        /*
         * First, try to grab the application identifier prefix (=bundle seed it)
         * and build the access group from it.
         */

        static NSString *accessGroup = nil;
        if (!accessGroup)
        {
            NSDictionary *strongQuery = @{(__bridge id)kSecAttrService: probeKey,
                                          (__bridge id)kSecAttrAccount: probeKey,
                                          (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                          (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleWhenUnlocked,
                                          (__bridge id)kSecReturnAttributes: @YES};
            CFDictionaryRef query = (__bridge CFDictionaryRef)strongQuery;

            status = SecItemCopyMatching(query, &result);

            if (status == errSecItemNotFound)
            {
                status = SecItemAdd(query, &result);
            }

            if (status != errSecSuccess)
            {
                /*
                 * Keychain is not available
                 */

                return nil;
            }

            NSString *defaultAccessGroup = [CFBridgingRelease(result) objectForKey:(__bridge id)kSecAttrAccessGroup];
            NSRange firstDot = [defaultAccessGroup rangeOfString:@"."];
            accessGroup = [[defaultAccessGroup substringToIndex:firstDot.location] stringByAppendingFormat:@".%@", keychainAccessGroup];

            /*
             * While we're at it, why not check developers didn't do the unthinkable?
             */
            if ([keychainAccessGroup isEqualToString:[defaultAccessGroup substringFromIndex:firstDot.location + 1]])
            {
                raiseException(NSInternalInconsistencyException, [NSString stringWithFormat:@"\"%@\" is your default access group. Make sure your application's bundle identifier is the first entry of `keychain-access-groups` in your entitlements!", keychainAccessGroup]);
            }


            /*
             * Try to clean things up
             */
            strongQuery = @{(__bridge id)kSecAttrService: probeKey,
                            (__bridge id)kSecAttrAccount: probeKey,
                            (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword};
            SecItemDelete((__bridge CFDictionaryRef)strongQuery);
        }
#endif // TARGET_IPHONE_SIMULATOR

        /*
         * Try to find the device identifier in the keychain.
         * Here we always have a bundle seed id.
         */

        static CFDictionaryRef searchQuery = NULL;
        if (!searchQuery)
        {
            searchQuery = (CFDictionaryRef)CFBridgingRetain( @{(__bridge id)kSecAttrAccount: uuidKey,
                                                               (__bridge id)kSecAttrService: uuidKey,
                                                               (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
#if !TARGET_IPHONE_SIMULATOR
                                                               (__bridge id)kSecAttrAccessGroup: accessGroup,
#endif // TARGET_IPHONE_SIMULATOR
                                                               (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne,
                                                               (__bridge id)kSecReturnData: (__bridge id)kCFBooleanTrue
                                                               });
        };

        status = SecItemCopyMatching(searchQuery, &result);
        checkMissingAccessControl(status);

        if (status == errSecSuccess)
        {
            /*
             * Device id found!
             */
            value = hexadecimal(CFBridgingRelease(result));
            return value;
        }

        if (status != errSecItemNotFound)
        {
            /*
             * Keychain problem
             */

            return nil;
        }

        /*
         * Get identifierForVendor and write it to the keychain.
         * If it succeeds, then assign the result to 'value'.
         */

        static NSData *deviceIdData = nil;
        if (!deviceIdData)
        {
            static NSCharacterSet *zeroesAndHyphens;
            static dispatch_once_t once;
            dispatch_once(&once, ^
            {
                zeroesAndHyphens = [NSCharacterSet characterSetWithCharactersInString:@"0-"];
            });

            NSString *idForVendor = UIDevice.currentDevice.identifierForVendor.UUIDString;
            if (![idForVendor stringByTrimmingCharactersInSet:zeroesAndHyphens].length)
            {
                /*
                 * Filter out nil, empty, or zeroed strings (e.g. "00000000-0000-0000-0000-000000000000")
                 * We don't have many options here, beside generating an id.
                 */

                idForVendor = [NSUUID.UUID UUIDString];
            }

            NSData *data = [idForVendor dataUsingEncoding:NSUTF8StringEncoding];
            unsigned char hash[CC_SHA1_DIGEST_LENGTH];
            CC_SHA1(data.bytes, (unsigned int)data.length, hash);

            deviceIdData = [NSData dataWithBytes:hash length:CC_SHA1_DIGEST_LENGTH];
        }

        static CFDictionaryRef saveQuery = NULL;
        if (!saveQuery)
        {
            saveQuery = (CFDictionaryRef)CFBridgingRetain( @{(__bridge id)kSecAttrAccount: uuidKey,
                                                             (__bridge id)kSecAttrService: uuidKey,
                                                             (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
#if !TARGET_IPHONE_SIMULATOR
                                                             (__bridge id)kSecAttrAccessGroup: accessGroup,
#endif // TARGET_IPHONE_SIMULATOR
                                                             (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleWhenUnlocked,
                                                             (__bridge id)kSecValueData: deviceIdData,
                                                             });
        };

        status = SecItemAdd(saveQuery, NULL);
        checkMissingAccessControl(status);
        if (status != errSecSuccess)
        {
            return nil;
        }

        value = hexadecimal(deviceIdData);
        return value;
    }
}

+ (NSString *)modelIdentifier
{
    static NSString *value;
    static dispatch_once_t once;
    dispatch_once(&once, ^
    {
        struct utsname systemInfo;
        uname(&systemInfo);
        value = [NSString.alloc initWithUTF8String:systemInfo.machine];
    });

    return value;
}

+ (NSData *)fingerprint
{
    /*
     * Build a fingerprint for this device using user settings and runtime environment.
     */

    // Model identifier
    NSString *model = self.modelIdentifier ?: UIDevice.currentDevice.model;
    
    /*
     * Build a fingerprint for this device using user settings and runtime environment.
     */
    NSMutableArray *fingerprintCompounds = [NSMutableArray array];
    
    // This comparator uses the Unicode collation algorithm, that is locale-invariant.
    static NSComparator localeInvariantComparator = ^NSComparisonResult(NSString *a, NSString *b)
    {
        return [a compare:b options:NSLiteralSearch range:NSMakeRange(0, a.length) locale:nil];
    };
    
    // Inject model identifier and device name
    [fingerprintCompounds addObject:model];
    [fingerprintCompounds addObject:UIDevice.currentDevice.name];
    
    // Inject Dynamic Type settings
    for (UIFontTextStyle textStyle in @[UIFontTextStyleBody,
                                        UIFontTextStyleCaption1,
                                        UIFontTextStyleCaption2,
                                        UIFontTextStyleFootnote,
                                        UIFontTextStyleHeadline,
                                        UIFontTextStyleSubheadline])
    {
        UIFont *font = [UIFont preferredFontForTextStyle:textStyle];
        [fingerprintCompounds addObject:font.fontName];
        [fingerprintCompounds addObject:@(font.pointSize)];
    }
    
    // Inject some accessibility settings. Some only exist since iOS 8.0
    [fingerprintCompounds addObject:@(UIAccessibilityIsMonoAudioEnabled())];
    [fingerprintCompounds addObject:@(UIAccessibilityIsClosedCaptioningEnabled())];
    [fingerprintCompounds addObject:@(&UIAccessibilityIsGrayscaleEnabled          && UIAccessibilityIsGrayscaleEnabled())];
    [fingerprintCompounds addObject:@(&UIAccessibilityIsBoldTextEnabled           && UIAccessibilityIsBoldTextEnabled())];
    [fingerprintCompounds addObject:@(&UIAccessibilityIsReduceMotionEnabled       && UIAccessibilityIsReduceMotionEnabled())];
    [fingerprintCompounds addObject:@(&UIAccessibilityIsReduceTransparencyEnabled && UIAccessibilityIsReduceTransparencyEnabled())];
    [fingerprintCompounds addObject:@(&UIAccessibilityDarkerSystemColorsEnabled   && UIAccessibilityDarkerSystemColorsEnabled())];
    
    // Inject carrier and SMS/MMS capabilities. Note the carrier name is always there if there's a SIM
    [fingerprintCompounds addObject:_carrierName ?: NSNull.null];
    [fingerprintCompounds addObject:@([MFMessageComposeViewController canSendText])];
    [fingerprintCompounds addObject:@([MFMessageComposeViewController canSendAttachments])];
    [fingerprintCompounds addObject:@([MFMessageComposeViewController isSupportedAttachmentUTI:(NSString *)kUTTypeJPEG])];
    [fingerprintCompounds addObject:@([MFMessageComposeViewController isSupportedAttachmentUTI:(NSString *)kUTTypeMovie])];
    
    // Inject available keyboards
    NSArray <NSString *> *keyboards = [NSUserDefaults.standardUserDefaults objectForKey:@"AppleKeyboards"];
    [fingerprintCompounds addObject:[keyboards sortedArrayUsingComparator:localeInvariantComparator] ?: @[]];
    
    // Inject localization settings
    NSLocale *locale = NSLocale.autoupdatingCurrentLocale;
    [fingerprintCompounds addObject:locale.localeIdentifier]; // also has the calendar identifier if non-standard
    [fingerprintCompounds addObject:[NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:locale]]; // 12/24 time format
    [fingerprintCompounds addObject:NSLocale.preferredLanguages];
    [fingerprintCompounds addObject:[locale objectForKey:NSLocaleUsesMetricSystem] ?: @NO];
    
    // Inject subtitles & captioning settings
    UIFontDescriptor *fontDescriptor =  CFBridgingRelease(MACaptionAppearanceCopyFontDescriptorForStyle(kMACaptionAppearanceDomainUser, 0, kMACaptionAppearanceFontStyleDefault));
    UIColor *fgColor = [UIColor colorWithWhite:1 alpha:1];
    UIColor *bgColor = [UIColor colorWithWhite:0 alpha:1];
    UIColor *wnColor = [UIColor colorWithWhite:0 alpha:0];
    
    CGColorRef cgFgColor = MACaptionAppearanceCopyForegroundColor(kMACaptionAppearanceDomainUser, 0);
    CGColorRef cgBgColor = MACaptionAppearanceCopyBackgroundColor(kMACaptionAppearanceDomainUser, 0);
    CGColorRef cgWnColor = MACaptionAppearanceCopyWindowColor(kMACaptionAppearanceDomainUser, 0);
    if (cgFgColor) {
        fgColor = [UIColor colorWithCGColor:cgFgColor];
        CFRelease(cgFgColor);
    }
    if (cgBgColor) {
        bgColor = [UIColor colorWithCGColor:cgBgColor];
        CFRelease(cgBgColor);
    }
    if (cgWnColor) {
        wnColor = [UIColor colorWithCGColor:cgWnColor];
        CFRelease(cgWnColor);
    }
    
    [fingerprintCompounds addObject:fontDescriptor.postscriptName];
    [fingerprintCompounds addObject:@(MACaptionAppearanceGetWindowRoundedCornerRadius(kMACaptionAppearanceDomainUser, 0))];
    [fingerprintCompounds addObject:@(MACaptionAppearanceGetDisplayType(kMACaptionAppearanceDomainUser))];
    [fingerprintCompounds addObject:@(MACaptionAppearanceGetRelativeCharacterSize(kMACaptionAppearanceDomainUser, 0))];
    [fingerprintCompounds addObject:@(MACaptionAppearanceGetTextEdgeStyle(kMACaptionAppearanceDomainUser, 0))];
    [fingerprintCompounds addObject:fgColor.description];
    [fingerprintCompounds addObject:bgColor.description];
    [fingerprintCompounds addObject:wnColor.description];
    [fingerprintCompounds addObject:@(MACaptionAppearanceGetForegroundOpacity(kMACaptionAppearanceDomainUser, 0))];
    [fingerprintCompounds addObject:@(MACaptionAppearanceGetBackgroundOpacity(kMACaptionAppearanceDomainUser, 0))];
    [fingerprintCompounds addObject:@(MACaptionAppearanceGetWindowOpacity(kMACaptionAppearanceDomainUser, 0))];
    
    // Compute the final hash. Note that since we use arrays, JSON representation is stable.
    NSData *input = [NSJSONSerialization dataWithJSONObject:fingerprintCompounds options:0 error:0];
    NSMutableData *fingerprint = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(input.bytes, (CC_LONG) input.length, fingerprint.mutableBytes);

    return fingerprint;
}

+ (NSString *)carrierName
{
    return _carrierName;
}

+ (NSString *)dataNetworkTechnology
{
    if (_latestReachabilityFlags & kSCNetworkReachabilityFlagsReachable)
    {
        if ((_latestReachabilityFlags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
        {
            NSString *networkType = _telephonyNetworkInfo.currentRadioAccessTechnology;
            
            // Strip the prefix. Note our Android implementation also uses the same values.
            NSString *const radioAccessTechnologyPrefix = @"CTRadioAccessTechnology";
            if ([networkType hasPrefix:radioAccessTechnologyPrefix])
            {
                return [networkType substringFromIndex:radioAccessTechnologyPrefix.length];
            }
        }
        else
        {
            return @"WiFi";
        }
    }
    return nil;
}

+ (CLLocationCoordinate2D)lastKnownCoordinate
{
    return _locationHelper.lastKnownCoordinate;
}
@end

