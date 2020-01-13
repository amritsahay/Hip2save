//
//  StoresViewControllers.swift
//  Hip2Save
//
//  Created by ip-d on 22/11/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class StoresViewControllers: UIViewController {
    var tbAccessoryView : UIToolbar?
    
    var stores:[JSON] = []
    var holdStores:[JSON] = []
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    @IBOutlet weak var storesListView: UITableView! { didSet {
        self.storesListView.register(UINib.init(nibName:"StoreTableViewCell", bundle:nil), forCellReuseIdentifier: "StoreTableViewCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "StoresViewControllers")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func setUI()
    {
       /* let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        let logo = UIImage(named: "hip2save_main")
        logoImage.image = logo
        self.navigationItem.titleView = logoImage */
        
        searchBar.delegate = self
        configureSearchBar(searchBar:searchBar)
        configureBarItems(enableCancel: false)
        loadStore()
    }
    
    @IBAction func menu(_ sender: Any) {
        AppDelegate.shared.openDrawer()
    }
    
    func configureBarItems(enableCancel:Bool)
    {
        self.navigationItem.rightBarButtonItems = nil
        if enableCancel
        {
            let cancelItem = UIBarButtonItem.init(barButtonSystemItem: .stop, target:self, action: #selector(searchAction))
            cancelItem.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItems = [cancelItem]
            
        }
        else
        {
            let searchItem = UIBarButtonItem.init(barButtonSystemItem: .search, target:self, action: #selector(searchAction))
            searchItem.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItems = [searchItem]
        }
        
    }
    
    @objc func searchAction()
    {
        if searchBarHeight.constant > 0
        {
            configureBarItems(enableCancel:false)
            self.searchBarHeight.constant = 0
            searchBar.resignFirstResponder()
        }
        else
        {
            configureBarItems(enableCancel:true)
            self.searchBarHeight.constant = 56
            self.searchBar.becomeFirstResponder()
            self.searchBar.backgroundColor = .white
            
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
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
                    self.holdStores = self .stores
                    self.storesListView.reloadData()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == Identifiers.StorePostViewController.rawValue
        {
            let navigation = segue.destination as! UINavigationController
            let destination = navigation.visibleViewController as! StorePostViewController
            let array = sender as? [Any]
            destination.store_id = array![0] as? Int
            destination.storeName = (array![1] as? String)!
        }
    }
}

extension StoresViewControllers:UITableViewDelegate,UITableViewDataSource
{
    // MARK:- TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stores.count == 0
        {
            //tableView.setEmptyView(title:"There are no stores found.", message: "")
        }
        else
        {
            tableView.restore()
        }
        return stores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var  cell = tableView.dequeueReusableCell(withIdentifier:"StoreTableViewCell", for: indexPath) as? StoreTableViewCell
        
        if cell == nil
        {
            let nibArray:NSArray = Bundle.main.loadNibNamed("StoreTableViewCell", owner: nil, options: nil )! as NSArray
            cell = (nibArray.object(at: 0) as! StoreTableViewCell)
            
        }
        
        cell?.selectionStyle = .none
        cell?.storeName.text = stores[indexPath.row]["store_title"].string?.convertHtml()
        
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
        let storeID = stores[indexPath.row]["store_id"].intValue
        let storeName = stores[indexPath.row]["store_title"].string?.convertHtml()
        performSegue(withIdentifier: Identifiers.StorePostViewController.rawValue, sender:[storeID,storeName])
    }
    
}

extension StoresViewControllers:UISearchBarDelegate
{
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if tbAccessoryView == nil {
            
            tbAccessoryView = UIToolbar.init(frame:
                
                CGRect.init(x: 0, y: 0,
                            
                            width: self.view.frame.size.width, height: 44))
            
            let bbiSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            
                                            target: nil, action: nil)
            
            let bbiSubmit = UIBarButtonItem.init(title: "Done", style: .plain,
                                                 
                                                 target: self, action: #selector(doBtnSubmit))
            
            tbAccessoryView?.items = [bbiSpacer, bbiSubmit]
            
        }
        
        // set the tool bar as this text field's input accessory view
        searchBar.inputAccessoryView = tbAccessoryView
        
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filter(text: searchText)
    }
    
    @objc func doBtnSubmit() {
        searchBar.resignFirstResponder()
    }
    
    func filter(text:String)
    {
        if text == ""
        {
            stores = holdStores
        }
        else
        {
            let filteredItems = holdStores.filter { $0["store_title"].string!.contains(text)}
            stores = filteredItems
        }
        
        storesListView.reloadData()
    }
}
