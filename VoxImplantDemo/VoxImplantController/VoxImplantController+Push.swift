//
//  VoxImplantController+Push.swift
//  VoxImplantDemo
//
//  Created by Andrey Syvrachev on 06.02.17.
//  Copyright © 2017 Andrey Syvrachev. All rights reserved.
//

import Foundation
import PushKit
import VoxImplant


extension Data {
    func tokenString() -> String{
    
        var string = ""
        for i in 0...self.count-1{
            string = string.appendingFormat("%02.2hhx", self[i])
        }
        return string
    }
}

extension VoxImplantController: PKPushRegistryDelegate {
    
    func registerForPushNotifications() {
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, forType type: PKPushType) {
        Log.debug("credentials.token = \(credentials.token.tokenString()) type = \(type)")
        self.sdk.registerPushNotificationsToken(credentials.token)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, forType type: PKPushType) {
        Log.debug("didReceiveIncomingPushWith = \(payload) type = \(type)")
        
        let aps = payload.dictionaryPayload["aps"] as! Dictionary<AnyHashable,Any>
        if aps["voximplant"] != nil {
            self.sdk.handlePushNotification(payload.dictionaryPayload)
        }
        
        Notify.post(name: Notify.incomingPush)
    }
}
