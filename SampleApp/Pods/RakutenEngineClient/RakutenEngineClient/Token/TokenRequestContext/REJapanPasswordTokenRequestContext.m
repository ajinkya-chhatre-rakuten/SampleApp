#import "RakutenEngineClient.h"
#import <CommonCrypto/CommonDigest.h>
#if (TARGET_OS_WATCH)
@import WatchKit;
#else
@import UIKit.UIDevice;
#endif
@import CoreLocation;
@import Darwin.POSIX.sys.utsname;
#import <RSDKDeviceInformation/RSDKDeviceInformation.h>

#pragma mark - Helpers

static BOOL objects_equal(id objA, id objB)
{
    return (!objA && !objB) || (objA && objB && [objA isEqual:objB]);
}

static NSString *urlSafeBase64FormatWithString(NSString *string)
{
    // URL-safe base 64.
    NSString *encodedString = [[string dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"=" withString:@""];
    return encodedString;
}

#pragma mark - REJapanPasswordTokenRequestContext

@implementation REJapanPasswordTokenRequestContext

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password
{
    NSParameterAssert(username);
    NSParameterAssert(password);
    
    if ((self = [super init]))
    {
        _username = username.copy;
        _password = password.copy;
    }
    
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
#pragma clang diagnostic pop

- (NSUInteger)hash
{
    return _username.hash ^ _password.hash ^ _serviceIdentifier.hash ^ _privacyPolicyVersion.hash ^ _challengeParameters.hash;
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    else if (![object isKindOfClass:[self class]])
    {
        return NO;
    }
    
    REJapanPasswordTokenRequestContext *other = object;
    
    return objects_equal(_username, other.username) &&
    objects_equal(_password, other.password) &&
    objects_equal(_serviceIdentifier, other.serviceIdentifier) &&
    objects_equal(_privacyPolicyVersion, other.privacyPolicyVersion) &&
    objects_equal(_challengeParameters, other.challengeParameters);
}


#pragma mark <RETokenRequestContext>

- (NSString *)requestURLPath
{
    return @"engine/token";
}

#pragma mark <RWCURLQueryItemSerializable>

- (NSArray *)serializeQueryItemsWithError:(out NSError **)error
{
    /*
     * "Tracking parameters" contain the privacy policy version acknowledged by the user upon login,
     * as well as a bit of information about the running environment.
     */
    NSMutableDictionary *trackingParameters = NSMutableDictionary.new;

    // Privacy policy version
    if (_privacyPolicyVersion.length) trackingParameters[@"pp_version"] = self.privacyPolicyVersion;

    // OS info
#if (TARGET_OS_WATCH)
    WKInterfaceDevice *device = WKInterfaceDevice.currentDevice;
#else
    UIDevice *device = UIDevice.currentDevice;
#endif
    trackingParameters[@"os_info"] = [NSString stringWithFormat:@"%@/%@", device.systemName, device.systemVersion];

    // Model identifier
    NSString *model = RSDKDeviceInformation.modelIdentifier ?: device.model;
    trackingParameters[@"device_model_identifier"] = model;

    // Time zone
    trackingParameters[@"time_zone"] = @(-NSTimeZone.localTimeZone.secondsFromGMT / 60).stringValue;

    // Current app (backend didn't request version info, oddly)
    NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
    if (bundleIdentifier) trackingParameters[@"application_identifier"] = bundleIdentifier;

    // Carrier name, if this device as a SIM
    NSString *carrierName = RSDKDeviceInformation.carrierName;
    if (carrierName) trackingParameters[@"carrier_name"] = urlSafeBase64FormatWithString(carrierName);

    // Current data network technology
    NSString *dataNetworkTechnology = RSDKDeviceInformation.dataNetworkTechnology;
    if (dataNetworkTechnology)
    {
        trackingParameters[@"network_type"] = dataNetworkTechnology;
    }

    // Last known location
    CLLocationCoordinate2D coordinate = RSDKDeviceInformation.lastKnownCoordinate;
    if (CLLocationCoordinate2DIsValid(coordinate))
    {
        trackingParameters[@"latitude"]  = @(coordinate.latitude);
        trackingParameters[@"longitude"] = @(coordinate.longitude);
    }

    /*
     * If Info.plist doesn't contain a DNT key, we track more sensitive data.
     *
     * We won't document this key, as it's only intended to allow for quickly republishing
     * an app in the event Apple rejected it because of us. We'll inform developers of its
     * existence only if that ever happens.
     */
    if (![NSBundle.mainBundle objectForInfoDictionaryKey:@"DNT"])
    {
        // Device name, as set by the user. This often contains the user's real name.
        trackingParameters[@"device_name"] = urlSafeBase64FormatWithString(device.name);
        trackingParameters[@"device_fp"] = [RSDKDeviceInformation.fingerprint base64EncodedStringWithOptions:0];
    }

    /*
     * Request params
     */
    NSMutableArray *queryitems = [NSMutableArray array];
    [queryitems addObject:[RWCURLQueryItem queryItemWithPercentUnencodedKey:@"grant_type" percentUnencodedValue:@"password"]];
    [queryitems addObject:[RWCURLQueryItem queryItemWithPercentUnencodedKey:@"username" percentUnencodedValue:self.username]];
    [queryitems addObject:[RWCURLQueryItem queryItemWithPercentUnencodedKey:@"password" percentUnencodedValue:self.password]];

    if (_serviceIdentifier.length)
        [queryitems addObject:[RWCURLQueryItem queryItemWithPercentUnencodedKey:@"service_id" percentUnencodedValue:self.serviceIdentifier]];

    if (_challengeParameters)
    {
        NSData *data = [NSJSONSerialization dataWithJSONObject:_challengeParameters.jsonObject options:0 error:0];
        NSString *json = [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
        if (json.length)
        {
            [queryitems addObject:[RWCURLQueryItem queryItemWithPercentUnencodedKey:@"challenger_parameters" percentUnencodedValue:json]];
        }
    }
    
    if (trackingParameters.count)
    {
        NSData *data = [NSJSONSerialization dataWithJSONObject:trackingParameters options:0 error:0];
        NSString *json = [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
        if (json.length)
        {
            [queryitems addObject:[RWCURLQueryItem queryItemWithPercentUnencodedKey:@"tracking_parameters" percentUnencodedValue:json]];
        }
    }

    return [queryitems copy];
}


#pragma mark <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    REJapanPasswordTokenRequestContext *copy = [[self.class allocWithZone:zone] initWithUsername:_username
                                                                                        password:_password];
    copy.serviceIdentifier    = _serviceIdentifier.copy;
    copy.privacyPolicyVersion = _privacyPolicyVersion.copy;
    copy.challengeParameters = _challengeParameters.copy;
    return copy;
}


#pragma mark <NSSecureCoding>

+ (BOOL)supportsSecureCoding
{
    return YES;
}


#pragma mark <NSCoding>

- (instancetype)initWithCoder:(NSCoder *)coder
{
    NSString *username = [coder decodeObjectOfClass:NSString.class forKey:NSStringFromSelector(@selector(username))];
    NSString *password = [coder decodeObjectOfClass:NSString.class forKey:NSStringFromSelector(@selector(password))];

    if ((self = [self initWithUsername:username password:password]))
    {
        _serviceIdentifier = [coder decodeObjectOfClass:NSString.class forKey:NSStringFromSelector(@selector(serviceIdentifier))];
        _privacyPolicyVersion = [coder decodeObjectOfClass:NSString.class forKey:NSStringFromSelector(@selector(privacyPolicyVersion))];
        _challengeParameters = [coder decodeObjectOfClass:REChallengeParameters.class forKey:NSStringFromSelector(@selector(challengeParameters))];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_username forKey:NSStringFromSelector(@selector(username))];
    [coder encodeObject:_password forKey:NSStringFromSelector(@selector(password))];
    [coder encodeObject:_serviceIdentifier forKey:NSStringFromSelector(@selector(serviceIdentifier))];
    [coder encodeObject:_privacyPolicyVersion forKey:NSStringFromSelector(@selector(privacyPolicyVersion))];
    [coder encodeObject:_challengeParameters forKey:NSStringFromSelector(@selector(challengeParameters))];
}

@end
