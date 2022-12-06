import Foundation
import UIKit

// Using Pods
import RAuthenticationChallenge
import RAuthenticationCore
import RAuthenticationUI
import RAnalytics
import FirebaseAnalytics
import FirebaseCrashlytics
import FirebaseRemoteConfig
import Rswift


// Using SPM
import RUNABanner
import CryptoSwift

// Using Carthage
import Alamofire
import Atributika
import AdjustSdkIm
import TinyConstraints
import Swinject
import CocoaLumberjackSwift
import ReSwift
import ReSwiftThunk


class AppDelegate: NSObject, UIApplicationDelegate {
    
    var allSDKInitialized = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        createSampleInstance()
        return true
    }
    
    
    func createSampleInstance()
    {
        let authClient = RAuthenticationChallengeClient(baseURL: URL(string:"https://google.com")!, pageId: "001")
        print("***** authClient = \(authClient)")
        
        let authToken = RAuthenticationToken()
        authToken.accessToken = "akbkajbckjanckjnakcjnbadkjbcdjk"
        print("***** authToken.accessToken = \(authToken.accessToken)")
        
        let authVC = RAuthenticationViewController()
        print("***** authVC = \(authVC)")
        
        let aes = try? AES(key: "keykeykeykeykeyk", iv: "drowssapdrowssap") // aes128
        print("***** aes = \(String(describing: aes))")
        
        let adsBanner = RUNABannerView()
        print("***** adsBanner = \(adsBanner)")
        
        print("***** firebaseAnalytics = \(Analytics.logEvent("SampleAppStarted", parameters: nil))")
        
        AF.request("https://httpbin.org/get").response { response in
            print("***** Alamofire response = \(response)")
        }
        
        let tweetLabel = AttributedLabel()
        print("***** Atributika label = \(tweetLabel)")
        
        print("***** Adjust = \(Adjust.trackSubsessionStart())")
        print("***** Adjust SDK version = \(String(describing: Adjust.sdkVersion()))")
        
        print("***** Tinyconstraints edgesToSuperview")
        let v1 = UIView()
        let v2 = UIView()
        v1.addSubview(v2)
        v2.edgesToSuperview()
        
        print("***** Swinject Container = \(Container())")
        
        //CocoaLumberjack
        DDLogInfo("***** CocoaLumberjack log")
        
        //RAnalytics
        print("***** RAnalytics Event = \(AnalyticsManager.Event(name: "SampleAppStarted", parameters: nil))")
        
        allSDKInitialized = true
    }
}

// App State
struct AppState {
    var counter: Int = 0
}

// all of the actions that can be applied to the state
struct CounterActionIncrease: Action {}
struct CounterActionDecrease: Action {}


let loggingMiddleware: Middleware<Any> =
{
    dispatch, getState in

    return {
        next in

        return {
            action in
            
            print("Do some task here...")
            return next(action)
        }
    }
}
