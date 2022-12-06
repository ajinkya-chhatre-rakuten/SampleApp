@attention This library is compatible with iOS 7.0+ and watchOS 4.0+. It has been tested with iOS 8.4 and above.

## Introduction

This library allows applications to get pieces of information about the device they are running on.

### Available Information

The following information is available.

* The device's [fingerprint](@ref RSDKDeviceInformation::fingerprint), a value suitable for fingerprinting a device.
* The device's [last known location](@ref RSDKDeviceInformation::lastKnownCoordinate), as most-recently acquired by any application.
* The [carrier(cellular operator)'s name](@ref RSDKDeviceInformation::carrierName), if registered to a network.
* The current [data network technology](@ref RSDKDeviceInformation::dataNetworkTechnology)., e.g. `LTE`.
* The device's [model identifier](@ref RSDKDeviceInformation::modelIdentifier).
* The device's [unique device identifier](@ref RSDKDeviceInformation::uniqueDeviceIdentifier).

@attention For [unique device identifier](@ref RSDKDeviceInformation::uniqueDeviceIdentifier) to work, keychain access **MUST** be properly configured first. Please refer to @ref device-information-keychain-setup "Setting up the keychain" for the right way to do so. If the keychain is locked or the identifier could not otherwise be read, [RSDKDeviceInformation.uniqueDeviceIdentifier](@ref RSDKDeviceInformation::uniqueDeviceIdentifier) returns `nil`. Applications should retry when the application becomes active again.

## Changelog

### 1.7.1 (2018-06-18)

* [MEMSDK-260](https://jira.rakuten-it.com/jira/browse/MEMSDK-260): 💣 fingerprint generation might crash app if not called from main thread

### 1.7.0 (2018-03-22)

* Added experimental support for watchOS.

### 1.6.0 (2018-01-11)

* Added [RSDKDeviceInformation.fingerprint](@ref RSDKDeviceInformation::fingerprint).
* Added [RSDKDeviceInformation.carrierName](@ref RSDKDeviceInformation::carrierName).
* Added [RSDKDeviceInformation.dataNetworkTechnology](@ref RSDKDeviceInformation::dataNetworkTechnology).
* Added [RSDKDeviceInformation.lastKnownCoordinate](@ref RSDKDeviceInformation::lastKnownCoordinate).

@page device-information-keychain-setup Setting up the keychain

Developers must add the `jp.co.rakuten.ios.sdk.deviceinformation` keychain access group
to their application's **Keychain Sharing** capabilities, as shown below.

@image html KeychainSharingSettings.png "Keychain sharing setup, with the aforementioned access group at the end of the list" width=80%

If keychain access is not properly configured, [RSDKDeviceInformation.uniqueDeviceIdentifier](@ref RSDKDeviceInformation::uniqueDeviceIdentifier)
will raise an `NSObjectInaccessibleException` exception.

@warning Note that `jp.co.rakuten.ios.sdk.deviceinformation` should **never** be the
first entry of this list. The first entry should always be your application's bundle identifier.
