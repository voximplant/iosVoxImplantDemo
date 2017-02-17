//
//  Disconnected.swift
//  VoxImplantDemo
//
//  Created by Andrey Syvrachev on 06.02.17.
//  Copyright © 2017 Andrey Syvrachev. All rights reserved.
//

import Foundation

class Disconnected: State {
    
    override func login(userName: String, password: String) {
        self.vic.userName = userName
        self.vic.password = password
        self.vic.sdk.connect(false) // disable connectivity check to speed up connection on VoIP Push
        //self.vic.sdk.connect(to: "lab-gw.voximplant.com:443")
        self.vic.goto(state: self.vic.sConnecting)
    }
    
    override func cmdDisconnect() {
    }
}
