//
//  VoxImplantController+VoxImplantDelegate.swift
//  VoxImplantDemo
//
//  Created by Andrey Syvrachev on 06.02.17.
//  Copyright © 2017 Andrey Syvrachev. All rights reserved.
//

import Foundation
import VoxImplant
import CoreVideo

extension VoxImplantController: VoxImplantDelegate {
    
    func onConnectionClosed() {
        self.state.onConnectionClosed()
    }
    
    func onConnectionSuccessful() {
        self.state.onConnectionSuccessful()
    }
    
    func onConnectionFailedWithError(_ reason: String!) {
        self.state.onConnectionFailedWithError(reason)
    }
    
    func onLoginSuccessful(withDisplayName displayName: String!, andAuthParams authParams: [AnyHashable : Any]!) {
        self.state.onLoginSuccessful(withDisplayName: displayName, andAuthParams: authParams)
    }
    
    func onLoginFailedWithErrorCode(_ errorCode: NSNumber!) {
        self.state.onLoginFailedWithErrorCode(errorCode)
    }
    
    func onIncomingCall(_ callId: String!, caller from: String!, named displayName: String!, withVideo videoCall: Bool, withHeaders headers: [AnyHashable : Any]!) {

        Log.debug("onIncomingCall callId = \(callId) from = \(from) displayNam= \(displayName) videoCall = \(videoCall)")
        
        self.reportIncomingCall(callId: callId, handle: displayName, hasVideo: videoCall)
    }
    
    
    func onCallRinging(_ callId: String!, withHeaders headers: [AnyHashable : Any]!) {
        Log.info("onCallRinging: \(callId)")
        if let call = calls[callId] {
            call.onCallRingin(withHeaders: headers)
        }else {
            Log.error("CALL ABSEND: onCallRinging callId = \(callId) headers = \(headers) ")
        }
    }
    
    func onCallAudioStarted(_ callId: String!) {
        Log.info("onCallAudioStarted: \(callId)")

        if let call = calls[callId] {
            call.onCallAudioStarted()
        }else {
            Log.error("CALL ABSEND: onCallAudioStarted callId = \(callId) ")
        }
    }
    
    func onCallConnected(_ callId: String!, withHeaders headers: [AnyHashable : Any]!) {
        Log.info("onCallConnected: \(callId) headers=\(headers)")

        if let call = calls[callId] {
            call.onCallConnected(withHeaders: headers)
        }else {
            Log.error("CALL ABSEND: onCallConnected callId = \(callId)  headers = \(headers)")
        }
    }
    
    
    func onCallDisconnected(_ callId: String!, withHeaders headers: [AnyHashable : Any]!) {
        Log.info("onCallDisconnected: \(callId) headers=\(headers)")

        if let call = calls[callId] {
            call.onCallDisconnected(withHeaders: headers)
            calls.removeValue(forKey: callId)
        }else {
            
            for call in self.incomingCalls.values {
                if (call.callId == callId) {
                    self.cancelIncomingCall(callDescriptor: call)
                    self.incomingCalls.removeValue(forKey: call.uuid)
                    return
                }
            }
            
            Log.error("CALL ABSEND: onCallDisconnected callId = \(callId)  headers = \(headers)")
        }
    }
    
    func onCallFailed(_ callId: String!, withCode code: Int32, andReason reason: String!, withHeaders headers: [AnyHashable : Any]!) {
        
        Log.info("onCallFailed: \(callId) code=\(code) reason=\(reason) headers=\(headers)")

        if let call = calls[callId] {
            call.onCallFailed(withCode: code, andReason: reason, withHeaders: headers)
            calls.removeValue(forKey: callId)
        }else {
            Log.error("CALL ABSEND: onCallFailed callId = \(callId)  code = \(code) reason=\(reason) headers = \(headers)")
        }
    }
    
    func onMessageReceived(inCall callId: String!, withText text: String!, withHeaders headers: [AnyHashable : Any]!) {
        Log.info("onMessageReceived: \(callId!) withText=\(text) text=\(text) withHeaders=\(headers)")
    }
    
    func onSIPInfoReceived(inCall callId: String!, withType type: String!, andContent content: String!, withHeaders headers: [AnyHashable : Any]!) {
        Log.info("onSIPInfoReceived: \(callId!) withType=\(type) andContent=\(content) withHeaders=\(headers)")
    }
    
    func onNetStatsReceived(inCall callId: String!, withStats stats: UnsafePointer<VoxImplantNetworkInfo>!) {
        Log.info("onNetStatsReceived: \(callId!) packetLoss=\(stats!.pointee.packetLoss)")
    }

    // uncomment this to preprocess captured video before sending it to remote endpoint
//    func onPreprocessCameraCapturedVideo(_ pixelBuffer: CVPixelBuffer!, rotation: Int32) {
//        //Log.info("onPreprocessCameraCapturedVideo: rotation=\(rotation)")
//        if (pixelBuffer == nil) {
//            return
//        }
//        let size = CVPixelBufferGetDataSize(pixelBuffer)
//        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
//        let baseAddr = CVPixelBufferGetBaseAddress(pixelBuffer)
//        memset(baseAddr, 300, size/3)
//        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
//    }
}
