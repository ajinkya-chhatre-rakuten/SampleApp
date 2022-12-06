# RPushPNP iOS SDK

1. [Introduction](#introduction)
1. [Troubleshooting and support](#troubleshooting-and-support)
1. [Getting started](#getting-started)
1. [API environment](#api-environment)
1. [Using PNP features](#using-pnp-features)
1. [Using advanced PNP features](advanced_usage.html)
1. [Setting a custom configuration](#setting-a-custom-configuration)
1. [Suggested implementation in app](#suggested-implementation-in-app)
1. [Rich Push Notifications](#rich-push-notifications)
1. [Uninstall tracking](#uninstall-tracking)
1. [Pitfalls](#pitfalls)
1. [macOS push tester app](#macos-push-tester-app)
1. [Migration guide](#migration-guide)
1. [Changelog](changelog.html)

# Introduction

⚠️ This module supports iOS 11.0 and above. It has been tested on iOS 12 and above.

This document is for iOS mobile application developers and describes how to integrate the PushPNP mobile SDK into their app.

The **RPushPNP** module interfaces to Rakuten's [Push Notification Platform](https://confluence.rakuten-it.com/confluence/display/PNPD/Push+Notification+Platform+Page) (PNP), which is an in-house platform to support configuring and scheduling Apple iOS and Google Android push messages. The SDK also provides registration caching support to minimise unnecessary registration API calls. 

The module uses the configuration class provided via its dependency on `RakutenWebClientKit`.

`RPushPNP` replaces the End of Life module `RakutenPushNotificationPlatformClient`. To migrate from `RakutenPushNotificationPlatformClient` please see the [migration guide](#migration-guide) below.

# Troubleshooting and support

* Please check this README carefully because the answer to your issue may already be in this document
* For an SDK issue please open an `Other SDKs` [inquiry on our SDK Customer Support Portal](https://confluence.rakuten-it.com/confluence/x/Aw_JqQ)
* For a PNP platform issue please [create a ticket](https://confluence.rakuten-it.com/confluence/display/PNPD/PNP+-+Create+a+ticket+to+contact+us) with the PNP team

# Getting started

## Pre-requisites for receiving high quality support
* To enable us to better support you, ensure you do the following *before* creating an [inquiry](https://confluence.rakuten-it.com/confluence/x/Aw_JqQ):
    * Give the DLM `dev-mag-mobile-sdk` access to your git source repo and include your repo URL on any inquiry ticket
    * Ideally, please also give the members of DLM `dev-mag-mobile-sdk` access to your crash reporting dashboard e.g. Firebase Crashlytics

## Installation

Your `Podfile` should contain:
```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://gitpub.rakuten-it.com/scm/eco/core-ios-specs.git'

pod 'RPushPNP'
```

Run `pod install` to install the module and its dependencies.

⚠️ This module now only supports **PNP v2** (newer high-availability) platform.

## RAE configuration

Your app must be registered with Rakuten App Engine (RAE) in order to access the PNP APIs. 

You can check which [PNP APIs](https://confluence.rakuten-it.com/confluence/display/PNPD/Legacy+Device+APIs) you need to call to determine which scopes you need.

You need to provide an RAE token with either all or a subset (depending on which features you will support) of the following scopes:

* pnp_ios_register
* pnp_ios_unregister
* pnp_ios_denytype_check
* pnp_ios_denytype_update
* pnp_common_pushedhistory
* pnp_common_getunreadcount
* pnp_common_sethistorystatus

If you already have an RAE client please ensure the above scopes are added to your RAE client ID. If you do not have an RAE client, [apply to RAE](https://onecloud.rakuten-it.com/one-docs/docs/Others/rae-getting-started) requesting they add the necessary scopes.  

To modify your RAE client's scopes use RAE's [Production](https://rae-dashboard.rakuten-it.com/rakuten/organization/list?firstLogin=true) and [Staging](https://stg-rae-dashboard.intra.rakuten-it.com/rakuten/organization/list?firstLogin=true) self-service dashboards. Note that the scopes request will need to be approved by the upstream API provider, in this case PNP.

## PNP configuration
Your app must then register with the PNP service in order to obtain PNP client ID and secret (_NOT_ the same as RAE client ID/secret). Please request a PNP client ID from the [PNP team here](https://confluence.rakuten-it.com/confluence/display/PNPD/Push+Notification+Platform+-+Create+New+PNP+Client+ID). They will send the following in a box folder and share access to your developers. The **external** secret should be used by mobile apps.

        PNP client id
        PNP external secret
        PNP Internal secret
        PNP username
        PNP password
        
## Apple APNs push notification configuration

* Activate Push Notifications for your App (Bundle) ID (e.g. `com.rakuten.tech.mobile.your_app_name`) on Sharepoint [here](https://officerakuten.sharepoint.com/sites/list/SDTD/MOBILEECO/MOBILESTAND/Lists/DraftMultiple%20Request/Ongoing.aspx?viewpath=%2Fsites%2Flist%2FSDTD%2FMOBILEECO%2FMOBILESTAND%2FLists%2FDraftMultiple%20Request%2FOngoing.aspx)

* Create a [Support Request: Get Enterprise Development and Production Certificates](https://officerakuten.sharepoint.com/sites/list/SDTD/MOBILEECO/MOBILESTAND/Lists/DraftMultiple%20Request/Ongoing.aspx?viewpath=%2Fsites%2Flist%2FSDTD%2FMOBILEECO%2FMOBILESTAND%2FLists%2FDraftMultiple%20Request%2FOngoing.aspx) ticket

* Create a [Support Request: Get Provisioning Profiles - Development and Production](https://officerakuten.sharepoint.com/sites/list/SDTD/MOBILEECO/MOBILESTAND/Lists/DraftMultiple%20Request/Ongoing.aspx?viewpath=%2Fsites%2Flist%2FSDTD%2FMOBILEECO%2FMOBILESTAND%2FLists%2FDraftMultiple%20Request%2FOngoing.aspx) ticket

* Create a [Support Request: Get APNs Auth Token (p8 File, team ID and key ID) for your iOS App - Development and Production](https://officerakuten.sharepoint.com/sites/list/SDTD/MOBILEECO/MOBILESTAND/Lists/DraftMultiple%20Request/Ongoing.aspx?viewpath=%2Fsites%2Flist%2FSDTD%2FMOBILEECO%2FMOBILESTAND%2FLists%2FDraftMultiple%20Request%2FOngoing.aspx) ticket

* [Add your device ID](https://officerakuten.sharepoint.com/sites/list/SDTD/MOBILEECO/MOBILESTAND/Lists/DraftMultiple%20Request/Ongoing.aspx?viewpath=%2Fsites%2Flist%2FSDTD%2FMOBILEECO%2FMOBILESTAND%2FLists%2FDraftMultiple%20Request%2FOngoing.aspx) to Development and Production provisioning profiles
 
* [Configure](https://confluence.rakuten-it.com/confluence/display/PNPD/2.+Setup#id-2.Setup-3rdPartyServiceSetup) your APNs Auth Token on PNP dashboard
 
## ACL for non-intra access from your server scripts

* To call PNP Push APIs from servers **inside** Rakuten network [create an OPS ticket](https://confluence.rakuten-it.com/confluence/display/PNPD/Push+Notification+Platform+-+Production+Proxy+ACL) (**Note**: only required for Production). Note that ZxD production environment has been added to the ACL already. The following IP ranges have been added based on ZxD specification:
        100.72.100.0/24
        100.72.101.0/24
        100.72.102.0/24
        100.74.107.0/24
        100.74.108.0/22
* To call PNP Push APIs from servers **outside** Rakuten network please [contact the PNP team](https://confluence.rakuten-it.com/confluence/display/PNPD/PNP+-+Create+a+ticket+to+contact+us).

# API environment
⚠️ External APIs are the APIs called from an app. You will be using PushPNP SDK to call these APIs. The API endpoints are RAE endpoints.

## Staging API access
* To test Staging on a mobile device it needs to be connected to a WiFi network inside Rakuten Intra so that it can connect to the Staging environment.
* To access the Staging environment outside Rakuten Intra ensure you use **stg-reverse-proxy**. If you do not have access please [request it from SYS team](https://confluence.rakuten-it.com/confluence/display/DEVPROXY/PROXY+Home). You may also need to [request RAE to whitelist the stg-reverse-proxy](https://confluence.rakuten-it.com/confluence/display/QA/%5BQA_KB%5DRAE+Staging+Proxy+Access+for+Off-site).
* To configure your app to use a Staging endpoint (e.g. https://stg.app.rakuten.co.jp , https://stg.24x7.app.rakuten.co.jp) for Push PNP see [this section](#setting-a-custom-configuration).

# Using PNP features

## How to use PNP with RAE (Rakuten App Engine)

⚠️ The RAE API is enabled by default.

* Enable RAE in RPushPNPManager:

**Swift**

```swift
RPushPNPManager.sharedInstance().enable(.RAE)
```

**Objective-C**

```objective-c
[RPushPNPManager.sharedInstance enableAPI:RPushPNPManagerAPITypeRAE];
```

* Use Staging:

**Swift**

```swift
let configuration = RWCURLRequestConfiguration()
configuration.baseURL = URL.init(string: "https://stg.app.rakuten.co.jp")
RPushPNPClient.shared().clientConfiguration = configuration
```

**Objective-C**

```objective-c
RWCURLRequestConfiguration *configuration = RWCURLRequestConfiguration.new;
configuration.baseURL = [NSURL URLWithString:@"https://stg.app.rakuten.co.jp"];
RPushPNPClient.sharedClient.configuration = configuration;
```

* Use Production (set by default):

**Swift**

```swift
let configuration = RWCURLRequestConfiguration()
configuration.baseURL = URL.init(string: "https://app.rakuten.co.jp")
RPushPNPClient.shared().clientConfiguration = configuration
```

**Objective-C**

```objective-c
RWCURLRequestConfiguration *configuration = RWCURLRequestConfiguration.new;
configuration.baseURL = [NSURL URLWithString:@"https://app.rakuten.co.jp"];
RPushPNPClient.sharedClient.configuration = configuration;
```

## How to use PNP with API-C (API Catalog) / ID-SDK

If you don't have a Client on API-C then please go to [API-C Self-service Dashboard](https://confluence.rakuten-it.com/confluence/x/dPlmj), [Setup your Organization](https://confluence.rakuten-it.com/confluence/x/jPlmj) and [Add a Client](https://confluence.rakuten-it.com/confluence/x/sP5mj).

Accessing PNP API as Rakuten Member requires App user to login to Rakuten Membership Services using ID SDK and OMNI first. Please follow these [steps](https://confluence.rakuten-it.com/confluence/x/5w2Bmg).

* Enable API-C in RPushPNPManager:

**Swift**

```swift
RPushPNPManager.sharedInstance().enable(.APIC)
```

**Objective-C**

```objective-c
[RPushPNPManager.sharedInstance enableAPI:RPushPNPManagerAPITypeAPIC];
```

* Use Staging:

**Swift**

```swift
let configuration = RWCURLRequestConfiguration()
configuration.baseURL = URL.init(string: "https://stg.gateway-api.rakuten.co.jp")
RPushPNPClient.shared().clientConfiguration = configuration
```

**Objective-C**

```objective-c
RWCURLRequestConfiguration *configuration = RWCURLRequestConfiguration.new;
configuration.baseURL = [NSURL URLWithString:@"https://stg.gateway-api.rakuten.co.jp"];
RPushPNPClient.sharedClient.configuration = configuration;
```

* Use Production (set by default):

**Swift**

```swift
let configuration = RWCURLRequestConfiguration()
configuration.baseURL = URL.init(string: "https://gateway-api.global.rakuten.com")
RPushPNPClient.shared().clientConfiguration = configuration
```

**Objective-C**

```objective-c
RWCURLRequestConfiguration *configuration = RWCURLRequestConfiguration.new;
configuration.baseURL = [NSURL URLWithString:@"https://gateway-api.global.rakuten.com"];
RPushPNPClient.sharedClient.configuration = configuration;
```

Then an access token has to be fetched as below by passing the API-C Client ID / API-C Client Secret or the IDSDK Exchange Token.

To obtain an ID SDK Exchange Token you need to integrate the [ID SDK](https://pages.ghe.rakuten-it.com/id-sdk/specs/user-guide/) and then follow these steps to request an [exchange token](https://pages.ghe.rakuten-it.com/id-sdk/specs/user-guide/#request-exchange-token).

⚠️ The IDSDK Exchange Token is optional and can be passed as nil.
⚠️ If the IDSDK Exchange Token is passed as nil, an anonymous access token is returned.

* Fetch a Non-Member access token:

**Swift**

```swift
let parameters = RPushPNPAPIParameters()
parameters.clientId = "my-apic-client-id"
parameters.clientSecret = "my-apic-client-secret"

RPushPNPManager.sharedInstance().fetchAccessToken(with: parameters) { error in
    
} successCompletion: { accessToken in
    
}
```

**Objective-C**

```objective-c
RPushPNPAPIParameters *parameters = RPushPNPAPIParameters.new;
parameters.clientId = @"my-apic-client-id";
parameters.clientSecret = @"my-apic-client-secret";

[RPushPNPManager.sharedInstance fetchAccessTokenWithParameters:parameters failureCompletion:^(NSError * _Nonnull error) {
    
} successCompletion:^(NSString * _Nonnull accessToken) {
    
}];
```

* Fetch a Member access token:

**Swift**

```swift
let parameters = RPushPNPAPIParameters()
parameters.token = "my-idsdk-exchange-token"

RPushPNPManager.sharedInstance().fetchAccessToken(with: parameters) { error in
    
} successCompletion: { accessToken in
    
}
```

**Objective-C**

```objective-c
RPushPNPAPIParameters *parameters = RPushPNPAPIParameters.new;
parameters.token = @"my-idsdk-exchange-token";

[RPushPNPManager.sharedInstance fetchAccessTokenWithParameters:parameters failureCompletion:^(NSError * _Nonnull error) {
    
} successCompletion:^(NSString * _Nonnull accessToken) {
    
}];
```

## Registering for Push PNP notifications
⚠️ Your application needs to register for push notifications every time it is launched, since the **device token** returned by iOS may change. 

The module will use its cache to only send the request to the server when the device token has changed or the `rpCookie` has not previously been fetched/stored.

To get the device token required for PNP registration, add a call to the `registerForRemoteNotifications` method in your App Delegate:

**Swift**

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

    let application = UIApplication.shared
    let center = UNUserNotificationCenter.current()
    center.delegate = self
    center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in

        if let error = error {
            print("UNUserNotificationCenter requestAuthorization failed: \(error)")
        } else if (granted) {
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
    return true
}
```

**Objective-C**

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIApplication *application = [UIApplication sharedApplication];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)
                completionHandler:^(BOOL granted, NSError * _Nullable error) {

        if (error) {
            NSLog(@"UNUserNotificationCenter requestAuthorization failed with error %@", error);
        } else if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [application registerForRemoteNotifications];
            });
        }
    }];
    return YES;
}
```

Implement the delegate method `didRegisterForRemoteNotificationsWithDeviceToken` to receive the device token which you can use to register with PNP:

**Swift**

```swift
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let request = RPushPNPRegisterDeviceRequest(accessToken: "your-token",
                                                    pnpClientIdentifier: "your-client-id",
                                                    pnpClientSecret: "your-client-secret",
                                                    deviceToken: deviceToken)

        RPushPNPManager.sharedInstance().registerDevice(with: request) { (success, error) in
            guard success == true else {
                return print("Couldn't register to PNP: \(error?.localizedDescription ?? "no error description")")
            }            
        }?.resume()
    }
```

**Objective-C**

```objective-c
    - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
      RPushPNPRegisterDeviceRequest *request = [RPushPNPRegisterDeviceRequest requestWithAccessToken:...
                                                                                 pnpClientIdentifier:...
                                                                                     pnpClientSecret:...
                                                                                         deviceToken:deviceToken];
      [[RPushManager.sharedInstance registerDeviceWithRequest:request
                                              completionBlock:^(BOOL success, NSError *__nullable error) {
        if (!success) {
          NSLog("Couldn't register for push notifications: %@", error.localizedDescription);
        }
      }] resume];
    }
```

⚠️ Note that the call to the `registerForRemoteNotifications` Apple API can fail in some circumstances (for example, Push doesn't work on the simulator) so it may be useful to implement the delegate method `- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error` and check the error received.

## Unregistering from PNP

**Swift**

```swift
let request = RPushPNPUnregisterDeviceRequest(accessToken: "your-token",
                                                pnpClientIdentifier: "your-client-id",
                                                pnpClientSecret: "your-client-secret",
                                                deviceToken: deviceToken)

RPushPNPManager.sharedInstance().unregisterDevice(with: request) { (success, error) in
    guard success == true else {
        return print("Couldn't unregister from PNP: \(error?.localizedDescription ?? "no error description")")
    }
}?.resume()
```

**Objective-C**

```objective-c
RPushPNPUnregisterDeviceRequest *request = [RPushPNPUnregisterDeviceRequest requestWithAccessToken:...
                                                                                pnpClientIdentifier:...
                                                                                    pnpClientSecret:...
                                                                                        deviceToken:...];
[[RPushManager.sharedInstance unregisterDeviceWithRequest:request
                                            completionBlock:^(BOOL success, NSError *__nullable error) {
    if (!success) {
        // handle error
    }
    }] resume];                                                
```

# Setting a custom configuration

To set custom values (e.g. a custom base URL) you can override the shared client's configuration prior to sending a request:

**Swift**

```swift
let configuration = RWCURLRequestConfiguration()
configuration.baseURL = URL.init(string: "https://your.endpoint")
RPushPNPClient.shared().clientConfiguration = configuration
```

**Objective-C**

```objective-c
RWCURLRequestConfiguration *configuration = RWCURLRequestConfiguration.new;
configuration.baseURL = [NSURL URLWithString:@"https://your.endpoint"];
RPushPNPClient.sharedClient.configuration = configuration;

RPushPNPRegisterDeviceRequest *request = [RPushPNPRegisterDeviceRequest requestWithAccessToken:...
                                                                            pnpClientIdentifier:...
                                                                                pnpClientSecret:...
                                                                                deviceIdentifer:...];
```

# Suggested implementation in app

You are free to implement Push PNP support in your app using any approach you prefer. The following architecture is a suggestion based on our [Push sample app](https://gitpub.rakuten-it.com/projects/ECO/repos/ios-push-sample/browse) architecture.

* Add the following dependency to your Podfile:
```ruby
pod 'RakutenEngineClient', :inhibit_warnings => true
```
* Create a `PushService.swift` file with contents:
```swift
private protocol PushClientConfiguring {
    func setConfiguration(baseURL: URL?, cachePolicy: NSURLRequest.CachePolicy)
}
final class PushService: NSObject {
    private let center: UNUserNotificationCenter
    private let pushManager: RPushPNPManager
    private let pushClient: RPushPNPClient
    private var deviceToken: Data?
    private var registerCompletion: ((Result<Data, PushRegistrationError>) -> Void)?
    private var accessToken: String?
    private let raeClientIdentifier: String
    private let raeClientSecret: String
    private let pnpClientIdentifier: String
    private let pnpClientSecret: String
    private var userId: String? = nil
    private var context: RETokenRequestContext? = nil
    private var _isRegistered: Bool = false
    private var cachedPushIdentifier: String?
    private let scopes: Set<String> = ["30days@Access","90days@Refresh","pnp_common_getunreadcount","pnp_common_pushedhistory","pnp_common_sethistorystatus","pnp_ios_register","pnp_ios_unregister","pnp_ios_denytype_check","pnp_ios_denytype_update"]
    init(raeClientIdentifier: String,
            raeClientSecret: String,
            pnpClientIdentifier: String,
            pnpClientSecret: String,
            baseURL: URL?) {
        self.center = UNUserNotificationCenter.current()
        self.raeClientIdentifier = raeClientIdentifier
        self.raeClientSecret = raeClientSecret
        self.pnpClientIdentifier = pnpClientIdentifier
        self.pnpClientSecret = pnpClientSecret
        self.pushManager = RPushPNPManager()
        self.pushClient = RPushPNPClient()
        super.init()
        self.setConfiguration(baseURL: baseURL, cachePolicy: .useProtocolCachePolicy)
        self.pushManager.setPushAPIClient(self.pushClient)
    }
    deinit {
        registerCompletion = nil
    }
}
extension PushService: PushClientConfiguring {
    func setConfiguration(baseURL: URL?, cachePolicy: NSURLRequest.CachePolicy) {
        let configuration = RWCURLRequestConfiguration()
        configuration.baseURL = baseURL
        configuration.cachePolicy = cachePolicy
        pushClient.clientConfiguration = configuration
    }
}
```
* Create a PushService:
```swift
pushServiceProduction = PushService(raeClientIdentifier: pushsampleKeys.raeClientIdentifierProduction,
    raeClientSecret: pushsampleKeys.raeClientSecretProduction,
    pnpClientIdentifier: pushsampleKeys.pnpClientIdentifierProduction,
    pnpClientSecret: pushsampleKeys.pnpClientSecretProduction,
    baseURL: URL(string: "https://app.rakuten.co.jp"))
```
* Declare a User type:
```swift
public enum User {
    case notMember(String), member(String, String)
}
```
* Register to Apple APNs Push Notification service:
```swift
func registerForRemoteNotifications(user: User,
                                    options: UNAuthorizationOptions,
                                    completion: @escaping (Result<Data, PushRegistrationError>) -> Void) {


    switch user {
    case .notMember(let userId):
        self.userId = userId
        context = REClientCredentialsTokenRequestContext()


    case .member(let userId, let password):
        self.userId = userId
        context = REJapanPasswordTokenRequestContext(username: userId, password: password)
    }
    registerCompletion = completion
    center.requestAuthorization(options: options) { [weak self] (granted, error) in
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            guard granted else {
                completion(.failure(.authorize(error)))
                self.registerCompletion = nil
                return
            }


            self.center.delegate = self
            self.center.setNotificationCategories(Set([self.imageCategory, self.gifCategory, self.videoCategory, self.audioCategory]))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}
```
* Receive the device token in the following AppDelegate method:
```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    dependenciesManager.pushService.registerDevice(deviceToken: deviceToken)
}
```
* Request an RAE access token:
```swift
func requestAccessToken(context: RETokenRequestContext,
                        completion: @escaping (Result<String, Error>) -> Void) {
    let request = RETokenRequest(clientIdentifier: raeClientIdentifier,
                                    clientSecret: raeClientSecret,
                                    context: context)
    request.scopes = scopes
    pushClient.dataTask(forRequestSerializer: request, responseParser: AccessTokenApplication.self) { [weak self] (result, error) in
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let accessToken = result as? String else {
            completion(.failure(NSError.unknownError()))
            return
        }
        self?.accessToken = accessToken
        completion(.success(accessToken))
        }?.resume()
}
```
Now you can pass the fetched RAE token into the SDK's PushPNP API methods.

⚠️ Note that the above is only a suggested implementation and you are free to implement it however you like.

# Rich Push Notifications

From v3.0.0 the SDK supports Rich Push notifications. See the [Rich Push feature user guide in the GitPub repo](rich_push_notifications.html).

Note: Please refer to ["How to send Rich Push Notification"](https://confluence.rakuten-it.com/confluence/display/PNPD/Sending+Rich+Push+Messages#SendingRichPushMessages-Sendingarichpush) documentation for more details. If you have any related question or need to report an issue please create a request via ["PNP - Create a ticket to contact us"](https://confluence.rakuten-it.com/confluence/display/PNPD/PNP+-+Create+a+ticket+to+contact+us?moved=true).

# Uninstall tracking

PNP sends uninstall tracking push (custom silent push) to all the devices of a client. Client has to opt-in for uninstall tracking push.
If a device has uninstalled the app, on receiving a push request for that device, the Apple Push Notification service returns a specific error message to PNP.
PNP marks the device as uninstalled and sets the uninstall detection date to be the same as push sent date.

iOS apps has to simply drop this kind of push. The end-user should not receive any kind of attention for it. 

You can use the utility method in `RPushPNPUninstallTrackingHelper` to check if your app has received or was launched by a PNP Uninstall Tracking Push.
`isUninstallTracking(payload:)` will return true on PNP Uninstall Tracking Push Notifications.

You can ignore the PNP Uninstall Tracking Push Notifications in this delegate method:

```swift
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if !RPushPNPUninstallTrackingHelper.isUninstallTracking(payload: userInfo) {
        // The PNP uninstall tracking push notification is ignored
    }
}
```

```objective-c
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    if (![RPushPNPUninstallTrackingHelper isUninstallTrackingWithPayload:userInfo]) {
        // The PNP uninstall tracking push notification is ignored
    }
}
```

# Pitfalls

## APNS

There is no need to unregister from APNS when your app unregisters from PNP.
When the app unregisters from PNP, the app's APNS device token is dissociated from the user id or the easy id.
The app only needs to register to APNS at launch:
```swift
UIApplication.shared.registerForRemoteNotifications()
```

```objective-c
[UIApplication.sharedApplication registerForRemoteNotifications];
```

# macOS push tester app

The SDK team's [macOS push tester](https://github.com/rakutentech/macos-push-tester) app can be useful when integrating and testing push notifications. Note that this app does not use Rakuten PNP and instead communicates directly with the Apple APNs servers using a local server on your mac.

# Migration guide

## 2.1.0

See the note about changes to [registration options](advanced_usage.html#set-user-segmentation-options-when-registering) since v2.1.0.

## 1.0.0

To migrate from `RakutenPushNotificationPlatformClient` module replace that dependency in your `Podfile` with `RPushPNP` - see [Getting started](#getting-started). The class names should be migrated as follows:

| RakutenPushNotificationPlatformClient | RPushPNP
| --------------------------------------------- | ------------
| RPNPClient | RPushPNPManager
| RPNPDenyType | RPushPNPDenyType
| RPNPGetDenyTypeRequest | RPushPNPGetDenyTypeRequest
| RPNPSetDenyTypeRequest | RPushPNPSetDenyTypeRequest
| RPNPHistoryData | RPushPNPHistoryData
| RPNPGetPushedHistoryRequest | RPushPNPGetPushedHistoryRequest
| RPNPSetHistoryStatusRequest | RPushPNPSetHistoryStatusRequest
| RPNPUnreadCount | RPushPNPUnreadCount
| RPNPGetUnreadCountRequest | RPushPNPGetUnreadCountRequest
| RPNPRegisterDeviceRequest | RPushPNPRegisterDeviceRequest
| RPNPUnregisterDeviceRequest | RPushPNPUnregisterDeviceRequest