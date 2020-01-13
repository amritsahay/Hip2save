//
//  PostViewController.swift
//  Hip2Save
//
//  Created by ip-d on 20/02/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class PostViewController: UIViewController {
    
    @IBOutlet weak var commet: UITextView!
    @IBOutlet weak var placeholder: UILabel!
    var isReply = false
    var postID:String = ""
    var parentID:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
       /* commet.delegate = self
        let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        let logo = UIImage(named: "hip2save_main")
        logoImage.image = logo
        self.navigationItem.titleView = logoImage */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "PostViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    @IBAction func post(_ sender: Any) {
        if commet.text.count == 0
        {
            Utility.shared.showSnackBarMessage(message:"Please enter some text.")
        }
        else
        {
            if AppDelegate.shared.currentUser == nil
            {
                showSigninAlert()
            }
            else
            {
                postComment()
            }
            
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated:true, completion:nil)
    }
    
    func createParam() -> Parameters
    {
        if isReply
        {
            let parameters:Parameters = [Key.option.rawValue:API.add_comment.rawValue,Key.post_id.rawValue:postID,Key.content.rawValue:commet.text!,Key.comment_parent.rawValue:parentID]
            return parameters
        }
        else
        {
            let parameters:Parameters = [Key.option.rawValue:API.add_comment.rawValue,Key.post_id.rawValue:postID,Key.content.rawValue:commet.text!]
            return parameters
        }
    }
    
    func postComment()
    {
        Utility.shared.startProgress(message:"")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = Constants.baseURL
        
        
        let parameters:Parameters = createParam()
        
        var headers:HTTPHeaders? = nil
        let token = AppDelegate.shared.getEncryptionToken()
        if  token != ""
        {
            headers = ["x-access-cookie":token]
        }
        
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
                    Utility.shared.showSnackBarMessage(message:"Successfully posted.")
                    self.dismiss(animated:true, completion: nil)
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
    
    func showSigninAlert()
    {
        let signinAlert = UIAlertController.init(title:"Hip2Save", message:"Oops! You must sign up or login to your Hip account to access this feature.", preferredStyle:.alert)
        
        let noThanks = UIAlertAction.init(title:"No Thanks", style:.default) { (alertAction) in
            signinAlert.dismiss(animated:true, completion: nil)
        }
        
        let signin = UIAlertAction.init(title:"Sign In", style: .default) { (alertAction) in
            signinAlert.dismiss(animated:true, completion: nil)
            let vc = self.storyboard?.instantiateViewController(withIdentifier:Identifiers.LoginViewController.rawValue)
            self.present(vc!, animated:true, completion: nil)
        }
        
        signinAlert.addAction(noThanks)
        signinAlert.addAction(signin)
        
        self.present(signinAlert, animated: true, completion:nil)
    }
    
}

extension PostViewController:UITextViewDelegate
{
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text.count == 0
        {
            placeholder.isHidden = false
        }
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        placeholder.isHidden = true
        return true
    }
}
