//
//  LoginViewController.swift
//  Hip2Save
//
//  Created by ip-d on 14/11/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import Firebase
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //emailAddress.text = "collin@hip2save.com"
        //password.text = "esfera2"
        setUI()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePopup), name: .reset, object: nil)
     
    }
    
    @objc func handlePopup(){
       // Utility.shared.showSnackBarMessage(message:"Please check your email for a confirnmation link.")
        let alertController = UIAlertController(title: "Title", message: "Message", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("OK Pressed")
        }
      
        
        // Add the actions
        alertController.addAction(okAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "LoginViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    //MARK:- Button Actions
    
    @IBAction func login(_ sender: Any) {
        
        if (emailAddress.text?.isBlank)!
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
        else
        {
            api_Login()
        }
        
    }
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated:true, completion:nil)
    }
    
    @IBAction func guestLogin(_ sender: Any) {
        
    }
    
    @IBAction func facebook(_ sender: Any) {
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        loginManager.logIn(withReadPermissions: ["email","public_profile"], from:self) { (loginResult,error) in
            if error != nil
            {
                //        Utility.shared.showSnackBarMessage(message:(error?.localizedDescription)!)
            }
            else if (loginResult?.isCancelled)!
            {
                //       Utility.shared.showSnackBarMessage(message:"Facebook login is cancelled")
            }
            else
            {
                let params = ["fields": "email, name, picture.height(961),work"]
                let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest.init(graphPath:"me", parameters:params)
                graphRequest.start(completionHandler: { (requestConnection,result, error) in
                    
                    if error != nil {
                        // Error occured while logging in
                        // handle error
                        //              Utility.shared.showSnackBarMessage(message:(error?.localizedDescription)!)
                        return
                    }
                    // Details received successfully
                    let dictionary = result as! [String: AnyObject]
                    //let email = dictionary["email"]
                    
                    self.navigationController?.pushViewController((self.storyboard?.instantiateViewController(withIdentifier:Identifiers.CustomTabBarViewController.rawValue))!, animated: true)
                    
                    let userId = "\(dictionary["id"]!)"
                    let username =  dictionary["name"] as? String
                    if let email  = dictionary["email"] as? String
                    {
                        self.api_social(username:username!, email:email, uid: "\(userId)", provider: Key.facebook.rawValue)
                    }
                    else
                    {
                        self.api_social(username:username!, email:"\(userId)@facebook.com", uid: "\(userId)", provider: Key.facebook.rawValue)
                    }
                    
                    print(dictionary)
                })
            }
        }
        
    }
    
    @IBAction func google(_ sender: Any) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }
    
    //MARK:- Init Methods & Other Methods
    
    func setUI()
    {
        emailAddress.attributedPlaceholder = NSMutableAttributedString.init(string:"Email Address", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        password.attributedPlaceholder = NSMutableAttributedString.init(string:"Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
    }
    
    func api_Login()
    {
        Utility.shared.startProgress(message:"Loading")
        let parameters:Parameters = [Key.option.rawValue:API.generate_auth_cookie.rawValue,Key.username.rawValue:emailAddress.text ?? "",Key.password.rawValue:
            password.text ?? ""]
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
        self.dismiss(animated: true, completion:nil)
        NotificationCenter.default.post(name:Constants.notifyUserDidChange, object: nil)
    }
    
    func api_social(username:String,email:String,uid:String,provider:String)
    {
        Utility.shared.startProgress(message:"Loading")
        let parameters:Parameters = [Key.option.rawValue:API.social_login.rawValue,Key.username.rawValue:username,Key.email.rawValue:email,Key.uid.rawValue:uid,Key.provider.rawValue:provider]
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
    
}


extension LoginViewController:GIDSignInDelegate
{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            let userId = user.userID
            let fullName = user.profile.name
            let email = user.profile.email
            
            self.api_social(username:fullName!, email:email!, uid:userId!, provider: Key.googleplus.rawValue)
            self.navigationController?.pushViewController((self.storyboard?.instantiateViewController(withIdentifier:Identifiers.CustomTabBarViewController.rawValue))!, animated: true)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
        
    }
    
    
}

extension LoginViewController:GIDSignInUIDelegate
{
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion:nil)
        
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion:nil)
    }
}


