## End Of Life
This module is approaching the end of its life, support for it ends on June 30 2018. After that date there will be no more updates to the module. We recommend you migrate away from this module or port the source code to your own code base (https://gitpub.rakuten-it.com/scm/eco/core-ios-api-kit.git).

---

The **RakutenWebClientKit** module provides a foundation for creating web API wrapping libraries.

## Installing
Please refer to the [Ecosystem SDK documentation](/ios-sdk/sdk-latest/#introduction) for a detailed step-by-step guide to installing the SDK.

If you would rather use this SDK module as a standalone library, your `Podfile` should contain:

    source 'https://github.com/CocoaPods/Specs.git'
    source 'https://gitpub.rakuten-it.com/scm/eco/core-ios-specs.git'

    pod 'RakutenWebClientKit'

## Getting started
For RakutenWebClientKit, web service endpoints are split into request serializers and response parsers.
* Request serializers expose parameters and generate requests.
* Response parsers parse server responses and generate models.

### Creating a request serializer
1. Create a class that conforms to the @ref RWCURLRequestSerializable protocol.
2. Add all the endpoint parameters as properties. It's considered best practice to use the `copy` retain policy.
3. Add a designated initializer which accepts all required parameters, for convenience.

### Creating a response parser
1. Create a class that conforms to the @ref RWCURLResponseParser protocol.

### Using the web client
This module provides a minimal @ref RWClient class that can be used as-is with arbitrary @ref RWCURLRequestSerializable "request serializers" and @ref RWCURLResponseParser "response parsers".

## What's new?
@ref api-kit-changelog "[Read the changelog]"

@page api-kit-changelog Changelog

### 1.3.0: (2018-03-22)

- Added experimental support for watchOS


### 1.2: Added NSOperation wrapper for tasks (2016-05-19)

- Added the @ref RWCURLSessionTaskOperation class, so that SDK modules with methods returning `NSOperation` instances can do so painlessly.

### 1.1: First stable version (2015-12-17)

