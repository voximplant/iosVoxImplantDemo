//
//  ViewController.swift
//  VoxImplantDemo
//
//  Created by Andrey Syvrachev on 27.01.17.
//  Copyright © 2017 Andrey Syvrachev. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var gateway: UITextField!
    
    
    private func loadUserDefaults(){
        let defaults = UserDefaults.standard
        userName.text = defaults.string(forKey: "user")
        password.text = defaults.string(forKey: "password")
        gateway.text = defaults.string(forKey: "gateway")
    }
    
    private func saveUserDefaults(){
        let defaults = UserDefaults.standard
        defaults.setValue(userName.text, forKey: "user")
        defaults.setValue(password.text, forKey: "password")
        defaults.setValue(gateway.text, forKey: "gateway")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadUserDefaults()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess(notification:)), name: Notify.loginSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loginFailed(notification:)), name: Notify.loginFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnected), name: Notify.disconnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(incomingPush), name: Notify.incomingPush, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notify.loginSuccess, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notify.loginFailed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notify.disconnected, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notify.incomingPush, object: nil)
    }
    
    func loginSuccess(notification: Notification) {
     //   Log.debug("loginSuccess notification = '\(notification)'")
        
        let phoneController = self.storyboard?.instantiateViewController(withIdentifier: "PhoneController")
        phoneController!.title = notification.userInfo!["displayName"] as? String
        self.navigationController?.pushViewController(phoneController!, animated: true)
        
        self.setUIDisconnected()
    }

    func loginFailed(notification: Notification){
    //    Log.debug("loginFailed notification = '\(notification)'")
        
        let reason = notification.userInfo?["reason"]
        let alert = UIAlertController(title: "Error", message: reason != nil ? "\(String(describing: reason))":"", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: nil))
        
        self.present(alert,animated: true, completion: nil)
        
        self.setUIDisconnected()
    }
    
    func disconnected(){
       // Log.debug("disconnected")
        self.setUIDisconnected()
    }
    
    
    func setUIDisconnected(){
        self.loginButton.isEnabled = true
        self.activityIndicator.stopAnimating()
        self.loginButton.setTitle("Login", for: .normal)
    }
    
    func setUIConnecting(){
        self.activityIndicator.startAnimating()
        self.loginButton.setTitle("Cancel", for: .normal)
    }
    
    func isConnecting() -> Bool {
        return self.activityIndicator.isAnimating
    }
    
    func login(){
        self.saveUserDefaults()
        
        vox.login(userName: userName.text!, password: password.text!, gateway: gateway.text)
        self.setUIConnecting()
    }

    @IBAction func loginButtonClicked(_ sender: Any) {
        
        if (!isConnecting()) {
            login()
        }else {
            vox.disconnect()
            self.loginButton.isEnabled = false
        }

    }
    
    func incomingPush() {

        if (!isConnecting()) {
            login()
        }
    }
}




