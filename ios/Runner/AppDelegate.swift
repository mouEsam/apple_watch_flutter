import UIKit
import Flutter
import WatchConnectivity

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    let watchChannelName = "com.kortobaa.watchTest.watch";
    var session: WCSession?
    var channel: FlutterMethodChannel?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if WCSession.isSupported() {
            session = WCSession.default;
            session?.delegate = self;
            session?.activate();
        }
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    enum FlutterEvents: String {
        case flutterToWatch
    }
    
    private func initFlutterChannel() -> FlutterMethodChannel? {
        return DispatchQueue.main.sync {
            if let controller = window?.rootViewController as? FlutterViewController {
                let channel = FlutterMethodChannel(
                    name: watchChannelName,
                    binaryMessenger: controller.binaryMessenger)
                
                channel.setMethodCallHandler({ [weak self] (
                    call: FlutterMethodCall,
                    result: @escaping FlutterResult) -> Void in
                    let method = FlutterEvents.init(rawValue: call.method)
                    switch method {
                    case .flutterToWatch:
                        guard let self = self, let watchSession = self.session,
                              watchSession.isPaired, watchSession.isReachable,
                              let methodData = call.arguments as? [String: Any],
                              let method = methodData["method"],
                              let data = methodData["data"] else {
                                  result(false)
                                  return
                              }
                        let watchData: [String: Any] = ["method": method, "data": data]
                        watchSession.sendMessage(watchData, replyHandler: nil)
                        result(true)
                    default:
                        result(FlutterMethodNotImplemented)
                    }
                })
                return channel
            }
            return nil
        }
    }
}

extension AppDelegate: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        self.channel = self.initFlutterChannel()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let method = message["method"] as? String, let channel = self.channel {
            DispatchQueue.main.sync {
                channel.invokeMethod(method, arguments: message)
            }
        }
    }
}
