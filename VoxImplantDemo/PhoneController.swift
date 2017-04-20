//
//  PhoneController.swift
//  VoxImplantDemo
//
//  Created by Andrey Syvrachev on 06.02.17.
//  Copyright © 2017 Andrey Syvrachev. All rights reserved.
//

import Foundation
import UIKit

class PhoneController: UIViewController {
    
    @IBOutlet weak var destUser: UITextField!
    @IBOutlet weak var videoCallButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (noVideo) {
            self.videoCallButton.isHidden = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(disconnected), name: Notify.disconnected, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(incomingCall(notification:)), name: Notify.incomingCall, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelIncomingCall(notification:)), name: Notify.cancelIncomingCall, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(acceptIncomingCall(notification:)), name: Notify.acceptIncomingCall, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rejectIncomingCall(notification:)), name: Notify.rejectIncomingCall, object: nil)

        loadUserDefaults()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notify.disconnected, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notify.incomingCall, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notify.cancelIncomingCall, object: nil)

        NotificationCenter.default.removeObserver(self, name: Notify.acceptIncomingCall, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notify.rejectIncomingCall, object: nil)
    }
    
    private func loadUserDefaults(){
        let defaults = UserDefaults.standard
        defaults.synchronize()
        destUser.text = defaults.string(forKey: "destUser")
    }
    
    private func saveUserDefaults(){
        let defaults = UserDefaults.standard
        defaults.setValue(destUser.text, forKey: "destUser")
    }
    
    func disconnected(){
        Log.debug("disconnected")
        self.navigationController!.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if vox.isDisconnected {
            self.navigationController!.popToRootViewController(animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // test if going to login screen, have to disconnect
        if (self.isMovingFromParentViewController) {
            vox.disconnect()
        }
    }
    
    func createCallController() -> CallController {
        return self.storyboard?.instantiateViewController(withIdentifier: "CallController") as! CallController
    }
    
    @IBAction func videoCallClick(_ sender: Any) {

        let callController = createCallController()
        callController.call = vox.callOut(user: self.destUser.text!, video: true, callDelegate: callController)
        self.navigationController?.pushViewController(callController, animated: true)
        saveUserDefaults()
    }
    
    @IBAction func callClick(_ sender: Any) {
        let callController = createCallController()
        callController.call = vox.callOut(user: self.destUser.text!, video: false, callDelegate: callController)
        self.navigationController?.pushViewController(callController, animated: true)
        saveUserDefaults()
    }
    
    var incomingAlertController:UIAlertController?
    
    // this function used on simulator only, because CallKit on simulator not working
    func incomingCall(notification:Notification) {
        let video = notification.userInfo!["video"] as! Bool
        let callId = notification.userInfo!["callId"] as! String
        let from = notification.userInfo!["from"] as! String
        
        let videoStr = video ? "Video ":""
        
        incomingAlertController = UIAlertController(title: "Incoming \(videoStr)Call", message: "\(from) ", preferredStyle: .actionSheet)
        
        let actionAccept = UIAlertAction(title: "Accept", style: .default) { action in
            Notify.post(name: Notify.acceptIncomingCall, userInfo: ["callId":callId,"video":video])
        }
        incomingAlertController!.addAction(actionAccept)
        
        let actionDecline = UIAlertAction(title: "Decline", style: .cancel) { action in
            Notify.post(name: Notify.rejectIncomingCall, userInfo: ["callId":callId])
        }
        incomingAlertController!.addAction(actionDecline)
        self.present(incomingAlertController!, animated: true);
    }
    
    func cancelIncomingCall(notification:Notification) {
        incomingAlertController?.dismiss(animated: true, completion: nil)
    }
    
    func acceptIncomingCall(notification:Notification) {
        
        let callId = notification.userInfo!["callId"] as! String
        let video = notification.userInfo!["video"] as! Bool
        let uuid = notification.userInfo!["UUID"] as? UUID
        
        let callController = self.createCallController()
        callController.call = vox.acceptCall(callId: callId, uuid: uuid, video: video, callDelegate: callController)
        self.navigationController?.pushViewController(callController, animated: true)
    }
    
    func rejectIncomingCall(notification:Notification) {
        let callId = notification.userInfo!["callId"] as! String
         vox.rejectCall(callid: callId)
    }
}
