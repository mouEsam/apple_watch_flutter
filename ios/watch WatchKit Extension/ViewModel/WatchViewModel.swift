//
//  WatchViewModel.swift
//  watch WatchKit Extension
//
//  Created by Mostafa Ibrahim on 27/02/2022.
//

import Foundation
import WatchConnectivity

class WatchViewModel: NSObject, ObservableObject {
    let session: WCSession
    @Published var counter = 0
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
    
    func incrementCounter() {
        sendDataMessage(for: .sendCounterToFlutter, data: ["counter": counter + 1])
    }
    
}

extension WatchViewModel: WCSessionDelegate {
    
    enum WatchReceiveMethod: String {
        case sendCounterToNative
    }
    
    enum WatchSendMethod: String {
        case sendCounterToFlutter
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    // Receive message From AppDelegate.swift that send from iOS devices
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            guard let method = message["method"] as? String, let enumMethod = WatchReceiveMethod(rawValue: method) else {
                return
            }
            switch enumMethod {
            case .sendCounterToNative:
                self.counter = (message["data"] as? Int) ?? 0
            }
        }
    }
    
    func sendDataMessage(for method: WatchSendMethod, data: [String: Any] = [:]) {
        sendMessage(for: method.rawValue, data: data)
    }
    
    func sendMessage(for method: String, data: [String: Any] = [:]) {
        guard session.isReachable else {
            return
        }
        let messageData: [String: Any] = ["method": method, "data": data]
        session.sendMessage(messageData, replyHandler: nil, errorHandler: nil)
    }
    
}
