//
//  Hip2ShareViewController.swift
//  Hip2Save
//
//  Created by ip-d on 18/12/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class Hip2ShareViewController: UIViewController {
    
    var tbAccessoryView : UIToolbar?
    var shares:[JSON] = []
    var current_page:Int = 1
    var found_posts:Int = 0
    var max_num_pages:Int = 0
    var batch_size:Int = 20
    
    @IBOutlet weak var loginView: UIView!
    lazy var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var loaderActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var shareListView: UITableView! { didSet {
        let header = Hip2ShareView()
        header.controller = self
        self.shareListView.tableHeaderView = header
        self.shareListView.tableHeaderView?.frame.size.height = 70
        self.shareListView.register(UINib.init(nibName:"Hip2ShareCell", bundle:nil), forCellReuseIdentifier: "Hip2ShareCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUI()
        StoreReviewHelper.checkAndAskForReview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if AppDelegate.shared.currentUser == nil
        {
            loginView.isHidden = false
        }
        else
        {
            shares.removeAll()
            current_page = 1
            Utility.shared.startProgress(message:"")
            loadHip2Share()
            shareListView.reloadData()
            loginView.isHidden = true
        }
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "Hip2ShareViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    @IBAction func menu(_ sender: Any) {
        AppDelegate.shared.openDrawer()
    }
    
    @IBAction func login(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:Identifiers.LoginViewController.rawValue)
        self.present(vc!, animated:true, completion: nil)
    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        refreshControl.endRefreshing()
        shares.removeAll()
        current_page = 1
        shareListView.reloadData()
        loadHip2Share()
    }
    
    @objc func userDidChangeNotification(notification: Notification) {
    //    shares.removeAll()
//        shareListView.reloadData()
//        current_page = 1
//        loadHip2Share()
    }
    
    func setUI()
    {
        /* searchBar.delegate = self
         configureSearchBar(searchBar:searchBar)
         configureBarItems(enableCancel: false)
         self.navigationItem.rightBarButtonItems = nil */
       /* let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        let logo = UIImage(named: "hip2save_main")
        logoImage.image = logo
        self.navigationItem.titleView = logoImage */
        
        shares.removeAll()
        
        let attributedText = NSMutableAttributedString.init(string:"Pull to refresh", attributes: [NSAttributedString.Key.foregroundColor:UIColor.gray])
        refreshControl.attributedTitle = attributedText
        refreshControl.tintColor = .gray
        
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        shareListView.addSubview(refreshControl) // not required when using UITableViewController
        NotificationCenter.default.addObserver(self, selector: #selector(self.userDidChangeNotification(notification:)), name:Constants.notifyUserDidChange, object: nil)
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
            self.searchBar.resignFirstResponder()
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
    
    func loadHip2Share()
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        loaderActivityIndicator.startAnimating()
        
        let url = Constants.baseURL
        
        var headers:HTTPHeaders? = nil
        let token = AppDelegate.shared.getEncryptionToken()
        
        if  token != ""
        {
            headers = ["x-access-cookie":token]
        }
        
        let parameters:Parameters = [Key.option.rawValue:API.hip2share_posts.rawValue,Key.posts_per_page.rawValue:batch_size,Key.current_page.rawValue:current_page]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding:URLEncoding.default, headers: headers).validate().responseString { (response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            Utility.shared.stopProgress()
            self.loaderActivityIndicator.stopAnimating()
            switch response.result {
            case .success:
                
                print("Validation Successful")
                let jsonString = response.value?.replacingOccurrences(of:"mu-plugins/query-monitor/wp-content/db.php", with:"")
                let json = JSON.init(parseJSON:jsonString ?? "{}")
                let response = json.dictionary
                let status = response?["status"]?.stringValue
                if status == "ok"
                {
                    let items = response?["result"]?["items"].arrayValue
                    let page_detail = response?["result"]?["page_detail"].dictionaryValue
                    self.max_num_pages = page_detail?["max_num_pages"]?.intValue ?? 0
                    if (items?.count)! > 0
                    {
                        self.current_page += 1
                        self.shares = self.shares + items!
                        self.shareListView.reloadData()
                    }
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
        if segue.identifier == Identifiers.DetailViewIdentifier.rawValue
        {
            let navigation = segue.destination as! UINavigationController
            let destination = navigation.visibleViewController as! DealDetailViewController
            destination.item = sender as? JSON
        }
    }
}
extension Hip2ShareViewController:UITableViewDelegate,UITableViewDataSource
{
    // MARK:- TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shares.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var  cell = tableView.dequeueReusableCell(withIdentifier:"Hip2ShareCell", for: indexPath) as? Hip2ShareCell
        
        if cell == nil
        {
            let nibArray:NSArray = Bundle.main.loadNibNamed("Hip2ShareCell", owner: nil, options: nil )! as NSArray
            cell = (nibArray.object(at: 0) as! Hip2ShareCell)
            
        }
        
        cell?.configCell(hip2share:shares[indexPath.row])
        
        if indexPath.row == shares.count - 1 && current_page <= max_num_pages && loaderActivityIndicator.isAnimating == false
        {
            loadHip2Share()
            
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var shareJSON = shares[indexPath.row]
        shareJSON["type"] = "hip2share"
        performSegue(withIdentifier: Identifiers.DetailViewIdentifier.rawValue, sender:shareJSON)
    }
    
    // MARK:- TableView Delegate
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect.init(x: CGFloat.leastNormalMagnitude, y: CGFloat.leastNormalMagnitude, width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude))
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
}
extension Hip2ShareViewController:UISearchBarDelegate
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
    
   
    @objc func doBtnSubmit() {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchText \(searchBar.text)")
        shares.removeAll()
        shareListView.reloadData()
        current_page = 1
        loadHip2Share()
        searchBar.resignFirstResponder()
    }
}
