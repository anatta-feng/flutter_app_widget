import Flutter
import UIKit
import WidgetKit
import OSLog

public class SwiftFlutterAppWidgetPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    private static var appGroupId: String?
    
    private var initialUrl: URL?
    private var latestUrl: URL? {
        didSet {
            if latestUrl != nil {
                eventSink?.self(latestUrl?.absoluteString)
            }
        }
    }
    private var pendingLaunchUrl: URL?
    
    private var eventSink: FlutterEventSink?
    
    private let noInitializedError = FlutterError(code: "-1", message: "AppGroupId not set. Call initialized first", details: nil)
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_app_widget", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterAppWidgetPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventChannel = FlutterEventChannel(name: "flutter_app_widget/events", binaryMessenger: registrar.messenger())
        
        eventChannel.setStreamHandler(instance)
        
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
        case "initialized":
            if let args = call.arguments as? [String: String],
               let appGroup = args["appGroupId"]{
                SwiftFlutterAppWidgetPlugin.appGroupId = appGroup
            }
            break
        case "updateWidget":
            if #available(iOS 14.0, *) {
                #if arch(arm64) || arch(i386) || arch(x86_64)
                WidgetCenter.shared.reloadAllTimelines()
                #endif
            }
            result(nil);
            break
        case "setWidgetData":
            if SwiftFlutterAppWidgetPlugin.appGroupId == nil {
                result(noInitializedError)
                return
            }
            if let args = call.arguments as? [String: String],
               let key = args["key"],
               let value = args["value"] {
                
                if let sharedDefaults = UserDefaults.init(suiteName: SwiftFlutterAppWidgetPlugin.appGroupId) {
                    sharedDefaults.setValue(value, forKey: key)
                    result(value)
                } else {
                    result(nil)
                }
            }
            break
        case "removeWidgetData":
            if SwiftFlutterAppWidgetPlugin.appGroupId == nil {
                result(noInitializedError)
                return
            }   
            if let args = call.arguments as? [String: String],
               let key = args["key"] {
                
                if let sharedDefaults = UserDefaults.init(suiteName: SwiftFlutterAppWidgetPlugin.appGroupId) {
                    sharedDefaults.removeObject(forKey: key)
                    result(true)
                } else {
                    result(false)
                }
            }
            break
        default:
            break
        }
        result("iOS " + UIDevice.current.systemVersion)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        if pendingLaunchUrl != nil {
            eventSink?.self(pendingLaunchUrl?.absoluteString)
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        
        let launchUrl = (launchOptions[UIApplication.LaunchOptionsKey.url] as? NSURL)?.absoluteURL
        
        if #available(iOS 14.0, *) {
            if let url = launchUrl {
                os_log("applicationn1: \(url)")
            } else {
                os_log("applicationn1: nil")
            }
        }
        
        if(launchUrl != nil && isWidgetUrl(url: launchUrl!)) {
            initialUrl = launchUrl?.absoluteURL
            latestUrl = initialUrl
            if eventSink == nil {
                pendingLaunchUrl = initialUrl
            }
        }
        return true
    }
    
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if #available(iOS 14.0, *) {
            os_log("applicationn2: \(url) isWidgetUrl: \(self.isWidgetUrl(url: url))")
        }
        if(isWidgetUrl(url: url)) {
            latestUrl = url
            if eventSink == nil {
                pendingLaunchUrl = url
            }
        }
        return true
    }
    
    private func isWidgetUrl(url: URL) -> Bool {
        let components = URLComponents.init(url: url, resolvingAgainstBaseURL: false)
        return components?.queryItems?.contains(where: {(item) in item.name == "flutter_app_widget"}) ?? false
    }
}
