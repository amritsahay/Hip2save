//
//  DealsTableViewCell.swift
//  Hip2Save
//
//  Created by ip-d on 15/11/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class DealsTableViewCell: UITableViewCell {
    @IBOutlet weak var comment: UIButton!
    @IBOutlet weak var thumbImage: UIImageView!
    
    @IBOutlet weak var cardview: UIView!
    @IBOutlet weak var hipListSign: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var count: UILabel!
    
    @IBOutlet weak var hiplistImage: UIImageView!
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var myWishListText: UILabel!
    @IBOutlet weak var count_view: RoundView!
    var controller:UIViewController! = nil
    var indexPath:IndexPath! = nil
    var  post:JSON? = nil
    @IBOutlet weak var popular: BorderView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        cardview.layer.shadowColor = UIColor.black.cgColor
        cardview.layer.shadowOpacity = 1
        //cardview.layer.shadowOffset = CGSize.zero
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func comments(_ sender: Any) {
        
        if self.controller == nil
        {
            return
        }
        let navigation = self.controller.storyboard?.instantiateViewController(withIdentifier:"CommentNavigationSID") as? UINavigationController
        
        let commentController = navigation?.viewControllers.last as! CommentsViewController
        commentController.post = post
        self.controller.present(navigation!, animated: true, completion:nil)
    }
    @IBAction func share(_ sender: Any) {
        if controller == nil
        {
            return
        }
        let postlink:URL = URL.init(string:post!["link"].stringValue)!
//        //let itemLink:URL = postlink.deletingLastPathComponent()
//        let activityItems = [postlink]
//        let activity = UIActivityViewController.init(activityItems: activityItems, applicationActivities:nil)
//
//        controller.present(activity, animated: true, completion:nil)
        let activityVC = UIActivityViewController(activityItems: [postlink], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = controller.view
        controller.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func hiplistAction(_ sender: Any) {
        if AppDelegate.shared.currentUser == nil
        {
            showSigninAlert()
            return
        }
        
        if self.post!["wishlist_type"].stringValue == "hiplist"
        {
            hiplist()
        }
        else
        {
            myCookBook()
        }
        
        
    }
    
    func showSigninAlert()
    {
        if controller == nil
        {
            return
        }
        
        let signinAlert = UIAlertController.init(title:"Hip2Save", message:"Oops! You must sign up or login to your Hip account to access this feature.", preferredStyle:.alert)
        
        let noThanks = UIAlertAction.init(title:"No Thanks", style:.default) { (alertAction) in
            signinAlert.dismiss(animated:true, completion: nil)
        }
        
        let signin = UIAlertAction.init(title:"Sign In", style: .default) { (alertAction) in
            signinAlert.dismiss(animated:true, completion: nil)
            let vc = self.controller.storyboard?.instantiateViewController(withIdentifier:Identifiers.LoginViewController.rawValue)
            self.controller.present(vc!, animated:true, completion: nil)
        }
        
        signinAlert.addAction(noThanks)
        signinAlert.addAction(signin)
        controller.present(signinAlert, animated: true, completion:nil)
    }
    
    func configureCell(post:inout JSON)
    {
        self.post = post
        postTitle.text = post[Key.post_title.rawValue].stringValue.convertHtml()
        let comment_count = post[Key.comment_count.rawValue].stringValue
        
        if comment_count == "" || comment_count == "0"
        {
            count.text = "0"
        }
        else
        {
            count.text = comment_count
            count_view.isHidden = false
        }
        thumbImage?.kf.indicatorType = .activity
        let imagePath = post[Key.thumbnail_image.rawValue].stringValue
        let url = URL.init(string:imagePath)
        thumbImage?.kf.setImage(with: url, placeholder:UIImage.init(named:"placeholder-image"), options: [.cacheOriginalImage], progressBlock: nil, completionHandler:nil)
        thumbImage?.contentMode = .scaleAspectFill
        thumbImage?.clipsToBounds = true
        
        flagImage?.kf.indicatorType = .activity
        let flagPath = post[Key.post_flag_url.rawValue].stringValue
        let flagUrl = URL.init(string:flagPath)
        flagImage?.kf.setImage(with: flagUrl, placeholder:nil, options: [.cacheOriginalImage], progressBlock: nil, completionHandler:nil)
        flagImage?.contentMode = .scaleAspectFit
        flagImage?.clipsToBounds = true
        
        if post["wishlist_type"].stringValue == "hiplist"
        {
            myWishListText.text = "Hiplist"
        }
        else
        {
            myWishListText.text = "MyCookbook"
        }
        
        if post["wishlist_value"].boolValue
        {
            updateHipList(action:"1")
        }
        else
        {
            updateHipList(action:"0")
        }
    }
    
    func updateHipList(action:String)
    {
        if action == "0"
        {
            hipListSign.text = "+"
        }
        else
        {
            hipListSign.text = "-"
        }
    }
    
    func hiplist()
    {
        var action = "0"
        if (post?["wishlist_value"].boolValue)!
        {
            action = "0"
        }
        else
        {
            action = "1"
        }
        Utility.shared.startProgress(message:"")
        let post_id = post?["ID"].intValue
        
        let parameters:Parameters = [Key.option.rawValue:API.hiplist_toggle.rawValue,Key.post_id.rawValue:post_id!,Key.action.rawValue:action]
        
        var headers:HTTPHeaders? = nil
        let token = AppDelegate.shared.getEncryptionToken()
        if  token != ""
        {
            headers = ["x-access-cookie":token]
        }
        
        let url = Constants.baseURL
        Alamofire.request(url, method: .post, parameters: parameters, encoding:URLEncoding.default, headers: headers).validate().responseString { (response) in
            Utility.shared.stopProgress()
            switch response.result {
            case .success:
                // {\"status\":\"error\",\"result\":\"\",\"error\":\"invalid cookie\"}
                let jsonString = response.value?.replacingOccurrences(of:"mu-plugins/query-monitor/wp-content/db.php", with:"")
                let json = JSON.init(parseJSON:jsonString ?? "{}")
                let response = json.dictionary
                let status = response?["status"]?.stringValue
                if status == "ok"
                {
                    self.updateHipList(action:action)
                    NotificationCenter.default.post(name:Constants.notifyDealCellDidChange,object:nil, userInfo: ["indexPath" : self.indexPath])
                }
                else
                {
                    Utility.shared.showSnackBarMessage(message:(response?["message"]?.stringValue)!)
                }
                
            case .failure(let error):
                print(error)
                Utility.shared.showSnackBarMessage(message:error.localizedDescription)
            }
        }
    }
    
    func myCookBook()
    {
        var action = "0"
        if (post?["wishlist_value"].boolValue)!
        {
            action = "0"
        }
        else
        {
            action = "1"
        }
        Utility.shared.startProgress(message:"")
        let post_id = post?["ID"].intValue
        let parameters:Parameters = [Key.option.rawValue:API.cookbook_toggle.rawValue,Key.post_id.rawValue:post_id!,Key.action.rawValue:action]
        
        var headers:HTTPHeaders? = nil
        let token = AppDelegate.shared.getEncryptionToken()
        if  token != ""
        {
            headers = ["x-access-cookie":token]
        }
        
        let url = Constants.baseURL
        Alamofire.request(url, method: .post, parameters: parameters, encoding:URLEncoding.default, headers: headers).validate().responseString { (response) in
            Utility.shared.stopProgress()
            switch response.result {
            case .success:
                // {\"status\":\"error\",\"result\":\"\",\"error\":\"invalid cookie\"}
                let jsonString = response.value?.replacingOccurrences(of:"mu-plugins/query-monitor/wp-content/db.php", with:"")
                let json = JSON.init(parseJSON:jsonString ?? "{}")
                let response = json.dictionary
                let status = response?["status"]?.stringValue
                if status == "ok"
                {
                    self.updateHipList(action:action)
                    NotificationCenter.default.post(name:Constants.notifyDealCellDidChange,object:nil, userInfo: ["indexPath" : self.indexPath])
                }
                else
                {
                    Utility.shared.showSnackBarMessage(message:(response?["message"]?.stringValue)!)
                }
                
            case .failure(let error):
                print(error)
                Utility.shared.showSnackBarMessage(message:error.localizedDescription)
            }
        }
    }
}
