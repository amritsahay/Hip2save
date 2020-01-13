//
//  MoreViewController.swift
//  Hip2Save
//
//  Created by ip-d on 24/12/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit
import MessageUI

class MoreViewController: UIViewController {
    
    let menu = ["Hip2Save","Hip2Keto","Budget","Categories","Contact Us","Coupon Database","Disclosure Policy","DIY/Crafts","Facebook","Hot Deal Alerts","Instagram","My Cookbook","Pinterest","Recipes","Terms & Conditions","YouTube"]
    
    
    @IBOutlet weak var moreListView: UITableView! { didSet {
        self.moreListView.register(UINib.init(nibName:"MoreTableViewCell", bundle:nil), forCellReuseIdentifier: "MoreTableViewCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        let logo = UIImage(named: "hip2save_main")
        logoImage.image = logo
        self.navigationItem.titleView = logoImage
        //Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "MoreViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["collin@hip2save.com"])
        mailComposerVC.setSubject("Hip2Save")
        return mailComposerVC
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Identifiers.BudgetIdentifier.rawValue
        {
            self.present(segue.destination, animated:true, completion:nil)
        }
    }
    
    func showHotDeals()
    {
        let composeVC  = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        composeVC.recipients = ["41411"]
        composeVC.body = "Hip2Save"
        
        if MFMessageComposeViewController.canSendText()
        {
            self.present(composeVC, animated: true, completion: nil)
        }
    }
}

extension MoreViewController:UITableViewDelegate,UITableViewDataSource
{
    // MARK:- TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var  cell = tableView.dequeueReusableCell(withIdentifier:"MoreTableViewCell", for: indexPath) as? MoreTableViewCell
        
        if cell == nil
        {
            let nibArray:NSArray = Bundle.main.loadNibNamed("MoreTableViewCell", owner: nil, options: nil )! as NSArray
            cell = (nibArray.object(at: 0) as! MoreTableViewCell)
            
        }
        cell?.cellName.text = menu[indexPath.row]
        if indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 6 || indexPath.row == 7 || indexPath.row == 9 || indexPath.row == 11 || indexPath.row == 14 || indexPath.row == 13
        {
            cell?.accessoryType = .disclosureIndicator
        }
        else
        {
            cell?.accessoryType = .none
        }
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
        
        if indexPath.row == 0
        {
            guard let url = URL(string: "http://www.hip2save.com") else { return }
            UIApplication.shared.open(url)
            
        }
        else if indexPath.row == 1
        {
            guard let url = URL(string: "http://www.hip2keto.com") else { return }
            UIApplication.shared.open(url)
           
            
        }
        else if indexPath.row == 2
        {
            performSegue(withIdentifier:Identifiers.BudgetIdentifier.rawValue, sender:nil)
            
            
        }
        else if indexPath.row == 3
        {
            performSegue(withIdentifier:Identifiers.CategoryIdentifier.rawValue, sender:nil)
           
        }
        else if indexPath.row == 4
        {
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
            
           
        }
        else if indexPath.row == 5
        {
            guard let url = URL(string:  "https://hip2save.com/coupon-database/") else { return }
            UIApplication.shared.open(url)
            
            
        }else if indexPath.row == 6
        {
            self.performSegue(withIdentifier:"policyViewController", sender: nil)
        
            
        }
        else if indexPath.row == 7
        {
            performSegue(withIdentifier:Identifiers.DIYNavigationIdentifier.rawValue, sender:nil)
        
          
        }
        else if indexPath.row == 8
        {
            guard let url = URL(string: "fb://profile/363066120342") else {
                return
            }
            UIApplication.shared.open(url, options: [:]) { (result) in
                
                if !result
                {
                    guard let url = URL(string: "http://www.facebook.com/Hip2Save") else { return }
                    UIApplication.shared.open(url)
                }
                
            }
           
            
            
        }else if indexPath.row == 9
        {
            let message = "How to get Text Messages for HOT Hip2Save Deals:\n--Text \"Hip2Save\" to 41411\n--That's it! You will now be alerted via text whenever a Hot deal is posted.\n--To stop receiving text messages, simply text \"STOP\" to 41411.\n--Note that standard text messaging rates will apply."
            let showSendTextAlert = UIAlertController.init(title:"Hot Deal Alerts", message: message, preferredStyle:.alert)
            
            showSendTextAlert.addAction(UIAlertAction(title:"OKAY GOT IT", style: .default, handler: { (action) in
                showSendTextAlert.dismiss(animated:true, completion:nil)
            }))
            
            showSendTextAlert.addAction(UIAlertAction(title:"TEXT NOW", style: .default, handler: { (action) in
                showSendTextAlert.dismiss(animated:true, completion:nil)
                self.showHotDeals()
            }))
            
            self.present(showSendTextAlert, animated:true, completion:nil)
            //self.performSegue(withIdentifier:"HotDealAlertVC", sender: nil)
            
            
        }else if indexPath.row == 10
        {
            guard let url = URL(string: "http://www.instagram.com/hip2save") else { return }
            UIApplication.shared.open(url)
        }
        else if indexPath.row == 11
        {
            performSegue(withIdentifier:Identifiers.MyCookBookIdentifer.rawValue, sender:nil)
        }
        else if indexPath.row == 12
        {
            guard let url = URL(string: "pinterest://board/hip2save/hip2save/") else {
                return
            }
            UIApplication.shared.open(url, options: [:]) { (result) in
                
                if !result
                {
                    guard let url = URL(string: "http://www.pinterest.com/hip2save/hip2save/") else { return }
                    UIApplication.shared.open(url)
                }
                
            }
        }
        else if indexPath.row == 13 // recipes
        {
           performSegue(withIdentifier:Identifiers.CookBookIdentifer.rawValue, sender:nil)
        }
        else if indexPath.row == 14 // terms & conditions
        {
            self.performSegue(withIdentifier:"WebViewController", sender: nil)
        }
        else if indexPath.row == 15 //youtube
        {
            guard let url = URL(string:  "http://www.youtube.com/user/hip2save") else { return }
            UIApplication.shared.open(url)
        }
    }
    
}
extension MoreViewController:MFMailComposeViewControllerDelegate
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

extension MoreViewController:MFMessageComposeViewControllerDelegate
{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated:true, completion:nil)
    }
    
    
}
