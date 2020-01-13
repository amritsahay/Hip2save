//
//  SideMenuViewController.swift
//  Hip2Save
//
//  Created by ip-d on 20/11/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import MessageUI

class SideMenuViewController: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var menuListView: UITableView! { didSet {
        
        self.menuListView.register(UINib.init(nibName:"MenuTableViewCell", bundle:nil), forCellReuseIdentifier: "MenuTableViewCell")
        }
    }
    @IBOutlet weak var username: UILabel!
    var name = ["Budget","Categories","Contact Us","Coupon Database","Hip2Share","My Cookbook","My Hiplist","Stores","Settings","Logout"]
    var image = ["money-bag.png","category","contact-us","shop","photo-camera","cooking-on-fire","heart-shape-silhouette","discount","settings-work-tool.png","logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if AppDelegate.shared.currentUser == nil
        {
            name = ["Login","Budget","Categories","Contact Us","Coupon Database","Hip2Share","My Cookbook","My Hiplist","Stores","Settings"]
            image = ["logout","money-bag.png","category","contact-us","shop","photo-camera","cooking-on-fire","heart-shape-silhouette","discount","settings-work-tool.png"]
            menuListView.reloadData()
            username.text = ""
        }
        else
        {
            loadProfile()
            name = ["Budget","Categories","Contact Us","Coupon Database","Hip2Share","My Cookbook","My Hiplist","Stores","Settings","Logout"]
            image = ["money-bag.png","category","contact-us","shop","photo-camera","cooking-on-fire","heart-shape-silhouette","discount","settings-work-tool.png","logout"]
            menuListView.reloadData()
            username.text = "" + (AppDelegate.shared.currentUser?.displayname ?? "")
        }
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "SideMenuViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    @IBAction func setting(_ sender: Any) {
        showSetting()
    }
    
    func loadProfile()
    {
        
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
                    self.username.text = "" + (profile?["displayname"]?.string)!
                    self.profileImage?.kf.indicatorType = .activity
                    let imagePath = profile?["avtar"]?.stringValue
                    let url = URL.init(string:imagePath!)
                    self.profileImage?.kf.setImage(with: url, placeholder:UIImage.init(named:"placeholder-image"), options: [.forceRefresh], progressBlock: nil, completionHandler:nil)
                    self.profileImage?.contentMode = .scaleAspectFill
                    self.profileImage?.clipsToBounds = true
                    
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

extension SideMenuViewController:UITableViewDelegate,UITableViewDataSource
{
    // MARK:- TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return name.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var  cell = tableView.dequeueReusableCell(withIdentifier:"MenuTableViewCell", for: indexPath) as? MenuTableViewCell
        
        if cell == nil
        {
            let nibArray:NSArray = Bundle.main.loadNibNamed("MenuTableViewCell", owner: nil, options: nil )! as NSArray
            cell = (nibArray.object(at: 0) as! MenuTableViewCell)
        }
        cell?.selectionStyle = .none
        cell?.icon.image = UIImage.init(named:image[indexPath.row])
        cell?.menuName.text = name[indexPath.row]
        return cell!
        
    }
    
    // MARK:- TableView Delegate
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect.init(x: CGFloat.leastNormalMagnitude, y: CGFloat.leastNormalMagnitude, width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude))
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // hip2share
        
        if name[indexPath.row] == "Hip2Share"
        {
            showHip2Share()
        }
        else if name[indexPath.row] == "My Hiplist" // hiplist
        {
            showHipList()
        }
        else if name[indexPath.row] == "My Cookbook" // cookbook
        {
            showCookbook()
        }
        else if name[indexPath.row] == "Categories" // categories
        {
            showCategories()
        }
        else if name[indexPath.row] == "Stores" // stores
        {
            showStore()
        }else if name[indexPath.row] == "Coupon Database" // stores
        {
            guard let url = URL(string:  "https://hip2save.com/coupon-database/") else { return }
            UIApplication.shared.open(url)
            
        }
        else if name[indexPath.row] == "Contact Us" // contact us
        {
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
        else if name[indexPath.row]  == "Budget" // Budget
        {
           showBudget()
        }
        else if name[indexPath.row]  == "Settings" // settings
        {
            showSetting()
        }
        else if name[indexPath.row] == "Logout" // logout
        {
            if AppDelegate.shared.currentUser != nil
            {
                showLogoutAlert()
            }
        }else if name[indexPath.row] == "Login"{
            let vc = self.storyboard?.instantiateViewController(withIdentifier:Identifiers.LoginViewController.rawValue)
            self.present(vc!, animated:true, completion: nil)
        }
    }
    
    func showLogoutAlert()
    {
        
        let alertController = UIAlertController.init(title:"Hip2Save", message:"Do you want to logout?", preferredStyle:.alert)
        
        let noAction = UIAlertAction.init(title:"No", style:.default) { (alertAction) in
            alertController.dismiss(animated:true, completion: nil)
        }
        
        let yesAction = UIAlertAction.init(title:"Yes", style: .default) { (alertAction) in
            alertController.dismiss(animated:true, completion: nil)
            LocalDBWrapper.shared.deleteUser()
            AppDelegate.shared.drawerController?.setDrawerState(.closed, animated: true)
            AppDelegate.shared.currentUser = nil
            self.name = ["Login","Budget","Categories","Contact Us","Coupon Database","Hip2Share","My Cookbook","My Hiplist","Stores","Settings"]
            self.image = ["logout","money-bag.png","category","contact-us","shop","photo-camera","cooking-on-fire","heart-shape-silhouette","discount","settings-work-tool.png"]
            self.menuListView.reloadData()
            self.username.text = "Hello"
            NotificationCenter.default.post(name:Constants.notifyUserDidChange, object: nil)
        }
        
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion:nil)
    }
    
    func showSetting()
    {
        
        let controller =  AppDelegate.shared.drawerController?.mainViewController
        if (controller?.isKind(of:UINavigationController.self))!
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier:Identifiers.SettingNavigationController.rawValue)
            let navigation = controller as! UINavigationController
            navigation.viewControllers.last?.present(vc!, animated: true, completion: nil)
            
        }
        else if (controller?.isKind(of:SettingTableViewController.self))!
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier:Identifiers.SettingNavigationController.rawValue)
            controller?.present(vc!, animated: true, completion: nil)
        }
        else
        {
            Utility.shared.showSnackBarMessage(message:"Something went wrong!")
        }
    }
    
    func showHip2Share()
    {
        let mainController =  AppDelegate.shared.drawerController?.mainViewController
        if (mainController?.isKind(of:UINavigationController.self))!
        {
            let navigation = mainController as! UINavigationController
            let viewControllers  = navigation.viewControllers
            for viewController  in viewControllers
            {
                if (viewController.isKind(of:CustomTabBarViewController.self))
                {
                    let tabController = viewController as! CustomTabBarViewController
                    let button = UIButton()
                    button.tag = 4
                    tabController.shareAction(button)
                    AppDelegate.shared.drawerController?.setDrawerState(.closed, animated: true)
                    break
                }
            }
        }
    }
    
    func showHipList()
    {
        let mainController =  AppDelegate.shared.drawerController?.mainViewController
        if (mainController?.isKind(of:UINavigationController.self))!
        {
            let navigation = mainController as! UINavigationController
            let viewControllers  = navigation.viewControllers
            for viewController  in viewControllers
            {
                if (viewController.isKind(of:CustomTabBarViewController.self))
                {
                    let tabController = viewController as! CustomTabBarViewController
                    let button = UIButton()
                    button.tag = 3
                    tabController.shareAction(button)
                    AppDelegate.shared.drawerController?.setDrawerState(.closed, animated: true)
                    break
                }
            }
        }
    }
    
    func showStore()
    {
        let mainController =  AppDelegate.shared.drawerController?.mainViewController
        if (mainController?.isKind(of:UINavigationController.self))!
        {
            let navigation = mainController as! UINavigationController
            let viewControllers  = navigation.viewControllers
            for viewController  in viewControllers
            {
                if (viewController.isKind(of:CustomTabBarViewController.self))
                {
                    let tabController = viewController as! CustomTabBarViewController
                    let button = UIButton()
                    button.tag = 2
                    tabController.shareAction(button)
                    AppDelegate.shared.drawerController?.setDrawerState(.closed, animated: true)
                    break
                }
            }
        }
    }
    
    func showCategories()
    {
        //CategoryNavigationSID
        let navigation = self.storyboard?.instantiateViewController(withIdentifier:"CategoryNavigationSID") as? UINavigationController
        self.present(navigation!, animated: true, completion:nil)
    }
    
    func showBudget()
    {
        //CategoryNavigationSID
        let navigation = self.storyboard?.instantiateViewController(withIdentifier:"BudgetNavigationSID") as? UINavigationController
        self.present(navigation!, animated: true, completion:nil)
    }
    
    func showCookbook()
    {
        //CategoryNavigationSID
        let navigation = self.storyboard?.instantiateViewController(withIdentifier:"MyCookbookNavigationSID") as? UINavigationController
        self.present(navigation!, animated: true, completion:nil)
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["collin@hip2save.com"])
        mailComposerVC.setSubject("Hip2Save")
        return mailComposerVC
    }
}

extension SideMenuViewController:MFMailComposeViewControllerDelegate
{
    func showSendMailErrorAlert() {
        
        let showSendMailErrorAlert = UIAlertController.init(title:"Could Not Send Email", message:  "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle:.alert)
        let cancel = UIAlertAction.init(title:"Cancel", style: .cancel) { (alertAction) in
            showSendMailErrorAlert.dismiss(animated:true, completion: nil)
        }
        showSendMailErrorAlert.addAction(cancel)
        self.present(showSendMailErrorAlert, animated: true, completion:nil)
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
