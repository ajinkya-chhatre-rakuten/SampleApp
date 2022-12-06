# RakutenIdInformationClient
## End Of Life
This module is approaching the end of its life, support for it ends on June 30 2018. After that date there will be no more updates to the module. We recommend you migrate away from this module or port the source code to your own code base (https://gitpub.rakuten-it.com/scm/eco/core-ios-api-idinformation.git).

---

The **RakutenIdInformationClient** provides an interface for making requests and parsing responses from [RAE's IdInformation service](https://confluence.rakuten-it.com/confluence/pages/viewpage.action?pageId=276662257).

## Getting started
### Installing RakutenIdInformationClient
Follow [Cocoapod's official documentation](https://guides.cocoapods.org/using/using-cocoapods.html) to get Cocoapods set up.

Add the following to your Podfile:

    source 'https://github.com/CocoaPods/Specs.git'
    source 'https://gitpub.rakuten-it.com/scm/eco/core-ios-specs.git'

    pod 'RakutenIdInformationClient'

Running `pod install` will install **RakutenIdInformationClient** library.

### Using RakutenIdInformationClient
We need to create a request corresponding the API we want to use. In the example below, a request of **RIIGetOpenIdRequest** is created for issuing requests for Rakuten App Engine's IdInformation/GetOpenID endpoint.

##### Objective-C

    RIIGetOpenIdRequest *request = [RIIGetOpenIdRequest requestWithAccessToken:accessToken];

##### Swift
    
    var request: RIIGetOpenIdRequest = RIIGetOpenIdRequest(accessToken: accessToken)

After creating a request, we create a NSURLSessionData task by using **RIIClient**

##### Objective-C

    NSURLSessionDataTask *dataTask;
    dataTask = [[RIIClient sharedClient] getOpenIdWithRequest:request 
                                              completionBlock:^(RIIOpenId * _Nullable result, NSError * _Nullable error) 
    {
        // Use the returned result;
    }];
    [dataTask resume];

##### Swift

    var dataTask: NSURLSessionDataTask
    dataTask = RIIClient.sharedClient().getOpenIdWithRequest(request, completionBlock: {(result: RIIOpenId, error: NSError) -> Void in
        // Use the returned result;
    })
    dataTask.resume()


## What's new?
@ref idinformationclient-changelog "[Read the changelog]"

@page idinformationclient-changelog Changelog

### 1.1.0 (2018-03-22)
* [MIDS-266](https://jira.rakuten-it.com/jira/browse/MIDS-266): ⭐️ [iOS] Basic support for watchOS

