## End Of Life
This module is approaching the end of its life, support for it ends on June 30 2018. After that date there will be no more updates to the module. We recommend you migrate away from this module or port the source code to your own code base (https://gitpub.rakuten-it.com/scm/eco/core-ios-api-memberinformation.git).

---

@tableofcontents
@section memberinformation-module Introduction
The **RakutenMemberInformationClient** module provides an interface for making requests and parsing responses from the [RAE MemberInformation service](https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=657983438).

@section memberinformation-installing Installing
See the [Ecosystem SDK documentation](/ios-sdk/sdk-latest/#introduction) for a detailed step-by-step guide to installing the SDK.

@section memberinformation-tutorial Getting started
We need to create a request corresponding the API we want to use. In the example below, a @ref RMIGetNameRequest is created to request a user's name from the RAE `MemberInformation/GetName` API.

##### Objective-C

    RMIGetNameRequest *request = [RMIGetNameRequest requestWithAccessToken:accessToken];

##### Swift
    
    var request = RMIGetNameRequest(accessToken: accessToken)

After creating a request, we create a [NSURLSessionDataTask](https://developer.apple.com/reference/foundation/nsurlsessiondatatask) task by using the shared @ref RMIClient.

##### Objective-C

    NSURLSessionDataTask *dataTask = [RMIClient.sharedClient getNameWithRequest:request 
                                                                completionBlock:^(RMIName *__nullable result, NSError *__nullable error) {
        // Use the returned result
    }];
    [dataTask resume];

##### Swift

    var dataTask = RMIClient.sharedClient().getNameWithRequest(request) { (result, error) -> Void in
        // Use the returned result
    }
    dataTask?.resume()

@section memberinformation-rank-api Selecting the right GetRank API
By default, @ref RMIGetRankRequest uses the legacy `MemberInformation/GetRank` API, that requires
your client be authorized for the `memberinfo_read_rank` scope.

This API is now deprecated, and applications should migrate to using the new `MemberInformation/GetRankSafe` API,
that unfortunately doesn't work with the legacy scope but requires a new one: `memberinfo_read_rank_safe`.

If your application uses this new API, it **must** first configure the @ref RMIGetRankRequest class like this:

    RMIGetRankRequest.endpoint = RMIGetRankSafeEndpoint

@section memberinformation-changelog Changelog
@subsection memberinformation-1-3-0 1.3.0 (2018-03-22)
* [MIDS-266](https://jira.rakuten-it.com/jira/browse/MIDS-266): ⭐️ [iOS] Basic support for watchOS

@subsection memberinformation-1-2-1 1.2.1 (2017-11-13)
* Date fields in the `MemberInformation/GetLimitedTimePoint` API response are now parsed as JST.

@subsection memberinformation-1-2-0 1.2.0 (2017-09-06)
* Added support for the `MemberInformation/GetLimitedTimePoint` API.

@subsection memberinformation-1-1-0 1.1.0 (2017-07-18)
* Added support for the `MemberInformation/GetRankSafe` API, using @ref RMIGetRankRequest.endpoint.

@subsection memberinformation-1-0-6 1.0.6 (2017-02-06)
* The `GetCredit` API is being abolished, so we've deprecated everything related.

@subsection memberinformation-1-0-5 1.0.5 (2016-06-21)
* Fixes a crash on iOS 7. 

@subsection memberinformation-1-0-4 1.0.4 (2016-06-02)
* Our `[out]` parameters now use the standard `out` keyword instead of `__autoreleasing`.

@subsection memberinformation-1-0-3 1.0.3 (2016-05-23)
* RMIPoint.pendingStandardPoints is now deprecated. Please use RMIPoint.futurePoints from now on.

@subsection memberinformation-1-0-2 1.0.2 (2016-05-23)
* Added support for the `GetAddressList`, `GetBasicInfo`, `GetCredit`, `GetPoint`, `GetRank`, `GetSafeBulk` and `GetUserInfo` API methods.

@subsection memberinformation-1-0-1 1.0.1 (2016-03-14)
* Added support for the `GetAddress`, `GetEmail`, `GetName` and `GetPhone` API methods.

@subsection memberinformation-1-0-0 1.0.0 (2016-05-30)
* Initial release.


