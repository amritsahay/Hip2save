//
//  ShareYourDealViewController.swift
//  Hip2Save
//
//  Created by ip-d on 20/12/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ShareYourDealViewController: UIViewController {
    
    @IBOutlet weak var placeholder: UILabel!
    @IBOutlet weak var text_title: UITextField!
    @IBOutlet weak var text_store: UITextField!
    @IBOutlet weak var dealImage: UIImageView!
    @IBOutlet weak var text_link: UITextField!
    
    
    @IBOutlet weak var checkimg: UIImageView!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var checkBoxView: UIView!
    @IBOutlet weak var navigation: UINavigationBar!
     var popOver:UIPopoverController?
    var storeID:String! = ""
    var imageURL:URL! = URL.init(string:"")
    var stores:[JSON] = []
    var storePicker:UIPickerView = UIPickerView.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "ShareYourDealViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dealImageAction(_ sender: Any) {
        showImagePicker()
        
    }
    
    @IBAction func submitAction(_ sender: Any) {
        
        if dealImage.image == nil
        {
            Utility.shared.showSnackBarMessage(message:"Please upload an image.")
        }
        else if (text_title.text?.isBlank)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter the title.")
        }
        else if (text_store.text?.isBlank)!
        {
            Utility.shared.showSnackBarMessage(message:"Please select the store.")
        }
        else if (descriptionView.text?.isBlank)!
        {
            Utility.shared.showSnackBarMessage(message:"Please add some description.")
        }
        else if checkBoxView.tag != 1
        {
            Utility.shared.showSnackBarMessage(message:"Please accept terms & conditions.")
        }
        else
        {
            
            addShare2Hip()
        }
        
        
    }
    
    @IBAction func checkBoxAction(_ sender: Any) {
        if checkBoxView.tag == 0
        {
            checkBoxView.tag = 1
            checkimg.isHidden = false
            //checkBoxView.backgroundColor = Constants.selectedColor
            
        }
        else
        {
            checkBoxView.tag = 0
            checkimg.isHidden = true
            //checkBoxView.backgroundColor = UIColor.white
        }
    }
    
    func setupUI()
    {
       /* let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        let logo = UIImage(named: "hip2save_main")
        logoImage.image = logo
        self.navigationItem.titleView = logoImage */
        checkimg.isHidden = true
        loadStore()
        storePicker.delegate = self
        text_store.inputView = storePicker
        
    }
    
    
    
    func showImagePicker()
    {
        let pickerPop = UIImagePickerController()
        pickerPop.delegate = self
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo From Camera", style: .default, handler:{(action:UIAlertAction) in
            pickerPop.sourceType = .camera
            self.present(pickerPop, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "From Photos", style: .default, handler:{(action:UIAlertAction) in
            pickerPop.sourceType = .photoLibrary
            self.present(pickerPop, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            self.popOver = UIPopoverController(contentViewController: pickerPop)
            self.popOver?.present(from: self.dealImage.bounds, in: self.dealImage, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        default:
            break
        }
        self.present(alert, animated: true, completion: nil)
//        let pickerPop = UIAlertController.init(title:"Hip2Save", message:"Please select an option.", preferredStyle: .actionSheet)
//
//        let cameraOption = UIAlertAction.init(title:"Take Photo From Camera", style:.default) { (action) in
//            let imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//            imagePicker.allowsEditing = false
//            imagePicker.sourceType = .camera
//            self.present(imagePicker,animated: true,completion: nil)
//        }
//
//        let photoOption = UIAlertAction.init(title:"From Photos", style: .default) { (action) in
//            
//            let imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//            imagePicker.allowsEditing = false
//            imagePicker.sourceType = .photoLibrary
//            self.present(imagePicker,animated: true,completion: nil)
        
       // }
        
//        let cancelOption = UIAlertAction.init(title:"Cancel", style: .cancel) { (action) in
//            pickerPop.dismiss(animated: true, completion: nil)
//        }
//
//        pickerPop.addAction(cameraOption)
//        pickerPop.addAction(photoOption)
//        pickerPop.addAction(cancelOption)
//
//        self.present(pickerPop, animated: true, completion:nil)
    }
    
    
    func addShare2Hip()
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
        //store_other
        
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(API.add_hip2share.rawValue.data(using:String.Encoding.utf8)!, withName: Key.option.rawValue)
                
                multipartFormData.append((self.text_title.text?.data(using: String.Encoding.utf8))!, withName: Key.post_title.rawValue)
                
                multipartFormData.append(self.descriptionView.text.data(using:String.Encoding.utf8)!, withName: Key.post_content.rawValue)
                
                multipartFormData.append(self.storeID.data(using: String.Encoding.utf8)!, withName: Key.store.rawValue)
                
                multipartFormData.append((self.text_link.text?.data(using: String.Encoding.utf8))!, withName: Key.deal_link.rawValue)
                
                multipartFormData.append(self.imageURL, withName: Key.featured_image.rawValue)
                
                if self.storeID == "other"
                {
                    multipartFormData.append(("Other".data(using: String.Encoding.utf8))!, withName:"store_other")
                }
                
        },
            to: url,
            method:.post,
            headers:headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseString { response in
                        Utility.shared.stopProgress()
                        print("Validation Successful")
                        let jsonString = response.value?.replacingOccurrences(of:"mu-plugins/query-monitor/wp-content/db.php", with:"")
                        let json = JSON.init(parseJSON:jsonString ?? "{}")
                        let response = json.dictionary
                        let status = response?["status"]?.stringValue
                        if status == "ok"
                        {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier:Identifiers.ThankYouViewController.rawValue)
                            self.present(vc!, animated:true, completion:nil)
                        }
                        else
                        {
                            Utility.shared.showSnackBarMessage(message:(response?["message"]?.stringValue)!)
                        }
                        
                    }
                case .failure(let encodingError):
                    Utility.shared.stopProgress()
                    print(encodingError)
                    Utility.shared.showSnackBarMessage(message:encodingError.localizedDescription)
                }
        }
        )
        
        
        
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if segue.identifier == Identifiers.BudgetIdentifier.rawValue
//        {
//            self.present(segue.destination, animated:true, completion:nil)
//        }
//    }
    
    @IBAction func termsncond(_ sender: Any) {
         //performSegue(withIdentifier:"WebViewController", sender: nil)
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewcontrol = storyboard.instantiateViewController(withIdentifier:  "WebViewController") as! WebViewController
        let navController = UINavigationController(rootViewController:viewcontrol)
        self.present(navController, animated: true, completion: nil)
    }
    
    func loadStore()
    {
        Utility.shared.startProgress(message:"")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = Constants.baseURL
        
        let parameters:Parameters = [Key.option.rawValue:API.store_list.rawValue]
        
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
                    self.stores =  (response?["result"]?.arrayValue)!
                    self.storePicker.reloadAllComponents()
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

extension ShareYourDealViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    /////load image from device
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated:true, completion:nil)
        
        if let photoImage = info[.originalImage] as? UIImage
        {
            dealImage.image = photoImage
            let timestamp = UInt64(floor(Date().timeIntervalSince1970 * 1000))
            let imageName = "\(timestamp).jpeg"
            let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
            if let jpegData = photoImage.jpegData(compressionQuality: 0.5) {
                try? jpegData.write(to: imagePath)
                imageURL = imagePath
            }
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}

extension ShareYourDealViewController:UITextViewDelegate
{
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.isEmpty
        {
            placeholder.isHidden = false
        }
        else
        {
            placeholder.isHidden = true
        }
        
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        if textView.text.isEmpty
        {
            placeholder.isHidden = false
        }
        else
        {
            placeholder.isHidden = true
        }
        return true
    }
}

extension ShareYourDealViewController:UIPickerViewDelegate,UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stores.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if stores.count == row
        {
            return "Other"
        }
        return stores[row]["store_title"].string
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if stores.count == row
        {
            storeID =  "other"
            text_store.text = "Other" 
        }
        else
        {
            let store_ID = stores[row]["store_id"].intValue
            storeID = "\(store_ID)"
            text_store.text = stores[row]["store_title"].string
        }
        
        
    }
    
}
