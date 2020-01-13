//
//  RegisterViewController.swift
//  Hip2Save
//
//  Created by ip-d on 14/11/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RegisterViewController: UIViewController {
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUI()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "RegisterViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    @IBAction func signup(_ sender: Any) {
        if (displayName.text?.isBlank)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter username.")
        }
        else if !(displayName.text?.isValidUsername)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter valid username.")
        }
        else if (emailAddress.text?.isBlank)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter email address.")
        }
        else if !(emailAddress.text?.isEmail)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter valid email address.")
        }
        else if (password.text?.isBlank)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter password.")
            
        }
        else if !(password.text?.isValidPassword)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter valid password.")
        }
        else if (confirmPassword.text?.isBlank)! {
            Utility.shared.showSnackBarMessage(message:"Please enter confirm password.")
            
        }
        else if !(confirmPassword.text?.isValidPassword)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter valid confirm password.")
        }
        else if confirmPassword.text != password.text
        {
            Utility.shared.showSnackBarMessage(message:"Password doesn't match.")
        }
        else
        {
            register()
        }
    }
    
    func setUI()
    {
        displayName.attributedPlaceholder = NSMutableAttributedString.init(string:"Username", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        emailAddress.attributedPlaceholder = NSMutableAttributedString.init(string:"Email Address", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        password.attributedPlaceholder = NSMutableAttributedString.init(string:"Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        confirmPassword.attributedPlaceholder = NSMutableAttributedString.init(string:"Confirm Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
    }
    
    func register()
    {
        Utility.shared.startProgress(message:"Loading")
        let parameters:Parameters = [Key.option.rawValue:API.register.rawValue,Key.email.rawValue:emailAddress.text ?? "",Key.password.rawValue:password.text ?? "",Key.display_name.rawValue:displayName.text ?? ""]
        let url = Constants.baseURL
        Alamofire.request(url, method: .post, parameters: parameters, encoding:URLEncoding.default, headers: nil).validate().responseString { (response) in
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
    
    func loginProcess(user:JSON)
    {
        LocalDBWrapper.shared.createUser(userJSON:user)
        AppDelegate.shared.currentUser = LocalDBWrapper.shared.readUser()
        self.presentingViewController?.presentingViewController?.dismiss(animated:true, completion:nil)
        NotificationCenter.default.post(name:Constants.notifyUserDidChange, object: nil)
    }
}
