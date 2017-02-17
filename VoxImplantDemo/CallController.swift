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
    
    var call:Call?
    
    override var prefersStatusBarHidden: Bool { get { return true }}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.call?.setLocalPreview(view: self.localPreview)
        self.call?.setRemotePreview(view: self.remoteView)
        
        self.localPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchCamera)))
    }

    func switchCamera() {
        self.call?.switchCamera()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // test if going to login screen, have to disconnect
        if (self.isMovingFromParentViewController) {
            self.call?.stop()
        }
    }
    
    internal func callDidConnect() {
        Log.debug("callDidConnect")
    }
    
    internal func callDidDisconnect() {
        Log.debug("callDidDisconnect")
        self.navigationController!.popViewController(animated: true)
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
        self.call?.stop()
    }
    
    @IBAction func muteAudioClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.call?.muteAudio(mute: sender.isSelected)
    }
    
    @IBAction func muteVideoClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.call?.muteVideo(mute: sender.isSelected)

    }
    
    @IBAction func loudClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.call?.useLoudSpeaker(use: sender.isSelected)
    }
}
