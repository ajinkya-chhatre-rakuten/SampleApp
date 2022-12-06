# RLogger
This module provides APIs for logging.
It supports iOS 12.0 and above.
It is intended to be used only by Rakuten approved applications.

#### IMPORTANT: Future versions of RLogger will be available as a part of RSDKUtils module
https://github.com/rakutentech/ios-sdkutils/

## Installing with CocoaPods
To use the module in its default configuration your `Podfile` should contain:

```ruby
pod 'RLogger', :git => 'https://gitpub.rakuten-it.com/scm/eco/ios-logger.git'
```

Run `pod install` to install the module.

## Installing with Swift Package Manager
Open your project settings in Xcode and add a new package in 'Swift Packages' tab:
* Repository URL: `https://gitpub.rakuten-it.com/scm/eco/ios-logger.git`
* Version settings: branch `master`

## Usage

```swift
import RLogger

RLogger.loggingLevel = .verbose
RLogger.verbose("hello world")
```

## Running tests
Run following command in project directory:
```
swift test
```

## Changelog

### RLogger 2.0.0 (in-progress)
* [SDKCF-4186] **BREAKING:** Remove Objective-C support
* [SDKCF-4186] Make RLogger available as a Swift Package

### RLogger 1.2.1 (2021-03-24)
* Set podspec swift version to 5.3

### RLogger 1.2.0 (2021-02-23)
* [SDKCF-3346](https://jira.rakuten-it.com/jira/browse/SDKCF-3346): RLogger Issue fix - RLogger-Swift.h header is missing in RakutenCard project
* [SDKCF-3217](https://jira.rakuten-it.com/jira/browse/SDKCF-3217): Set the correct caller module name in the logs
* [SDKCF-3272](https://jira.rakuten-it.com/jira/browse/SDKCF-3272): Set up bitrise CI
* [SDKCF-3346](https://jira.rakuten-it.com/jira/browse/SDKCF-3216): Set Swift version 5 to the RLogger Xcode project
