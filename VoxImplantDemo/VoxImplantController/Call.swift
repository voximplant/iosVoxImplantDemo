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
    var sendVideoEnabled = true
    var callStopHandler: (() -> Void)!
    
    init(delegate:CallDelegate) {
        self.delegate = delegate
    }
    
    deinit {
        Log.debug("[Call:\(callId!)] deinit")
    }
 
    func startCallTo(user:String, video:Bool) -> String {
        self.sendVideoEnabled = video
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
        //self.callStopHandler()
    }
    
    func onIncomingCall(caller from: String!, named displayName: String!, withVideo videoCall: Bool, withHeaders headers: [AnyHashable : Any]!) {
        Log.debug("[Call:\(callId!)] onIncomingCall from = \(from) displayNam= \(displayName) videoCall = \(videoCall)")
        self.sendVideoEnabled = true
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
        vox.cleanIncomingCall(callId: callId!)
    }
    
    func onCallFailed(withCode code: Int32, andReason reason: String!, withHeaders headers: [AnyHashable : Any]!) {
        Log.debug("[Call:\(callId!)]  onCallFailed code = \(code) reason=\(reason) headers = \(headers)")
        self.delegate?.callFailedWithError(code: code, reason: reason)
    }
    
    func setLocalPreview(view:UIView) {
        vox.sdk.setLocalPreview(view)
    }
    
    func setRemotePreview(view:UIView) {
        vox.sdk.setRemoteView(view)
    }
    
    func sendMessage(message:String) {
        vox.sdk.sendMessage(callId, withText: message, andHeaders: ["X-my-header":"custom header"])
    }
    
    func sendMessage(message:String, mimeType:String) {
        vox.sdk.sendInfo(callId, withType: mimeType, content: message, andHeaders: ["X-my-header":"custom header"])
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
        self.sendVideoEnabled = !mute
    }
    
    func duration() -> TimeInterval {
        return vox.sdk.getCallDuration(self.callId)
    }
    
    func setHold (hold:Bool) {
        vox.sdk.setHold(hold, forCall: self.callId)
    }
}
