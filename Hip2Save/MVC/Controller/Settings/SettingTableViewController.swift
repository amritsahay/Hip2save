//
//  SettingTableViewController.swift
//  Hip2Save
//
//  Created by ip-d on 27/02/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    let settings = ["User Profile","Change Password"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib.init(nibName:"MoreTableViewCell", bundle:nil), forCellReuseIdentifier: "MoreTableViewCell")
       /* let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        let logo = UIImage(named: "hip2save_main")
        logoImage.image = logo
        self.navigationItem.titleView = logoImage */
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "SettingTableViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    // MARK: - Table view data source
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated:true, completion:nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return settings.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var  cell = tableView.dequeueReusableCell(withIdentifier:"MoreTableViewCell", for: indexPath) as? MoreTableViewCell
        
        if cell == nil
        {
            let nibArray:NSArray = Bundle.main.loadNibNamed("MoreTableViewCell", owner: nil, options: nil )! as NSArray
            cell = (nibArray.object(at: 0) as! MoreTableViewCell)
            
        }
        cell?.cellName.text = settings[indexPath.row]
        cell?.selectionStyle = .none
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0
        {
            //performSegue(withIdentifier:Identifiers.ShowProfileIdentifier.rawValue, sender:nil)
            guard let url = URL(string:  "https://hip2save.com/profile/") else { return }
            UIApplication.shared.open(url)
        }
        else
        {
            performSegue(withIdentifier:Identifiers.ChangePasswordNavigation.rawValue, sender:nil)
            
        }
        
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
