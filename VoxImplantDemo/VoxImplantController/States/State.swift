//
//  State.swift
//  VoxImplantDemo
//
//  Created by Andrey Syvrachev on 06.02.17.
//  Copyright © 2017 Andrey Syvrachev. All rights reserved.
//

import Foundation

class State {
    
    var vic:VoxImplantController
    
    init(vic:VoxImplantController) {
        self.vic = vic
    }
    
    func didEnterFrom(state:State){
    }
    func willExitTo(state:State){
    }
    
    func login(userName:String, password:String,gateway: String?) {
        Log.error("[\(self)] > called login in incorrect state")
    }

    
    func cmdDisconnect(){
        Log.debug("[\(self)] > cmdDisconnect")
        self.vic.sdk.closeConnection()
        self.vic.goto(state: self.vic.sDisconnected)
    }
    
    
    
    func onConnectionSuccessful(){
        Log.debug("[\(self)] > UNHANDLED onConnectionSuccessful")

    }
    
    func onConnectionClosed() {
        Log.debug("[\(self)] > onConnectionClosed")
        
        Notify.post(name: Notify.disconnected)
        self.vic.goto(state: self.vic.sDisconnected)
    }
    
    func onConnectionFailedWithError(_ reason: String!) {
        Log.debug("[\(self)] UNHANDLED onConnectionFailedWithError \(reason)")
    }
    
    
    func onLoginSuccessful(withDisplayName displayName: String!, andAuthParams authParams: [AnyHashable : Any]!) {
        Log.debug("[\(self)] UNHANDLED  onLoginSuccessful(\(displayName) authParams=\(authParams))")
    }
    
    func onLoginFailedWithErrorCode(_ errorCode: NSNumber!) {
        Log.debug("[\(self)] onLoginFailedWithErrorCode \(errorCode)")
        Notify.post(name: Notify.loginFailed, userInfo:  ["reason":errorCode])
        self.vic.sdk.closeConnection()
        self.vic.goto(state: self.vic.sDisconnected)
    }
    
}
