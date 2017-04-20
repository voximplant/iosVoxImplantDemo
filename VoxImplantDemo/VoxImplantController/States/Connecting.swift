//
//  Connecting.swift
//  VoxImplantDemo
//
//  Created by Andrey Syvrachev on 06.02.17.
//  Copyright © 2017 Andrey Syvrachev. All rights reserved.
//

import Foundation

class Connecting: State {
    
    override func onConnectionSuccessful() {
        self.vic.goto(state: self.vic.sLoggingIn)
    }
    
    override func onConnectionFailedWithError(_ reason: String!) {
        Notify.post(name: Notify.loginFailed, userInfo: reason != nil ? ["reason":reason] : nil)
        self.vic.goto(state: self.vic.sDisconnected)
    }
}
