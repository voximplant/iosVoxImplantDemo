//
//  VoxImplantController.swift
//  VoxImplantDemo
//
//  Created by Andrey Syvrachev on 27.01.17.
//  Copyright © 2017 Andrey Syvrachev. All rights reserved.
//

import UIKit
import PushKit
import CallKit
import VoxImplant


class IncomingCallDescriptor {
    
    init(callId:String, video:Bool, uuid:UUID) {
        self.callId = callId
        self.video = video
        self.uuid = uuid
    }
    var callId:String
    var video:Bool
    var uuid:UUID
}

class VoxImplantController: NSObject {

    let provider: CXProvider
    
    var calls = [String:Call]()
    var incomingCalls = [UUID:IncomingCallDescriptor]()
    var state: State!
    
    var sDisconnected: State!
    var sConnecting:State!
    var sLoggingIn:State!
    var sLoggedIn:State!
    
    let sdk:VoxImplant
    
    var userName:String?
    var password:String?
    
    var isDisconnected:Bool{get {return self.state === self.sDisconnected }}
    
    
    private init(sdk: VoxImplant) {
        
        provider = CXProvider(configuration: type(of: self).providerConfiguration)
        
        self.sdk = sdk
        
        super.init()
        
        provider.setDelegate(self, queue: nil)
        
        self.sDisconnected = Disconnected(vic:self)
        self.sConnecting = Connecting(vic:self)
        self.sLoggingIn = LoggingIn(vic:self)
        self.sLoggedIn = LoggedIn(vic:self)
        
        self.state = self.sDisconnected
        
        self.sdk.voxDelegate = self
        
    //    self.sdk.setResolution(1280, andHeight: 720)
        
        self.registerForPushNotifications()
    }
    
    class func instance() -> VoxImplantController {
        VoxImplant.setLogLevel(INFO_LOG_LEVEL)
        return VoxImplantController(sdk: VoxImplant.getInstance())
    }
    
    func switchVideoResizeMode() {
        let mode = self.sdk.getVideoResizeMode()
        switch mode {
            case VI_VIDEO_RESIZE_MODE_CLIP: self.sdk.setVideoResizeMode(VI_VIDEO_RESIZE_MODE_FIT); break;
            case VI_VIDEO_RESIZE_MODE_FIT:  self.sdk.setVideoResizeMode(VI_VIDEO_RESIZE_MODE_CLIP); break;
        default:
            assert(false);
            break;
        };
    }

}

extension VoxImplantController {

    func goto(state: State) {
        Log.debug("[\(self.state!) -> \(state)]")
        self.state.willExitTo(state: state)
        let prevState = self.state!
        self.state = state
        self.state.didEnterFrom(state: prevState)
    }
    
    func login(userName:String, password:String, gateway: String?) {
        self.state.login(userName: userName, password: password, gateway:gateway)
    }

    func disconnect(){
        self.state.cmdDisconnect()
    }
    
    func callOut(user:String, video:Bool, callDelegate:CallDelegate) -> Call {
        let call = Call(delegate: callDelegate)
        let callId = call.startCallTo(user: user, video:video)
        calls[callId] = call
        call.callStopHandler = {
            self.calls.removeValue(forKey: callId)
        }
        
        return call
    }
    
    func acceptCall(callId:String, uuid:UUID?, video:Bool, callDelegate:CallDelegate) -> Call {
        let call = Call(delegate: callDelegate)
        call.acceptCall(callid: callId, uuid: uuid, video:video)
        calls[callId] = call
        call.callStopHandler = {
            self.calls.removeValue(forKey: callId)
        }
        return call
    }

    func rejectCall(callid:String) {
        vox.sdk.declineCall(callid, withHeaders: nil)
    }
}

