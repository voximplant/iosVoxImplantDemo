//
//  LoggingIn.swift
//  VoxImplantDemo
//
//  Created by Andrey Syvrachev on 06.02.17.
//  Copyright © 2017 Andrey Syvrachev. All rights reserved.
//

import Foundation

class LoggingIn: State {
    
    override func didEnterFrom(state: State) {
        self.vic.sdk.login(withUsername: self.vic.userName!, andPassword: self.vic.password!)
    }
    
    override func onLoginSuccessful(withDisplayName displayName: String!, andAuthParams authParams: [AnyHashable : Any]!) {
        Log.debug("[\(self)] onLoginSuccessful(\(displayName) authParams=\(authParams))")
        Notify.post(name: Notify.loginSuccess, userInfo:  ["displayName":displayName, "authParams":authParams])
        self.vic.goto(state: self.vic.sLoggedIn)
    }
    
//    override func onLoginFailedWithErrorCode(_ errorCode: NSNumber!) {
//        Log.error("[\(self)] onLoginFailedWithErrorCode \(errorCode)")
//
//    }
}
