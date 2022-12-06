@warning
This library is now in limited maintenance mode. Click [here](https://confluence.rakuten-it.com/confluence/x/HQJAgg) to learn about its replacement, and [here](https://pages.ghe.rakuten-it.com/id-sdk/specs/overview/#motivation) for what motivated us to move away from the old ways.

@note
 To contact our support team, follow [this link](https://tiny.cc/mobile-login-support).

@tableofcontents
@attention
 **This module supports iOS 9.0 and above, as recommended by RGR (see [RGR » CXO Guidelines-Implementation » Instructions Rakuten Group Common Operational Manual for Creating Web Content » System Requirements v1.7](https://confluence.rakuten-it.com/confluence/display/RGR/CXO+Guidelines-Implementation+Instructions?preview=/1006133113/1479387776/%5B002251%5DOpMnl_for_CreatingWebContent_System_Req.pdf)). If your app still requires iOS 8, please use [RAuthentication v3](https://documents.developers.rakuten.com/ios-sdk/authentication-3.16) but be aware that support for that version will end soon.**
 Support for watchOS 4.0 and above is also provided, albeit still experimental.

@section authentication-module Introduction
This SDK provides APIs and UI to easily authenticate Rakuten users, and offers @ref authentication-sso "Single Sign-On" and @ref RAuthenticationAccount "account management".

@warning
 **Single Sign-On** is activated by default, but has some requirements.
 Please refer to the @ref authentication-sso "Single Sign-On Guide" to learn about those.

@warning
 Although not recommended, Single Sign-On can be disabled by modifying
 the @ref RAuthenticator::serviceIdentifier "-serviceIdentifier" property of an
 @ref RAuthenticator "authenticator" before using it.

@section authentication-installing Installing
Three separate libraries are provided:

- @ref RAuthenticationCore "RAuthenticationCore" contains the low-level interfaces for authentication, and is compatible with iOS and watchOS applications, as well as extensions.
- @ref RAuthenticationUI "RAuthenticationUI" contains builtin UI and workflows for login and logout, and is only compatible with iOS applications.
- @ref RAuthenticationChallenge "RAuthenticationChallenge" contain interfaces for working with @ref authentication-challenges "Authentication Challenges".

All libraries are distributed as [pods](https://guides.cocoapods.org/using/getting-started.html). You need to add our
private specs repository https://gitpub.rakuten-it.com/scm/eco/core-ios-specs.git to the top of your `Podfile`, like this:

@code{.rb}
    source 'https://github.com/CocoaPods/Specs.git'
    source 'https://gitpub.rakuten-it.com/scm/eco/core-ios-specs.git' # This is important

    target 'MyApp' do
      pod 'RAuthenticationChallenge'
      pod 'RAuthenticationCore'
      pod 'RAuthenticationUI'
    end
@endcode

Run `pod install --repo-update` to install the libraries and all their dependencies.

@section authentication-tutorial Getting started
The main class is @ref RAuthenticationAccount. It represents an account obtained from the keychain or from an @ref RAuthenticator, and can be written back to the keychain using @ref RAuthenticationAccount#persistWithError:.

Developers can load a specific account using RAuthenticationAccount::loadAccountWithName:service:error:, or all known accounts for a service using RAuthenticationAccount::loadAccountsWithService:error:.

@attention
 Applications can use any service identifier for their own internal purposes, although for **Single Sign-On** it is required of them to use the @ref RAuthenticator::defaultServiceIdentifier "default service identifier" provided by the @ref RAuthenticator subclass they use. @ref RAuthenticator is a base class used for authenticating applications or users, and its concrete subclasses are @ref RAnonymousAuthenticator and @ref RJapanIchibaUserAuthenticator.

@ref RBuiltinLoginWorkflow provides a high-level workflow for logging users in. This is the class you should look up first. Initialize a @ref RBuiltinLoginWorkflow instance using a @ref RBuiltinLoginDialog "builtin login dialog" and a @ref RBuiltinAccountSelectionDialog "builtin account selection dialog", pass it the @ref rauthenticator_factory_block_t "authenticator factory", and call @ref RBuiltinLoginWorkflow::start "-start". **You're done:** the user will be asked to pick an account if one was found using **Single Sign-On** or to sign in manually otherwise, the framework will retrieve an @ref RAuthenticationAccount and save it into the keychain if allowed by the user, and finally hand it to you in the completion block you passed to the workflow.

@note
 For a very simple example on how to leverage @ref RBuiltinLoginWorkflow to log users in your application, check out the **SingleSignOn** project in @ref authentication-samples "Sample Applications".

@subsection authentication-requirements General Requirements
Your application **MUST** meet the following requirements:

Identifier                | Requirement
--------------------------|-------------
`Xcode`                   | You **MUST** use [Xcode](https://developer.apple.com/xcode/) 9.0 or newer.
`Cocoapods`               | You **MUST** use [Cocoapods](https://cocoapods.org/) 1.4.0 or newer.
`TargetOS`                | Your project **MUST** have a deployment target of `iOS 9.0` or newer.
`BaseSDK`                 | Your project **MUST** use a base SDK of `iOS 11.0` or newer (we recommend leaving that setting to its `Latest iOS` default).
`PodSource`               | Your `Podfile` **MUST** declare `source 'https://gitpub.rakuten-it.com/scm/eco/core-ios-specs.git'`.
`Scope.Name`              | You **MUST** request the `memberinfo_read_name` scope when performing user login. This scope is required by our SDK to associate a user account to a name.
`Scope.Access`            | You **MUST** request an access scope when authenticating, e.g. `30days\@Access`.
`SSO.OptOut`              | If you do not want to implement SSO, you **MUST** turn it off explicitly. See the @ref authentication-sso "Single Sign-On Guide" for how to do so.

@subsection authentication-sso-requirements SSO Requirements
If your application implements SSO it **MUST** meet the following requirements:

Identifier             | Requirement
-----------------------|-------------
`SSO.CodeSigning`      | Your application **MUST** have the right App ID prefix (see [Technical Note TN2311](https://developer.apple.com/library/ios/technotes/tn2311/_index.html) for more information): either `5J4GVGN58B` for Enterprise builds or `87CT3T3CK2` for regular AppStore/AdHoc builds.
`SSO.Service`          | The @ref RAuthenticator::serviceIdentifier "-serviceIdentifier" property of the @ref RAuthenticator "authenticator" being used **MUST** be equal to the class's @ref RAuthenticator::defaultServiceIdentifier "+defaultServiceIdentifier" value.
`SSO.Entitlements`     | Your applications **MUST** request access to the keychain access group shared across SSO-enabled apps: `jp.co.rakuten.sdtd.sso`. This is done by adding that value to the `Keychain Groups` array in Xcode's `Capabilities > Keychain Sharing` panel, as shown in the screenshot below this table.
`SSO.StandardLoginWF`  | You **MUST** use RBuiltinLoginWorkflow to perform login, unless you can justify of a reason that makes it not possible.
`SSO.StandardLoginUI`  | You **MUST** use the built-in login UI to perform login, unless you can justify of a reason that makes it not possible.
`SSO.StandardLogoutWF` | You **MUST** use RBuiltinLogoutWorkflow to perform logout, unless you can justify of a reason that makes it not possible.
`SSO.StandardLogoutUI` | You **MUST** use the built-in logout UI to perform logout, unless you can justify of a reason that makes it not possible.
`SSO.AccountLoading`   | You **MUST NOT** manage access tokens yourselves, but obtain tokens from RAuthenticationAccount.loadAccount with the right service identifier (see requirement `SSO.Service` above).
`SSO.CacheUserName`    | Your app **MUST** persist the *username* of the current logged-in user so you can load the matching account using `RAuthenticationAccount.loadAccount` the next time the app becomes active. Since the Rakuten username is considered sensitive information by RGR, it **SHOULD** be persisted in the keychain, not `NSUserDefaults`.
`SSO.HandleLogout`     | When your app becomes active, it **MUST** invalidate any credentials it previously held in memory and reload the current user using `RAuthenticationAccount.loadAccount`. Users must login again if they have been logged out from another app.
`SSO.ForcedUpdates`    | You **MUST** have a mechanism for forcing users to update to a newer version (kill switch), using either [RPing](../ping-latest) or another solution. Your app **MUST** check for forced updates whenever it becomes active, i.e. in `-[UIApplicationDelegate applicationDidBecomeActive:]`, not just on launch.

@image html "Keychain Setup for SSO.png" "Setting up the keychain access group for SSO" width=80%

@note
For **App Extensions** additional steps are required to share keychain between host app and extension, see @ref authentication-app-extension-support "App Extension Support".

## Required Rakuten App Engine scopes
The builtin **Rakuten App Engine** authenticators have the following requirements:

* @ref RAnonymousAuthenticator and @ref RJapanIchibaUserAuthenticator require that your application has been granted an **Access** scope (e.g. `90days@Access`).
* @ref RJapanIchibaUserAuthenticator requires that your application has been granted the `memberinfo_read_name` scope.

@attention If using any of the authenticators above, we ask that you request the `idinfo_read_encrypted_easyid` scope so that we can track conversion rates.

@section authentication-faq Frequently Asked Questions

 <dl><dt>
 **Q: How can I specify a token expiration?**</dt>
 <dd>A: You have to add the proper desired expiration scopes to your @ref RAuthenticator::requestedScopes "requested scopes", e.g. `90days@Access`, `365days@Refresh`…</dd>
 </dl>

 <dl><dt>
 **Q: How can I get the user's profile?**</dt>
 <dd>A: This SDK is for authentication only. To retrieve a user's profile, please use the `MemberInformation` API of RAE.</dd>
 </dl>

@section authentication-workflow Builtin Login Workflow

A standard @ref RBuiltinLoginWorkflow "login workflow" is provided, that
takes care of everything needed to log a user in based on the
@ref RLoginDialog-p "login" and @ref RAccountSelectionDialog-p "account selection"
dialogs the developer provided, and on the chosen @ref RAuthenticator "authenticator".

@section authentication-ui Builtin UI
The module provides several built-in view controllers to application developers,
detailed below, that support both US English and Japanese. Applications can
provide a custom logo or use custom text, as well as translate text into new
languages.

* Our built-in @ref RBuiltinLoginDialog "login dialog" is a concrete implementation
  of the @ref RLoginDialog-p protocol, that presents users with a standard login
  form for providing one's username and password.
* Our built-in @ref RBuiltinAccountSelectionDialog "account selection dialog" is a
  concrete implementation of the @ref RAccountSelectionDialog-p protocol, that
  allow users to pick an existing account or login with a different username. It
  is limited to the most-recently used account due to UI/UX specifications by CWD.
* Our built-in @ref RBuiltinVerificationDialog "verification dialog" asks users to
  confirm an important decision, such as checking out an order, by entering their
  password. Note that the @ref RBuiltinVerificationWorkflow "verification workflow"
  supports **Touch ID** and **Face ID** when it's available.
* Our @ref RBuiltinLogoutWorkflow "standard logout workflow" provides an all-in-one
  solution for logging users out of @ref authentication-sso "Single Sign-On" enabled applications,
  but applications with specific needs can use our @ref RBuiltinLogoutDialog "logout dialog reference implementation"
  to write their own custom logout workflow.

@subsection authentication-ui-login Login Dialog
@image html RBuiltinLoginDialog.png "RBuiltinLoginDialog" width=80%

@ref RBuiltinLoginDialog can be used when a user needs to log in.
It asks the user to fill in their username and password, and calls the methods of its @ref RLoginDialogDelegate-p "delegate" for each action they perform.

@subsection authentication-ui-account-selection Account Selection Dialog
@image html RBuiltinAccountSelectionDialog.png "RBuiltinAccountSelectionDialog" width=80%

@ref RBuiltinAccountSelectionDialog can be used to allow users to either
pick a previously-used account or sign in manually with a different account.
Again, every UI interaction has the view controller call the methods of its
@ref RAccountSelectionDialogDelegate-p "delegate", which performs the actual operations.

@subsection authentication-ui-verification Verification Dialog
@image html RBuiltinVerificationDialog.png "RBuiltinVerificationDialog" width=80%

@ref RBuiltinVerificationDialog can be used to allow users to enter their password
as part of a @ref RBuiltinVerificationWorkflow "verification workflow". Note that
the latter supports **Touch ID** and **Face ID** when they are available, as depicted below:

@image html RBuiltinVerificationDialog-TouchID.png "Touch ID" width=80%

@image html RBuiltinVerificationDialog-FaceID.png "Face ID" width=80%

@subsection authentication-ui-logout Logout Dialog
@image html RBuiltinLogoutDialog.png "RBuiltinLogoutDialog" width=80%

@ref RBuiltinLogoutDialog can be used to ask the user whether they want to sign
out from the current application only, or from all @ref authentication-sso "Single Sign-On" enabled applications.
Depending on the option chosen by the user, an extra confirmation popup is
shown. Note that no actual logout is performed by this UI-only class.

@subsection authentication-presentation-style "Presentation Style"

Builtin workflows's presentation style is configurable by specifying a @ref RBuiltinWorkflowPresentationConfiguration "presentation configuration" when start a workflow.

Sample code to specify FormSheet style for a login workflow.
```swift
  let presentationConfiguration = RBuiltinWorkflowPresentationConfiguration()
  presentationConfiguration.presenterViewController = presenter
  presentationConfiguration.presentationStyle = .formSheet

  RBuiltinLoginWorkflow(
      authenticationSettings: User.authenticationSettings,
      loginDialog: loginDialog,
      accountSelectionDialog: accountSelectionDialog,
      authenticatorFactory: RBuiltinJapanIchibaUserAuthenticatorFactory(User.scopes),
      presentationConfiguration: presentationConfiguration
  ) {
      ...
  }.start()
```

@warning presentation style on iOS 13
Since iOS 13, FormSheet, PageSheet and Popover are all presented as the same card-like style. All of them can be cancelled by pulling down the view on the screen.
For logout workflow, that cancel event cannot be passed to the app if the Popover style is chosen. We **strongly** suggest app developers avoid using the Popover style on iPhones running iOS 13+.

@section authentication-ui-login-autofill Username password autofill for builtin login dialog
@ref RBuiltinLoginDialog "login dialog" support autofill username and password by Shared Web Credentials and third party password manager app extension.

@subsection authentication-ui-login-autofill-swc Enable Shared Web Credentials and Password AutoFill(iOS 11 and above)
@note
- This feature is only available for the @ref RBuiltinLoginDialog "builtin login dialog", if you are using a custom login ui, you need to implement it yourselves. (Nevertheless, you have to follow the following steps to enable Shared Web Credentials and Password AutoFill.)
- You can find more about Password AutoFill [here](https://developer.apple.com/documentation/security/password_autofill)
- You can find more about Shared Web Credentials [here](https://developer.apple.com/documentation/security/shared_web_credentials)

### Steps

1. If your app is not listed in the [Rakuten Japan App Site Association file](https://member.id.rakuten.co.jp/.well-known/apple-app-site-association) yet,  send us an inquiry though our [support page](https://tiny.cc/mobile-login-support) to have it added. Please mention the bundle identifier of your app and the bundle identifier prefix (Team ID).
2. Adding the Associated Domains Entitlement, and add following domains to associated domains:
```
member.id.rakuten.co.jp
grp01.id.rakuten.co.jp
grp02.id.rakuten.co.jp
grp03.id.rakuten.co.jp
grp04.id.rakuten.co.jp
login.account.rakuten.com
```
@image html "Associated Domains Setup for Shared Web Credentials.png" "Associated Domains Setup for Shared Web Credentials" width=80%

###Stock UI behavior
* The built-in @ref RBuiltinLoginDialog "login dialog" attempts to request shared web credentials immediately after it on screen.

@subsection authentication-ui-login-autofill-password-extension Enable autofill from third party password manager app extension
@note
 The built-in @ref RBuiltinLoginDialog "login dialog" can work with password managers handle `org.appextension.find-login-action` scheme.

###Steps
1. Add the custom URL scheme, `org-appextension-feature-password-management` to `LSApplicationQueriesSchemes`, in your target's info.plist
@image html "Custom URL Scheme.png" "Custom URL Scheme" width=80%
2. **Optional:** App can provide a custom password manager button by include an image named RAuthenticationPasswordExtension in your application bundle. If this image is not provided by app, built-in login dialog will use a emoji 🔑  as button title.

###Stock UI behavior
* The built-in @ref RBuiltinLoginDialog "login dialog" embeds a button in the right corner of password input textfield to launch password extension. This button is only displayed while user is not editing password textfield.
@image html "RBuiltinLoginDialogPasswordExtensionEnabled.png" "built-in login dialog with password extension enabled" width=80%

@section authentication-sso Single Sign-On (SSO)
**Single Sign-On** (**SSO** for shorts) is a technique for allowing different
applications to share credentials, so that users don't get asked to input
their username and password every time they install a new application from
the same vendor.

**RAuthentication** provides an API and a @ref authentication-ui "stock UI" for easily enabling SSO
across Rakuten applications. The @ref authentication-samples "sample applications"
**SingleSignOn1**, **SingleSignOn2** and **SingleSignOn3**, which share the same source code,
are examples of how to use it in your own applications.

@note
SSO works by sharing the user's credentials across applications. Although not recommended, Single Sign-On can be
disabled by modifying the @ref RAuthenticator::serviceIdentifier "-serviceIdentifier" property of an @ref RAuthenticator "authenticator"
before using it. If using @ref RBuiltinLoginWorkflow "login workflows", this can be done using a custom @ref rauthenticator_factory_block_t
"authenticator factory". Note that applications should set the @ref RAuthenticator::serviceIdentifier "-serviceIdentifier" property to `nil`,
and thus disable SSO for the authenticator, if the user does not want to have their account remembered.

@note
For **App Extensions** additional steps are required to share keychain between host app and extension, see @ref authentication-app-extension-support "App Extension Support".

@subsection authentication-sso-login Logging in
Signing in with SSO involves the following steps:

1. Loading all the available accounts for a service (e.g. @ref RJapanIchibaUserAuthenticator::defaultServiceIdentifier) with RAuthenticationAccount::loadAccountsWithService:error:.
2. **Optional:** Ask the user to pick one account, or just use the most-recently-used. You can either use a @ref RBuiltinAccountSelectionDialog for this or write your own @ref RAccountSelectionDialog-p "account selection dialog".
3. Sign the user in using @ref RAuthenticator::loginWithCompletion:, after having built an @ref RAuthenticator "authenticator" based on the @ref RAuthenticationAccount "account" 's @ref RAuthenticationAccount::name "-name" and @ref RAuthenticationAccount::password "-password". This can be a @ref RJapanIchibaUserAuthenticator or any custom authenticator.
4. **Or,** if the user chose to sign in using a different account, or no previous account was found, create a new @ref RAuthenticationAccount using @ref RAuthenticator::loginWithCompletion: after having had them input their username and password (you can either use a @ref RBuiltinLoginDialog, or write your own @ref RLoginDialog-p "login dialog").

@note All of the above is taken care of for you by @ref RBuiltinLoginWorkflow, which we encourage you to use unless you have specific requirements. Even so, developers are strongly invited to take a look at its source code, which is to be taken as our **reference implementation**.

@subsection authentication-sso-logout Logging Out
Logging users out is achieved by calling RAuthenticationAccount::logoutWithSettings:options:completion:. The method can **invalidate an access token**, **revoke it on RAE** and **delete an account**.

@attention Deleting an account that was shared across applications deletes it in every applications. This effectively logs the associated user out of every application. For logging a user out of the current application only, developers only need to revoke the account's access token.

@section authentication-challenges Authentication Challenges

Authentication challenges are a fraud prevention measure complementing the automatic flagging of suspicious login attempts by our machine learning algorithms.

The fraud prevention backend implements various levels of confidence to determine if a login attempt is from a genuine user or from an attacker. These levels of **greyness** result in the remote IP address of the client being cleared or blocked for a certain amount of time. For a user who has been incorrectly flagged as a possible attacker, solving an authentication challenge allows to reset the greyness level and allow login immediately.

The [Challenger](https://confluence.rakuten-it.com/confluence/display/GST/Solution+Architecture) service is responsible for dealing and validating authentication challenges. Here is a rough diagram showing how it works:

@image html authentication-challenges.svg

Challenger supports a growing list of challenge types, from **CAPTCHA** and **SMS PIN codes** to **Proof-of-Work**.

@note
Since v4.2.1, our SDK integrates with Challenger. Support has been added to the RJapanIchibaUserAuthenticator to transparently negotiate and solve **clear-pass** and **proof-of-work** challenges (corresponding to values of **0** and **127**, respectively, for Challenger's **ctype**).
You do not have anything to configure for this to work out of the box.

RAuthenticationChallenge is available for you to request and solve challenges, in case you have implemented custom @ref authentication-custom-authenticators "authenticator". RAuthenticationChallenge is a provided as standalone library now.

@code{.rb}
    source 'https://github.com/CocoaPods/Specs.git'
    source 'https://gitpub.rakuten-it.com/scm/eco/core-ios-specs.git' # This is important

    target 'MyApp' do
      pod 'RAuthenticationChallenge'
    end
@endcode

@section authentication-migrating Migration Guides
This section covers migrating data from previous versions of this module.

@subsection authentication-migrating-from-v3 RAuthentication 3 » 4
Version 4.0 drops support for iOS 7 and iOS 8, and adds experimental support for watchOS 4.0.
It also retires all the APIs that were previously marked as deprecated.

Assuming your app targets iOS 9 or above and did not use any deprecated API, there is nothing to do to migrate to version 4.

@section authentication-extensibility Extending
The module can be extended in multiple ways:

@subsection authentication-custom-authenticators Custom authenticators
The @ref RAuthenticator base class provides a framework for defining authentication schemes.
Three concrete subclasses are provided in this module:

* @ref RAnonymousAuthenticator, based on the @ref REClient "token" API, for authenticating applications.
* @ref RJapanIchibaUserAuthenticator, based on the @ref REClient "token" and @ref RMIClient "member information" APIs, for authenticating **Japan Ichiba** users.

Developers can create other authenticators by subclassing any of these classes
and implement a few methods described in the **Subclassing** section of
@ref RAuthenticator 's documentation. Note that @ref RJapanIchibaUserAuthenticator
subclasses an intermediate abstract authenticator,
@ref RUserPasswordAuthenticator, which custom authenticators requiring a username
and a password can be based upon.

@subsection authentication-custom-ui Custom UI
@ref authentication-ui "Builtin UI" is provided for quick prototyping, but
developers who want to write their own view controllers and have them play
nicely with our @ref authentication-workflow "login workflows" simply have to
make sure to have their classes conform to either @ref RLoginDialog-p,
@ref RAccountSelectionDialog-p or both!

@subsection authentication-custom-localization Custom localization
Our @ref authentication-ui "builtin UI" comes in **English** and **Japanese** flavors,
but you can provide your own translations for other locales, or even override
the strings for the languages we support. All that is required is that your
application has a `RAuthentication.strings` table in its resources. See the
@ref authentication-samples "Single Sign-On Sample app" for an example.

@section authentication-samples Sample Apps
Sample applications provided to illustrate how to use this module are found in the `Samples/` directory of the [core-ios-authentication repository](https://gitpub.rakuten-it.com/projects/ECO/repos/core-ios-authentication/browse/Samples).

@subsection authentication-sample-sso The SingleSignOn project
This project contains three targets, **SingleSignOn1**, **SingleSignOn2** and **SingleSignOn3**, which demonstrate how to use @ref RBuiltinLoginWorkflow with the builtin @ref RBuiltinLoginDialog "login" and @ref RBuiltinAccountSelectionDialog "account selection" dialogs, and a @ref RJapanIchibaUserAuthenticator "Japan Ichiba user authenticator" for @ref authentication-sso "Single Sign-On". It uses @ref RBuiltinJapanIchibaUserAuthenticatorFactory to setup an @ref rauthenticator_factory_block_t "authenticator factory" that creates authenticators with the `memberinfo_read_name, 90days@Access, 365days@Refresh` scope.

The important bit is the setup of the @ref RBuiltinLoginWorkflow "login workflow":

    rauthenticator_factory_block_t authenticatorFactory =
        RBuiltinJapanIchibaUserAuthenticatorFactory([NSSet setWithObjects:
                                                     @"memberinfo_read_name",
                                                     @"90days@Access",
                                                     @"365days@Refresh",
                                                     nil]);
    loginWorkflow = [RBuiltinLoginWorkflow.alloc
        initWithAuthenticationSettings:authenticationSettings
                           loginDialog:loginDialog
                accountSelectionDialog:accountSelectionDialog
                  authenticatorFactory:authenticatorFactory
                            completion:^(RAuthenticationAccount *account, NSError *error)
        {
            ...
        }];

…as well as the service identifier used for loading the current user's account:

    // Load the SSO-enabled account for a specific Japan Ichiba user
    account = [RAuthenticationAccount
        loadAccountWithName:username
                    service:RJapanIchibaUserAuthenticator.defaultServiceIdentifier
                      error:&error];

@ref RBuiltinJapanIchibaUserAuthenticatorFactory is a builtin function that creates
an @ref rauthenticator_factory_block_t "authenticator factory" capable of producing
@ref RJapanIchibaUserAuthenticator instances.

@attention
 It is important that developers, when invoking
 RAuthenticationAccount::loadAccountWithName:service:error:,
 use the right service identifier. For @ref authentication-sso "Single Sign-On",
 this should **always** be the @ref RAuthenticator::defaultServiceIdentifier of the class the
 @ref rauthenticator_factory_block_t "authenticator factory" produces instances of.

@attention
 Applications that use a specific service identifier on RAE (e.g. `i101`) should use the @ref RBuiltinJapanIchibaUserAuthenticatorFactoryWithServiceID factory instead. It works like @ref RBuiltinJapanIchibaUserAuthenticatorFactory but takes an extra parameter to set the RAE service identifier.

### watchOS sample

**SingleSignOn3** is bundled with a watchOS sample app **WatchSignOn**, this sample demonstrated how to transfer logged-in user account from iPhone app to watchOS app.

@image html "WatchOSSample.png" "WatchSignOn before and after sign in on iPhone"

@section authentication-app-extension-support App Extension Support

## Installing

Only @ref RAuthenticationCore "RAuthenticationCore" is compatible with app extension development. Add @ref RAuthenticationCore "it" (without @ref RAuthenticationUI "UI") to the app extension target in your `Podfile`:

@code{.rb}
    source 'https://github.com/CocoaPods/Specs.git'
    source 'https://gitpub.rakuten-it.com/scm/eco/core-ios-specs.git'

target 'appextension' do
    pod 'RAuthenticationCore'
end
@endcode

## Share login user account between host app and app extension

By default the logged-in user's account is stored inside the host app's private keychain access group, its **keychain access group identifier** is the same as the host app's bundle identifier.
Due to app extensions having a different bundle identifier, the user account logged into the host app cannot be accessed by an app extension. If you want to share the logged-in user account between the host app and app extension, an access group shared by the host app and app extension is necessary.

@warning
 SSO works without the following steps as long as @ref authentication-sso "Single Sign-On" is configured for app extension target. The logged-in user account will not be shared from host app to extension (and vice versa). In this case you can login different users in the  host app and extension.

### Keychain Setup Steps
1. Add your host app's **keychain access group identifier**(bundle identifier) to app extension's **Keychain Groups** array in **Capabilities > Keychain Sharing**, as shown below:
@image html "Keychain Access Group Setup for AppExtension.png" "Setting up the keychain access group for extension" width=80%
2. Add **com.rakuten.tech.mobile.auth.access-group-overwrite** to both host app and extension's **info.plist**, then set the value to your host app's **keychain access group identifier**
@image html "Keychain Access Group Info for AppExtension.png" "Set the keychain access group info" width=80%

@note
 Add **keychain access group identifier** without **App ID Prefixes**.

@section authentication-changelog Changelog

@warning
This library is now in limited maintenance mode. Click [here](https://confluence.rakuten-it.com/confluence/x/HQJAgg) to learn about its replacement, and [here](https://pages.ghe.rakuten-it.com/id-sdk/specs/overview/#motivation) for what motivated us to move away from the old ways.

@subsection authentication-4-3-7 4.3.7 (2020-09-23)

- 💬 Change registration message ("Rakuten Super Points" => "Rakuten Points")

@subsection authentication-4-3-6 4.3.6 (2020-07-13)

- 🐛 Handle pull down dismiss of login/verification screen of non-full screen presentation style.
- 🍭 Launch registration & reset password page using SFSafariViewController in sample apps
  - Please follow the sample to show password-reset & registration links using SFSafariViewController, or your app might get rejected by AppStore review.
- 🗑️ Remove old date in privacy policy notice

@subsection authentication-4-3-5 4.3.5 (2020-03-25)

- 🐛 Properly handle pull down event when user cancels logout screen on iOS 13. See @ref authentication-presentation-style "Presentation Style".
- 📚 Added **OMNI's domain (login.account.rakuten.com)** to the list of required domains for shared web credentials. See @ref authentication-ui-login-autofill-swc "Enable Shared Web Credentials and Password AutoFill".

@subsection authentication-4-3-4 4.3.4 (2019-10-07)

- [MEMSDK-380](https://jira.rakuten-it.com/jira/browse/MEMSDK-380): 💄 Set `overrideUserInterfaceStyle` to `UIUserInterfaceStyleLight` for build-in UIViewControllers for iOS 13.

@subsection authentication-4-3-3 4.3.3 (2019-06-10)

- [MEMSDK-378](https://jira.rakuten-it.com/jira/browse/MEMSDK-379): 🐛 Add `RakutenWebClientKit` dependency specifically to avoid link error when using cocoapods version higher than 1.6.0.

@subsection authentication-4-3-2 4.3.2 (2019-02-04)

- [MEMSDK-378](https://jira.rakuten-it.com/jira/browse/MEMSDK-378): 🚑  Crash when pressing cancel while SSO is logging in

@subsection authentication-4-3-1 4.3.1 (2019-01-21) Withdrawn
@attention Withdrawn due to crash: [MEMSDK-378](https://jira.rakuten-it.com/jira/browse/MEMSDK-378).

- [MEMSDK-375](https://jira.rakuten-it.com/jira/browse/MEMSDK-375): 🐛 RLoginWorkflow Memory Leak💧
- [MEMSDK-374](https://jira.rakuten-it.com/jira/browse/MEMSDK-374): 🔗 Update default links

@subsection authentication-4-3-0 4.3.0 (2018-11-05)

- [MEMSDK-310](https://jira.rakuten-it.com/jira/browse/MEMSDK-310): ⭐️ Standalone proof of work challenge client.
- [MEMSDK-306](https://jira.rakuten-it.com/jira/browse/MEMSDK-306): 🐛 Match English display name style with android version on verification screen.
- [MEMSDK-204](https://jira.rakuten-it.com/jira/browse/MEMSDK-204): ⭐️ Add a watchOS target to **SingleSignOn** sample project.

@subsection authentication-4-2-1 4.2.1 (2018-07-09)

- [MEMSDK-283](https://jira.rakuten-it.com/jira/browse/MEMSDK-283): 🐛 Proof of work solving function fails to produce valid result for some challenges.
- [MEMSDK-292](https://jira.rakuten-it.com/jira/browse/MEMSDK-292): 🐛 Missing a part of error messages on login page on some devices

@subsection authentication-4-2-0 4.2.0 (2018-06-18) Withdrawn
@attention
Due to proof of work solving function fails to produce valid result in some cases, this version is **withdrawn** from spec repo.

- [MEMSDK-261](https://jira.rakuten-it.com/jira/browse/MEMSDK-261): 🔐 Integrate proof of work challenge
- [MEMSDK-263](https://jira.rakuten-it.com/jira/browse/MEMSDK-263): 📚 Document necessary steps to support face-id for verification

@subsection authentication-4-1-1 4.1.1 (2018-06-04)

- [MEMSDK-265](https://jira.rakuten-it.com/jira/browse/MEMSDK-265): 🎨 Adjust new logo size

@subsection authentication-4-1-0 4.1.0 (2018-05-21)

- [MEMSDK-255](https://jira.rakuten-it.com/jira/browse/MEMSDK-255): 🎨 2018 logo update
- [MEMSDK-247](https://jira.rakuten-it.com/jira/browse/MEMSDK-247): ⭐️ **UI:** Support non-fullscreen modal presentation styles on iPad. Check sample app [VerificationWorkflow](https://gitpub.rakuten-it.com/projects/ECO/repos/core-ios-authentication/browse/Samples/VerificationWorkflow) to find out how it works.
- [MEMSDK-218](https://jira.rakuten-it.com/jira/browse/MEMSDK-218): ⚡️ **UI:** Use UIStackView for common footer which shared by all builtin screens.
- [MEMSDK-207](https://jira.rakuten-it.com/jira/browse/MEMSDK-207): 🍭 Modify the verification sample application to show case how to logout user when verification fails.

@subsection authentication-4-0-1 4.0.1 (2018-04-09)
- [MEMSDK-228](https://jira.rakuten-it.com/jira/browse/MEMSDK-228): 🐛 **UI:** Labels and buttons would sometimes be truncated on iOS 11.
- [MEMSDK-231](https://jira.rakuten-it.com/jira/browse/MEMSDK-231): 🎫 **Cocoapods** `RAuthenticationUI` had a bogus dependency on `RAuthenticationCore` private source, leading to warnings and problems when linting the podspec.

@subsection authentication-4-0-0 4.0.0 (2018-03-22)
- [MEMSDK-216](https://jira.rakuten-it.com/jira/browse/MEMSDK-216): 🔥 **Platforms:** Support for iOS 8 has been dropped. Minimum required OS is now 9.0. See [CWD Design Principles & Guidelines » RGR Operational Standard and Manuals » System Requirements](https://confluence.rakuten-it.com/confluence/display/CWDDPG/1.+OS+and+browser#03) and [RGR » CXO Guidelines-Implementation » Instructions Rakuten Group Common Operational Manual for Creating Web Content » System Requirements v1.7](https://confluence.rakuten-it.com/confluence/display/RGR/CXO+Guidelines-Implementation+Instructions?preview=/1006133113/1479387776/%5B002251%5DOpMnl_for_CreatingWebContent_System_Req.pdf) for the RGR.
- [MEMSDK-185](https://jira.rakuten-it.com/jira/browse/MEMSDK-185): ⭐️ **Platforms:** Basic support for watchOS 4 (experimental).
- [MEMSDK-192](https://jira.rakuten-it.com/jira/browse/MEMSDK-192): ⭐️ **UI:** The @ref RBuiltinLoginWorkflow "login" and @ref RBuiltinLogoutWorkflow "logout" workflows now accept an optional view controller to be used to present UI from.
- [MEMSDK-160](https://jira.rakuten-it.com/jira/browse/MEMSDK-160): 🐛 **UI:** The footer was not properly displayed when showing the keyboard on iOS 11, and the content was just scrolling endlessly.
- [MEMSDK-163](https://jira.rakuten-it.com/jira/browse/MEMSDK-163): 🐛 **UI:** The @ref RBuiltinAccountSelectionDialog "builtin login dialog" did not handle invalid server responses properly, leading to the dismissal of the login flow.
- [MEMSDK-217](https://jira.rakuten-it.com/jira/browse/MEMSDK-217): 🐛 **UI:** The safari view controller opened when tapping on the footer links had two navigation bars on iOS 11.

@subsection authentication-3-16-1 3.16.1 (2018-06-18)

- [MEMSDK-276](https://jira.rakuten-it.com/jira/browse/MEMSDK-276) ⚙️ [Cocoapods] Fix dependencies and modulemaps. This change fixed a build error occurs on centain version of cocoapods, if following conditions are met:

  - RAuthentication pod is added to multiple targets in one podfile.
  - RAuthentication pod is refered both as static and dynamic library in above podfile.

@subsection authentication-3-16-0 3.16.0 (2018-01-11)
- [MEMSDK-145](https://jira.rakuten-it.com/jira/browse/MEMSDK-145) Add support for App Extensions. See @ref authentication-app-extension-support "App Extension Support" page.

@subsection authentication-3-15-0 3.15.0 (2017-10-10)
- [MEMSDK-92](https://jira.rakuten-it.com/jira/browse/MEMSDK-92) Our built-in @ref RBuiltinLoginDialog "login dialog" now works with Shared Web Credentials and third party password manager app extension(1Password, LastPass,  Dashlane etc.) for autofill. See @ref authentication-ui-login-autofill "setup instructions"
- [MEMSDK-85](https://jira.rakuten-it.com/jira/browse/MEMSDK-85) Fix broken Chinese IME input for username in the built-in login UI

@subsection authentication-3-14-15926 3.14.15926 (2017-09-06)
- [MEMSDK-48](https://jira.rakuten-it.com/jira/browse/MEMSDK-48) Add support for registering a preflight operation in the @ref RBuiltinLogoutWorkflow "built-in logout workflow", to be called after users have confirmed they want to logout but *before* the authentication token gets revoked. This gives apps a chance to call other APIs with a valid token when users log out, e.g. for unregistering from PNP.

@subsection authentication-3-13-0 3.13.0 (2017-07-18)
- [MEMSDK-24](https://jira.rakuten-it.com/jira/browse/MEMSDK-24) Our built-in login workflow now sets the version of the [Rakuten Japan Privacy Policy](https://privacy.rakuten.co.jp/) the user agrees to when they sign in. Additionally, RAuthenticationAccount::rakutenJapanPrivacyPolicyVersion can be used to query that version or override its value.

@subsection authentication-3-12-1 3.12.1 (2017-06-21)
- [MEMSDK-28](https://jira.rakuten-it.com/jira/browse/MEMSDK-28)[IDDEV-525](https://jira.rakuten-it.com/jira/browse/IDDEV-525) Our built-in UI now uses the new July 2017 Rakuten logo.
- Fix URL of the default privacy policy page in English.

@subsection authentication-3-12-0 3.12.0 (2017-03-30)
- [REM-19140](https://jira.rakuten-it.com/jira/browse/REM-19140): Handle new RAE error code when IP is blacklisted.

@subsection authentication-3-11-2 3.11.2 (2017-02-16)
- [REM-19538](https://jira.rakuten-it.com/jira/browse/REM-19538): Fix a crash in the built-in login/SSO UI when the privacy policy is received after the dialog was closed.
- Fix outdated/insecure ATS settings in sample apps.

@subsection authentication-3-11-1 3.11.1 (2017-02-06)
- [REM-17095](https://jira.rakuten-it.com/jira/browse/REM-17095): Whereas the list of authenticators supporting single sign-on was previously hard-coded (and limited to RJapanIchibaUserAuthenticator and RGlobalUserAuthenticator), every @ref RUserPasswordAuthenticator subclass whose @ref RAuthenticator::defaultServiceIdentifier "+defaultServiceIdentifier" class method returns a non-null value is now capable of participating into SSO. This means application developers can still, for instance, implement SSO for Global ID after we remove the deprecated RGlobalUserAuthenticator from our SDK, if they provide their own custom authenticator for that.
- Changed the way the library interfaces with the Analytics module.
- Added section on enabling RAT tracking to README.
- [REM-18339](https://jira.rakuten-it.com/jira/browse/REM-18339): To follow the [SSO Guidelines](/ios-sdk/sdk-latest/#requirements) we now save the last seen username to the keychain in the SSO sample apps.

@subsection authentication-3-11-0 3.11.0 (2016-11-07)
- [REM-16613](https://jira.rakuten-it.com/jira/browse/REM-16613): Replace JA privacy policy URL.
- [REM-14955](https://jira.rakuten-it.com/jira/browse/REM-14955): Change JA privacy policy title/button text.
- [REM-14426](https://jira.rakuten-it.com/jira/browse/REM-14426): Implement privacy policy update feature.
- [REM-16665](https://jira.rakuten-it.com/jira/browse/REM-16665): Fetch the privacy policy update text and the display dates from the server.
- [REM-17236](https://jira.rakuten-it.com/jira/browse/REM-17236): Change default text for privacy policy update.
- Global ID support is deprecated and will be removed in the next major version of our SDK (3.0), scheduled to be released in Q1 2017. Application developers are invited to use a custom authenticator, possibly based on the implementation found in the current version (2.x).

@subsection authentication-3-10-1 3.10.1 (2016-09-28)
- Add missing changelog line in README.

@subsection authentication-3-10-0 3.10.0 (2016-07-27)
- [REM-14059](https://jira.rakuten-it.com/jira/browse/REM-14059): Adds @ref RAuthenticationAccount::trackingIdentifier, which is automatically populated upon login if the application has the relevant scope (`idinfo_read_encrypted_easyid`, for RAE). This field is important for KPI tracking. Applications can use this field for tracking user behavior with RAT.
- [REM-14071](https://jira.rakuten-it.com/jira/browse/REM-14071): Broadcast internal tracking events for login, logout and verification.
- [REM-14287](https://jira.rakuten-it.com/jira/browse/REMI-1071): An account would not be refreshed properly when nothing held a strong reference to it.
- [REM-13732](https://jira.rakuten-it.com/jira/browse/REM-13732): Document that @ref RAuthenticationAccount might fail in some exceptional circumstances.
- Fix a crash during logout on STG if not on a network that can access STG.
- Fix an assert when an operation is canceled, directly or indirectly, e.g. by double-tapping the Login button.

@subsection authentication-3-9-2 3.9.2 (2016-06-23)
- [REMI-1071](https://jira.rakuten-it.com/jira/browse/REMI-1071): Fixed a crash on iOS 7.

@subsection authentication-3-9-1 3.9.1 (2016-06-13)
- Fixed a memory leak during authentication.

@subsection authentication-3-9-0 3.9.0: General improvements (2016-06-06)
- The module does not depend on RakutenAPIs anymore. API errors now use the `RWCAppEngineResponseParserErrorDomain` domain and `RWCAppEngineResponseParserError#####` codes, though those have the same values as their predecessors had in RakutenAPIs, so that existing code does not break.
- [REM-13748](https://jira.rakuten-it.com/jira/browse/REM-13748): Fix the order in which accounts are returned, so that the most-recently used account is the first.

@subsection authentication-3-8-1 3.8.1 (2016-05-16)
- [REMI-959](https://jira.rakuten-it.com/jira/browse/REM-959): Fixed a systematic crash during login in certain circumstances.

@subsection authentication-3-8-0 3.8.0: General improvements (2016-04-27)
- [REM-9270](https://jira.rakuten-it.com/jira/browse/REM-9270): Added a @ref RBuiltinLogoutWorkflow "standard logout workflow" for @ref authentication-sso "Single Sign-On" enabled applications, as well as a @ref RBuiltinLogoutDialog "logout dialog reference implementation" developers can use if implementing a custom logout workflow.
- [REM-12361](https://jira.rakuten-it.com/jira/browse/REM-12361): The `Privacy Policy` and `Help` buttons do not open the browser by default anymore. The module now uses the in-app Safari view controller if available (iOS 9+), or a web view otherwise.
- The podspec and modulemap have both been fixed so that the module now automatically links against the system frameworks it depends on, when built either as a static library or as a dynamic framework.
- @ref authentication-sso "Single Sign-On" is now supported in iOS simulators (requires Xcode 7+).
- [REM-11602](https://jira.rakuten-it.com/jira/browse/REM-11602): Keychain access is now always denied when the device is locked, even for non-critical information, as to avoid false alarms during security audits.
- [REM-11844](https://jira.rakuten-it.com/jira/browse/REM-11844): Accounts with invalid passwords are now cleared from the keychain by the @ref RBuiltinLoginWorkflow "standard login workflow" if it can't login the user automatically, before it transitions to the normal user/password login dialog.
- [REM-12510](https://jira.rakuten-it.com/jira/browse/REM-12510): User authentication doesn't require the backend to expose a profile API (for RAE, either `MemberInformation` or `GlobalMemberInformation`) anymore. This allows for users to be authenticated using e.g. the European RAE domain, which is sometimes used to send push notifications.
- [REM-12509](https://jira.rakuten-it.com/jira/browse/REM-12509): The Rakuten logo image for the `zh-Hant-TW` locale was missing `1x` and `3x` variants.

@subsection authentication-3-7-0 3.7.0: Login workflow improvements (2016-03-17)
- [REM-7875](https://jira.rakuten-it.com/jira/browse/REM-7875): Added an optional @ref RAccountSelectionDialog::handleError: protocol method, giving custom account selection dialogs a chance to handle an error without closing the login workflow.
- [REM-7875](https://jira.rakuten-it.com/jira/browse/REM-7875): The @ref RBuiltinAccountSelectionDialog "builtin account selection dialog" now implements the method above.
- Small documentation improvements.

@subsection authentication-3-6-0 3.6.0: Support for RAE's `service_id` parameter (2016-02-27)
- [REM-10578](https://jira.rakuten-it.com/jira/browse/REM-10578): Added @ref RJapanIchibaUserAuthenticator::raeServiceIdentifier to let application developers specify a custom RAE service id during authentication.
- [REM-10578](https://jira.rakuten-it.com/jira/browse/REM-10578): Added a new authenticator factory, @ref RBuiltinJapanIchibaUserAuthenticatorFactoryWithServiceID, that takes a custom RAE service id parameter.

@subsection authentication-3-5-0 3.5.0: UI customization improvements (2016-02-16)
- [REM-9600](https://jira.rakuten-it.com/jira/browse/REM-9600): Added the RBuiltinLogoutActionSheet::privacyPolicyButtonHandler and RBuiltinLogoutActionSheet::helpButtonHandler properties.

@subsection authentication-3-4-0 3.4.0: Touch ID (2016-01-22)
- [REM-4625](https://jira.rakuten-it.com/jira/browse/REM-4625): Added @ref RBuiltinVerificationWorkflow to ask users to confirm their identity using Touch ID or, if not available or in base of repeated failures, with their password. This new API retrieves a new access token from RAE that is not managed by our SDK and can be used with a short expiration scope to perform a sensitive operation, e.g. a checkout. It can be used with either our @ref RBuiltinVerificationDialog "builtin verification dialog", or application can implement their own UI that conforms to the @ref RVerificationDialog protocol.
- Added @ref RLoginDialog::populateWithUsername: so that the username of a @ref RLoginDialog "login dialog" can be pre-filled by the login workflow when transitioning from an @ref RAccountSelectionDialog "account selection dialog".
- Builtin UI overhaul and bug fixes.
- Better documentation.

@subsection authentication-3-3-0 3.3.0: New login UI/UX (2015-11-12)
- Updated the login UI/UX to match the new requirements.
- Deprecated some properties that are ignored in the new UI specs in various builtin dialogs.

@subsection authentication-3-2-0 3.2.0: Swift support (2015-08-12)
- Added nullability and throw annotations to the exposed API.

@subsection authentication-3-1-0 3.1.0: Logout UI (2015-05-28)
- Added RBuiltinLogoutActionSheet.
- Added the @ref RBuiltinLoginWorkflow::navigationBarAppearance property to allow setting a custom look for the login workflow's navigation bar.
- Added the read-only @ref RBuiltinLoginWorkflow::authenticatorFactory property, for consistency.
- Great documentation improvement.
