## End Of Life
This module is approaching the end of its life, support for it ends on June 30 2018. After that date there will be no more updates to the module. We recommend you migrate away from this module or port the source code to your own code base (https://gitpub.rakuten-it.com/scm/eco/core-ios-api-engine.git).

---

@tableofcontents
@section api-rae-engine-module Introduction
This library provides an interface for making requests and parsing responses from [RAE's platform level services](https://confluence.rakuten-it.com/confluence/display/RAED/Platform).

@section api-rae-engine-installing Installing
See the [Ecosystem SDK documentation](/ios-sdk/sdk-latest/#introduction) for a detailed step-by-step guide to installing the SDK.

Alternatively, you can also use this SDK module as a standalone library. To use the SDK module as a standalone library, your `Podfile` should contain:

@code{.rb}
    source 'https://github.com/CocoaPods/Specs.git'
    source 'https://gitpub.rakuten-it.com/scm/eco/core-ios-specs.git'

    pod 'RakutenEngineClient'
@endcode

Run `pod install` to install the module and its dependencies.

@section api-rae-engine-tutorial Getting started
@subsection api-rae-engine-create-token-request Creating a Rakuten App Engine token request
In the example below, a token request for Japan ID is created then it is used by @ref REClient to produce an NSURLSessionDataTask for requesting tokens.

##### Objective-C

@code{.m}
    RETokenRequest *request = [RETokenRequest japanPasswordTokenRequestWithClientIdentifier:clientID
                                                                               clientSecret:clientSecret
                                                                                   username:username
                                                                                   password:password];
    [[REClient.sharedClient tokenWithRequest:request
                             completionBlock:^(RETokenResult *result, NSError *error) {
        // Use the token result
    }] resume];
@endcode

##### Swift

@code{.swift}
    let request = RETokenRequest.japanPasswordTokenRequest(clientIdentifier: clientID,
                                                               clientSecret: clientSecret,
                                                                   username: username,
                                                                   password: password)
    REClient.sharedClient().token(request: request) {
        (result: RETokenResult, error: NSError) -> Void in
        // Use the token result
    }.resume()
@endcode

@subsection api-rae-engine-privacy-policy Handling privacy policy agreement
The following code snippet shows how to notify the backend that the user has agreed to the terms of
the [Rakuten Japan privacy policy](https://privacy.rakuten.co.jp) version `20421225`:

##### Objective-C

@code{.m}
    RETokenRequest *request = [RETokenRequest japanPasswordTokenRequestWithClientIdentifier:clientID
                                                                               clientSecret:clientSecret
                                                                                   username:username
                                                                                   password:password
                                                                          serviceIdentifier:serviceID
                                                                       privacyPolicyVersion:@"20421225"];
    [[REClient.sharedClient tokenWithRequest:request
                             completionBlock:^(RETokenResult *result, NSError *error) {
        // Use the token result
    }] resume];
@endcode

##### Swift

@code{.swift}
    let request = RETokenRequest.japanPasswordTokenRequest(clientIdentifier: clientID,
                                                               clientSecret: clientSecret,
                                                                   username: username,
                                                                   password: password,
                                                          serviceIdentifier: serviceID,
                                                       privacyPolicyVersion: "20421225")
    REClient.sharedClient().token(request: request) {
        (result: RETokenResult, error: NSError) -> Void in
        // Use the token result
    }.resume()
@endcode

@section api-rae-engine-changelog Changelog

@subsection api-rae-engine-1-5-0 1.5.0 (2018-06-18)

* [MEMSDK-261](https://jira.rakuten-it.com/jira/browse/MEMSDK-261): ⭐️ [MEMSDK-261] Integrate with challenger, add parameter for solved challenge to @ref REJapanPasswordTokenRequestContext

@subsection api-rae-engine-1-4-1 1.4.1 (2018-05-21)

* [MEMSDK-235](https://jira.rakuten-it.com/jira/browse/MEMSDK-235): 🐛 Modifies the encoding of tracking parameters so that they do not contain unicode, which was causing problems between RAE and JID3.

@subsection api-rae-engine-1-4-0 1.4.0 (2018-03-22)

* [MIDS-266](https://jira.rakuten-it.com/jira/browse/MIDS-266): ⭐️ Basic support for watchOS

@subsection api-rae-engine-1-3-0 1.3.0 (2018-01-11)

* [MEMSDK-143](https://jira.rakuten-it.com/jira/browse/MEMSDK-143): 🚚 Move device fingerprint generation to device-information library.
* [MEMSDK-139](https://jira.rakuten-it.com/jira/browse/MEMSDK-139): Remove mentions of www.raksdtd.com from the documentation.

@subsection api-rae-engine-1-2-1 1.2.1 (2017-10-10)

* [REM-23826](https://jira.rakuten-it.com/jira/browse/REM-23826): Track client_credentials token request failure.

@subsection api-rae-engine-1-2-0 1.2.0 (2017-07-18)

* Added @ref REJapanPasswordTokenRequestContext::privacyPolicyVersion.
* Automatically populates [tracking parameters](https://confluence.rakuten-it.com/confluence/display/RAED/password#password-RequestParameters) upon serializing a @ref RETokenRequest "token request" that uses a @ref REJapanPasswordTokenRequestContext "password grant type".

@subsection api-rae-engine-1-1-0 1.1.0 (2016-11-07)

* Global ID support is deprecated and will be removed in the next major version of our SDK (3.0), scheduled to be released in Q1 2017. Applications relying on Global ID are invited to implement and maintain authentication as part of their source code base.

@subsection api-rae-engine-1-0-0 1.0.0 (2016-01-05)

* Initial version
