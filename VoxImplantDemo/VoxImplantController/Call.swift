//
//  Call.swift
//  VoxImplantDemo
//
//  Created by Andrey Syvrachev on 06.02.17.
//  Copyright © 2017 Andrey Syvrachev. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

protocol CallDelegate: class {
    func callDidConnect()
    func callDidDisconnect()
    func callFailedWithError(code:Int32, reason:String)
}

class Call: NSObject {
    weak var delegate:CallDelegate?
    var callId:String?
    var callUUID:UUID?
    
    init(delegate:CallDelegate) {
        self.delegate = delegate
    }
    
    deinit {
        Log.debug("[Call:\(callId!)] deinit")
    }
 
    func startCallTo(user:String, video:Bool) -> String {
        callId = vox.sdk.createCall(user, withVideo: video, andCustomData: "VoxImplantDemo custom call data")
        vox.sdk.startCall(callId, withHeaders: nil)

        Log.debug("[Call:\(callId!)] startCallTo \(user)")

        return callId!
    }
    
    func acceptCall(callid:String, uuid: UUID?, video:Bool) {
        self.callId = callid
        self.callUUID = uuid
        vox.sdk.answerCall(callid, withHeaders: nil)
    }
    
    func stop() {
        vox.sdk.disconnectCall(callId, withHeaders: nil)
        if let uuid = callUUID {
            vox.provider.reportCall(with: uuid, endedAt: Date(), reason: .answeredElsewhere)
        }
    }
    
    func onIncomingCall(caller from: String!, named displayName: String!, withVideo videoCall: Bool, withHeaders headers: [AnyHashable : Any]!) {
        Log.debug("[Call:\(callId!)] onIncomingCall from = \(from) displayNam= \(displayName) videoCall = \(videoCall)")
    }
    
    func onCallRingin(withHeaders headers: [AnyHashable : Any]!) {
        Log.debug("[Call:\(callId!)]  onCallRinging headers = \(headers) ")
    }
    
    func onCallAudioStarted() {
        Log.debug("[Call:\(callId!)]  onCallAudioStarted ")
    }
    
    func onCallConnected(withHeaders headers: [AnyHashable : Any]!) {
        Log.debug("[Call:\(callId!)]  onCallConnected  headers = \(headers)")
        self.delegate?.callDidConnect()
    }
    
    func onCallDisconnected(withHeaders headers: [AnyHashable : Any]!) {
        Log.debug("[Call:\(callId!)]  onCallDisconnected  headers = \(headers)")
        self.delegate?.callDidDisconnect()
    }
    
    func onCallFailed(withCode code: Int32, andReason reason: String!, withHeaders headers: [AnyHashable : Any]!) {
        Log.debug("onCallFailed callId = \(callId!)  code = \(code) reason=\(reason) headers = \(headers)")
        self.delegate?.callFailedWithError(code: code, reason: reason)
    }
    
    func setLocalPreview(view:UIView) {
        vox.sdk.setLocalPreview(view)
    }
    
    func setRemotePreview(view:UIView) {
        vox.sdk.setRemoteView(view)
    }
    
    var capturePosition = AVCaptureDevicePosition.front
    
    public func switchCamera(){
        
        if (capturePosition == .back) {
            capturePosition = .front
        }else {
            capturePosition = .back
        }
        vox.sdk.switchToCamera(with: capturePosition)
    }
    
    func useLoudSpeaker(use:Bool){
        vox.sdk.setUseLoudspeaker(use)
    }
    
    func muteAudio(mute:Bool) {
        vox.sdk.setMute(mute)
    }
    
    func muteVideo(mute:Bool) {
        vox.sdk.sendVideo(!mute)
    }
}
