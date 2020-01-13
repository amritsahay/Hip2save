//
//  CategoryViewController.swift
//  Hip2Save
//
//  Created by ip-d on 11/02/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CategoryViewController: UIViewController {
    var categories:[JSON] = []
    @IBOutlet weak var categoryList: UITableView! { didSet {
        self.categoryList.register(UINib.init(nibName:"MoreTableViewCell", bundle:nil), forCellReuseIdentifier: "MoreTableViewCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loadStore()
       /* let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        let logo = UIImage(named: "hip2save_main")
        logoImage.image = logo
        self.navigationItem.titleView = logoImage */
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "CategoryViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated:true, completion: nil)
    }
    
    func loadStore()
    {
        Utility.shared.startProgress(message:"")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = Constants.baseURL
        
        let parameters:Parameters = [Key.option.rawValue:API.category_list.rawValue]
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding:URLEncoding.default, headers: nil).validate().responseString { (response) in
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
                    self.categories =  (response?["result"]?.arrayValue)!
                    self.categoryList.reloadData()
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == Identifiers.CategoryDetailIdentifier.rawValue
        {
            let categoryDetailVC:CategoryDetailViewController = segue.destination as! CategoryDetailViewController
            
//            let cat_id = sender as? Int
//            categoryDetailVC.category_id = cat_id
            let array = sender as? [Any]
            categoryDetailVC.category_id = array![0] as? Int
            categoryDetailVC.cattitle = (array![1] as? String)!
            
        }
    }
    
    
}

extension CategoryViewController:UITableViewDelegate,UITableViewDataSource
{
    // MARK:- TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categories.count == 0
        {
           // tableView.setEmptyView(title:"There are no categories found.", message: "Please swipe down to refresh.")
        }
        else
        {
            tableView.restore()
        }
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var  cell = tableView.dequeueReusableCell(withIdentifier:"MoreTableViewCell", for: indexPath) as? MoreTableViewCell
        
        if cell == nil
        {
            let nibArray:NSArray = Bundle.main.loadNibNamed("MoreTableViewCell", owner: nil, options: nil )! as NSArray
            cell = (nibArray.object(at: 0) as! MoreTableViewCell)
            
        }
        cell?.accessoryType = .disclosureIndicator
        cell?.cellName.text = categories[indexPath.row]["cat_title"].string?.convertHtml()
        
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
        
        let catID = categories[indexPath.row]["cat_id"].int
        let cattitle = categories[indexPath.row]["cat_title"].string?.convertHtml()
        performSegue(withIdentifier:Identifiers.CategoryDetailIdentifier.rawValue, sender: [catID,cattitle])
    }
}

extension String{
    func convertHtml() -> String{
      
        let data = self.data(using: String.Encoding.unicode)!
        let attrStr = try? NSAttributedString( // do catch
            data: data,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        return attrStr?.string ?? ""
    }
}
