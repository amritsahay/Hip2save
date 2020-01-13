//
//  ChangePasswordViewController.swift
//  Hip2Save
//
//  Created by ip-d on 01/03/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var confirm: UITextField!
    @IBOutlet weak var new: UITextField!
    @IBOutlet weak var old: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        confirm.attributedPlaceholder = NSMutableAttributedString.init(string:"Confirm Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        new.attributedPlaceholder = NSMutableAttributedString.init(string:"New Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        old.attributedPlaceholder = NSMutableAttributedString.init(string:"Old Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
       /* let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        let logo = UIImage(named: "hip2save_main")
        logoImage.image = logo
        self.navigationItem.titleView = logoImage */
        
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "ChangePasswordViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    @IBAction func change(_ sender: Any) {
        if (old.text?.isBlank)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter old password.")
        }
        else if !(old.text?.isValidPassword)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter valid old password.")
        }
        else if (new.text?.isBlank)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter new password.")
        }
        else if !(new.text?.isValidPassword)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter valid new password.")
        }
        else if (confirm.text?.isBlank)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter confirm password.")
        }
        else if !(confirm.text?.isValidPassword)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter valid confirm password.")
        }
        else if confirm.text != new.text
        {
            Utility.shared.showSnackBarMessage(message:"New & Confirm password doesn't match.")
        }
        else
        {
            updatePassword()
        }
    }
    
    func loginProcess(user:JSON)
    {
        LocalDBWrapper.shared.createUser(userJSON:user)
        AppDelegate.shared.currentUser = LocalDBWrapper.shared.readUser()
        
        let alertController = UIAlertController(title: "Your password has been reset.", message: "", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            self.dismiss(animated: true, completion:nil)
        }
        
        
        // Add the actions
        alertController.addAction(okAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        NotificationCenter.default.post(name:Constants.notifyUserDidChange, object: nil)
    }
    
    func updatePassword()
    {
        Utility.shared.startProgress(message:"")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = Constants.baseURL
        var headers:HTTPHeaders? = nil
        let token = AppDelegate.shared.getEncryptionToken()
        if  token != ""
        {
            headers = ["x-access-cookie":token]
        }
        let parameters:Parameters = [Key.option.rawValue:API.change_password.rawValue,"current_pwd":old.text!,"new_pwd":new.text!]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding:URLEncoding.default, headers: headers).validate().responseString { (response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            Utility.shared.stopProgress()
            switch response.result {
            case .success:
                print("Validation Successful")
                let jsonString = response.value?.replacingOccurrences(of:"mu-plugins/query-monitor/wp-content/db.php", with:"")
                let json = JSON.init(parseJSON:jsonString ?? "{}")
                let response = json.dictionary
                let status = response?["status"]?.stringValue
                if status == "ok"
                {
                    self.loginProcess(user:json)
                   // Utility.shared.showSnackBarMessage(message:"Password updated.")
                    
                }
                else
                {
                    Utility.shared.showSnackBarMessage(message:(response?["message"]?.stringValue)!)
                }
                
            case .failure(let error):
                Utility.shared.showSnackBarMessage(message:error.localizedDescription)
                print(error)
            }
        }
    }
    
}
