//
//  ForgotViewController.swift
//  Hip2Save
//
//  Created by ip-d on 14/11/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ForgotViewController: UIViewController {

    @IBOutlet weak var emailAddress: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUI()
    
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "ForgotViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    @IBAction func ResetPassword(_ sender: Any) {
        if (emailAddress.text?.isBlank)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter email address.")
        }
        else if !(emailAddress.text?.isEmail)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter valid email address.")
        }
        else
        {
            updatePassword()
        }
    }
    
    func setUI()
    {
       
        emailAddress.attributedPlaceholder = NSMutableAttributedString.init(string:"Email Address", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
    }
    
    func updatePassword()
    {
        Utility.shared.startProgress(message:"")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = Constants.baseURL
        
        let parameters:Parameters = [Key.option.rawValue:"forgot_password","user_login":emailAddress.text!]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding:URLEncoding.default, headers: nil).validate().responseString { (response) in
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
                   // Utility.shared.showSnackBarMessage(message:(response?["result"]?.stringValue)!)
                 //   NotificationCenter.default.post(name: .reset, object: self)
                    self.emailAddress.endEditing(true)
                    let alertController = UIAlertController(title: "Please check your email for a confirmation link.", message: "", preferredStyle: .alert)
                    
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
