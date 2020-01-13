//
//  ProfileViewController.swift
//  Hip2Save
//
//  Created by ip-d on 27/02/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var save_changes: BorderView!
    @IBOutlet weak var yyyy: UITextField!
    @IBOutlet weak var dd: UITextField!
    @IBOutlet weak var mm: UITextField!
    @IBOutlet weak var favorite_restaurant: UITextField!
    @IBOutlet weak var favorite_sport: UITextField!
    @IBOutlet weak var bio: UITextView!
    @IBOutlet weak var display_name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var last_name: UITextField!
    @IBOutlet weak var first_name: UITextField!
    @IBOutlet weak var change_photo: UIButton!
    @IBOutlet weak var user_photo: UIImageView!
    let datePicker:UIDatePicker = UIDatePicker.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUI()
    }
    
    func setUI()
    {
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        mm.delegate = self
        dd.delegate = self
        yyyy.delegate = self
        mm.inputView =  datePicker
        dd.inputView =  datePicker
        yyyy.inputView =  datePicker
        disableEdit()
       /* let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        let logo = UIImage(named: "hip2save_main")
        logoImage.image = logo
        self.navigationItem.titleView = logoImage */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadProfile()
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "ProfileViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    @objc func editAction() {
        
        enableEdit()
    }
    
    @objc func cancelAction() {
        disableEdit()
    }
    
    
    @IBAction func clsoe(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func change_photo(_ sender: Any) {
//        guard let url = URL(string: "https://en.gravatar.com/site/login") else { return }
//        UIApplication.shared.open(url)
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        updateProfile()
    }
    
    func disableEdit()
    {
        yyyy.isUserInteractionEnabled = false
        dd.isUserInteractionEnabled = false
        mm.isUserInteractionEnabled = false
        favorite_restaurant.isUserInteractionEnabled = false
        favorite_sport.isUserInteractionEnabled = false
        bio.isUserInteractionEnabled = false
        display_name.isUserInteractionEnabled = false
        email.isUserInteractionEnabled = false
        last_name.isUserInteractionEnabled = false
        first_name.isUserInteractionEnabled = false
        save_changes.isHidden = true
        change_photo.isHidden = true
        self.navigationItem.rightBarButtonItems?.removeAll()
        
        let editButton = UIBarButtonItem.init(title:"Edit", style: .done, target: self, action: #selector(editAction))
        editButton.tintColor = .white
        self.navigationItem.rightBarButtonItems = [editButton]
        
        
    }
    
    func enableEdit()
    {
        yyyy.isUserInteractionEnabled = true
        dd.isUserInteractionEnabled = true
        mm.isUserInteractionEnabled = true
        favorite_restaurant.isUserInteractionEnabled = true
        favorite_sport.isUserInteractionEnabled = true
        bio.isUserInteractionEnabled = true
        display_name.isUserInteractionEnabled = false
        email.isUserInteractionEnabled = false
        last_name.isUserInteractionEnabled = true
        first_name.isUserInteractionEnabled = true
        save_changes.isHidden = false
        change_photo.isHidden = false
        
        self.navigationItem.rightBarButtonItems?.removeAll()
        
        let cancelButton = UIBarButtonItem.init(title:"Cancel", style: .done, target: self, action: #selector(cancelAction))
        cancelButton.tintColor = .white
        
        self.navigationItem.rightBarButtonItems = [cancelButton]
    }
    
    func loadProfile()
    {
        Utility.shared.startProgress(message:"")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = Constants.baseURL
        
        let parameters:Parameters = [Key.option.rawValue:API.user_profile.rawValue]
        
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
                    let profile = response?["result"]!.dictionary
                    self.first_name.text = profile?["firstname"]?.string
                    self.last_name.text = profile?["lastname"]?.string
                    self.email.text = profile?["email"]?.string
                    self.display_name.text = profile?["displayname"]?.string
                    self.bio.text = profile?["description"]?.string
                    self.favorite_sport.text = profile?["fav_store"]?.string
                    self.favorite_restaurant.text = profile?["fav_restaurant"]?.string
                    self.dd.text = profile?["birth_day"]?.string
                    self.mm.text = profile?["birth_month"]?.string
                    self.yyyy.text = profile?["birth_year"]?.string
                    self.user_photo?.kf.indicatorType = .activity
                    let imagePath = profile?["avtar"]?.stringValue
                    let url = URL.init(string:imagePath!)
                    self.user_photo?.kf.setImage(with: url, placeholder:UIImage.init(named:"placeholder-image"), options: [.forceRefresh], progressBlock: nil, completionHandler:nil)
                    self.user_photo?.contentMode = .scaleAspectFill
                    self.user_photo?.clipsToBounds = true
                    
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
    
    func updateProfile()
    {
        Utility.shared.startProgress(message:"")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = Constants.baseURL
        
        let parameters:Parameters = [Key.option.rawValue:API.update_user.rawValue,"user_email":email.text!,"user_firstname":first_name.text!,"user_lastname":last_name.text!,"user_dishplayname":display_name.text!,"user_description":bio.text!,"fav_store":favorite_sport.text!,"fav_restaurant":favorite_restaurant.text!,"birth_day":dd.text!,"birth_month":mm.text!,"birth_year":yyyy.text!]
        
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
                    Utility.shared.showSnackBarMessage(message:(response?["message"]?.stringValue)!)
                    self.disableEdit()
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension ProfileViewController:UITextFieldDelegate
{
    func textFieldDidEndEditing(_ textField: UITextField) {
        dd.text = Utility.shared.convertTime(format:"dd", time:datePicker.date)
        mm.text = Utility.shared.convertTime(format:"MM", time:datePicker.date)
        yyyy.text = Utility.shared.convertTime(format:"yyyy", time:datePicker.date)
    }
}
