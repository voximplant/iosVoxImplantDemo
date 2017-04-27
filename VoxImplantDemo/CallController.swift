//
//  CallController.swift
//  VoxImplantDemo
//
//  Created by Andrey Syvrachev on 06.02.17.
//  Copyright © 2017 Andrey Syvrachev. All rights reserved.
//

import Foundation
import UIKit

class CallController: UIViewController, CallDelegate {

    @IBOutlet weak var localPreview: UIView!
    @IBOutlet weak var remoteView: UIView!
    @IBOutlet weak var callDurationLabel: UILabel!
    @IBOutlet weak var muteVideoButton: UIButton!
    @IBOutlet weak var holdButton: UIButton!
    
    var call:Call!
    var timer:Timer?
    var alreadyPoppedUp = false
    
    override var prefersStatusBarHidden: Bool { get { return true }}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
//            Log.debug("call duration: \(self.call?.duration())")
            
                let durationInt = Int(self.call.duration())
                let minutes = durationInt / 60
                let seconds = durationInt % 60
                
                let text = String.localizedStringWithFormat("%u:%02u", minutes,seconds)
                
                self.callDurationLabel.text = text
        })
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            vox.sdk.sendDTMF(self.call.callId, digit: 0)
//            vox.sdk.sendDTMF(self.call.callId, digit: 10)
//            vox.sdk.sendDTMF(self.call.callId, digit: 11)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        Log.debug("[CallController:\(String(describing: call.callId))] deinit")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        muteVideoButton.isSelected = !self.call.sendVideoEnabled

        if (noVideo) {
            muteVideoButton.isHidden = true
            holdButton.isHidden = true // for SB demo only!
        }else {
            self.call.setLocalPreview(view: self.localPreview)
            self.call.setRemotePreview(view: self.remoteView)
            self.localPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchCamera)))
            self.remoteView.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(switchVideoResizeMode)));
        }

    }

    func switchVideoResizeMode() {
        // test call duration here
        vox.switchVideoResizeMode()
    }
    
    func switchCamera() {
        self.call.switchCamera()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // test if going to login screen, have to disconnect
        if (self.isMovingFromParentViewController) {
            self.call.stop()
        }
    }
    
    internal func callDidConnect() {
        Log.debug("callDidConnect")
        
        self.call.sendMessage(message: "test message")
        self.call.sendMessage(message: "test info message", mimeType: "audio/aiff")
    }
    
    internal func callDidDisconnect() {
        Log.debug("callDidDisconnect")
        if (!alreadyPoppedUp) {
            alreadyPoppedUp = true
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    internal func callFailedWithError(code: Int32, reason: String) {
        let alertController = UIAlertController(title: "Call Error", message: "Code=\(code) \nReason=\(reason)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Close", style: .destructive) { action in
             self.navigationController!.popViewController(animated: true)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true);
    }

    @IBAction func hangupClick(_ sender: Any) {
        self.call.stop()
    }
    
    @IBAction func muteAudioClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.call.muteAudio(mute: sender.isSelected)
    }
    
    @IBAction func muteVideoClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.call.muteVideo(mute: sender.isSelected)

    }
    
    @IBAction func loudClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.call.useLoudSpeaker(use: sender.isSelected)
    }
    
    @IBAction func holdClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.call.setHold(hold:sender.isSelected)
    }
}
