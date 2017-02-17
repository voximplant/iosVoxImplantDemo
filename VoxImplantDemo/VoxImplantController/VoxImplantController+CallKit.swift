//
//  VoxipmplantController+ProviderDelegate.swift
//  VoxImplantDemo
//
//  Created by Andrey Syvrachev on 07.02.17.
//  Copyright © 2017 Andrey Syvrachev. All rights reserved.
//

import Foundation
import CallKit
import AVFoundation

struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}

extension VoxImplantController: CXProviderDelegate {

    /// Called when the provider has been reset. Delegates must respond to this callback by cleaning up all internal call state (disconnecting communication channels, releasing network resources, etc.). This callback can be treated as a request to end all calls without the need to respond to any actions
    @available(iOS 10.0, *)
    public func providerDidReset(_ provider: CXProvider) {
        Log.debug("providerDidReset \(provider)")
    }
    
    static var providerConfiguration: CXProviderConfiguration {
        let localizedName = "VoxImplant"
        let providerConfiguration = CXProviderConfiguration(localizedName: localizedName)
        providerConfiguration.supportsVideo = true
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportedHandleTypes = [.generic]
        return providerConfiguration
    }
    
    func reportIncomingCall(callId: String, handle: String, hasVideo: Bool = false) {
        let uuid = UUID();
        self.incomingCalls[uuid] = IncomingCallDescriptor(callId: callId,video: hasVideo, uuid:uuid)

        // CallKit not avilable on simulator
        if Platform.isSimulator {

            // simulator
            Log.info("incoming call on simulator")

            Notify.post(name: Notify.incomingCall, userInfo: ["callId":callId,
                                                              "from":handle,
                                                              "video":hasVideo])

        }else{
    

            // Construct a CXCallUpdate describing the incoming call, including the caller.
            let update = CXCallUpdate()
            update.remoteHandle = CXHandle(type: .generic, value: handle)
            update.hasVideo = hasVideo
            
            // Report the incoming call to the system
            provider.reportNewIncomingCall(with: uuid, update: update) { error in
                if (error != nil) {
                    Log.error("reportNewIncomingCall error = \(error)")
                }
            }
        }
    }
    
    func cancelIncomingCall(callDescriptor:IncomingCallDescriptor) {
        
        if Platform.isSimulator {
            
            Notify.post(name: Notify.cancelIncomingCall, userInfo: ["callId":callDescriptor.callId])
        }else{
            provider.reportCall(with: callDescriptor.uuid, endedAt: Date(), reason: .remoteEnded)
        }
        
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        
        if let callDescr = incomingCalls[action.callUUID] {
            incomingCalls.removeValue(forKey: action.callUUID)
                        
            // Workaround for webrtc, because first incoming call does not have audio due to incorrect category: AVAudioSessionCategorySoloAmbient
            // webrtc need AVAudioSessionCategoryPlayAndRecord
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            } catch let error {
                Log.debug("AVAudioSession setCategory ERROR: \(error)")
            }
            
            Notify.post(name: Notify.acceptIncomingCall, userInfo: ["callId":callDescr.callId,
                                                                    "video":callDescr.video,
                                                                    "UUID":action.callUUID])
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        if let callDescr = incomingCalls[action.callUUID] {
            incomingCalls.removeValue(forKey: action.callUUID)
            Notify.post(name: Notify.rejectIncomingCall, userInfo: ["callId":callDescr.callId])
        }
        provider.reportCall(with: action.callUUID, endedAt: Date(), reason: .declinedElsewhere)
        
        action.fulfill()
    }
}
