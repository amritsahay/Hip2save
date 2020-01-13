//
//  DIYDetailViewController.swift
//  Hip2Save
//
//  Created by ip-d on 12/02/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DIYDetailViewController: UIViewController {
    
    var deals:[[String:[JSON]]] = []
    var tbAccessoryView : UIToolbar?
    var current_page:Int = 1
    var found_posts:Int = 0
    var max_num_pages:Int = 0
    var batch_size:Int = 20
    var drytitle:String = ""
    var category_id:Int?
    
    lazy var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var loaderActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var dealListView: UITableView! { didSet {
        self.dealListView.register(UINib.init(nibName:"DealsTableViewCell", bundle:nil), forCellReuseIdentifier: "DealsTableViewCell")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUI()
        loadMoreItems()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setNotification()
        self.title = (drytitle ?? "")
        //current_page = 1
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "DIYDetailViewController")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        removeNotification()
    }
    // MARK:- Other Methods
    
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
        deals.removeAll()
        let attributedText = NSMutableAttributedString.init(string:"Pull to refresh", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        refreshControl.attributedTitle = attributedText
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        dealListView.addSubview(refreshControl) // not required when using UITableViewController
        NotificationCenter.default.addObserver(self, selector: #selector(self.userDidChangeNotification(notification:)), name:Constants.notifyUserDidChange, object: nil)
    }
    
    func setNotification()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(self.dealCellDidChangeNotification(notification:)), name:Constants.notifyDealCellDidChange, object: nil)
        
    }
    
    func removeNotification()
    {
        NotificationCenter.default.removeObserver(self, name:Constants.notifyDealCellDidChange, object: nil)
        //NotificationCenter.default.removeObserver(self, name:Constants.notifyUserDidChange, object: nil)
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
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        refreshControl.endRefreshing()
        deals.removeAll()
        current_page = 1
        dealListView.reloadData()
        loadMoreItems()
    }
    
    @objc func searchAction()
    {
        if searchBarHeight.constant > 0
        {
            configureBarItems(enableCancel:false)
            self.searchBarHeight.constant = 0
            searchBar.resignFirstResponder()
            deals.removeAll()
            dealListView.reloadData()
            current_page = 1
            loadMoreItems()
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
    
    
    func createParam() -> Parameters
    {
        var parameters:Parameters = [:]
        
        
        if searchBarHeight.constant > 0
        {
            parameters = [Key.option.rawValue:Key.deal_search.rawValue,Key.current_page.rawValue:current_page,Key.posts_per_page.rawValue:batch_size,Key.keyword.rawValue:searchBar.text!,Key.category_id.rawValue: category_id!]
        }
        else
        {
            parameters = [Key.option.rawValue:Key.get_posts.rawValue,Key.current_page.rawValue:current_page,Key.posts_per_page.rawValue:batch_size,Key.category_id.rawValue: category_id!]
        }
        
        return  parameters
    }
    
    func loadMoreItems()
    {
        loaderActivityIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let parameters = createParam()
        
        var headers:HTTPHeaders? = nil
        let token = AppDelegate.shared.getEncryptionToken()
        
        if  token != ""
        {
            headers = ["x-access-cookie":token]
        }
        
        let url = Constants.baseURL
        Alamofire.request(url, method: .post, parameters: parameters, encoding:URLEncoding.default, headers: headers).validate().responseString { (response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
                    self.current_page += 1
                    self.handle(items:items!)
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
    
    
    func handle(items:[JSON])
    {
        let headerFormatter = DateFormatter.init()
        headerFormatter.dateStyle = .medium
        headerFormatter.timeStyle = .none
        headerFormatter.doesRelativeDateFormatting  = false
        var value = filterArrayWithDate(items:items, key:"post_date", formatter:headerFormatter)
        if value.count > 0 && deals.count > 0
        {
            appendResponse(items:&value)
        }
        else
        {
            deals = value
        }
        dealListView.reloadData()
    }
    
    func appendResponse(items:inout [[String:[JSON]]])
    {
        let last = deals.last
        if last?.keys.first == items.first?.keys.first
        {
            var arr = deals.last?.values.first
            arr = (deals.last?.values.first)! + (items.first?.values.first)!
            deals[deals.count - 1][(last?.keys.first)!] = arr
            items.remove(at:0)
        }
        else
        {
            deals = deals + items
        }
    }
    
    func filterArrayWithDate(items:[JSON],key:String,formatter:DateFormatter?) -> [[String:[JSON]]]
    {
        var uniqueSectionKeys:[String] = []
        var compoundArray:[[String:[JSON]]] = []
        
        for item in items
        {
            var keyValue = item[key].string
            let date = Utility.shared.convertServerTime(serverDate:keyValue!)
            if date != nil && formatter != nil
            {
                keyValue = formatter?.string(from:date!)
            }
            if keyValue != nil && !uniqueSectionKeys.contains(keyValue!)
            {
                uniqueSectionKeys.append(keyValue!)
                var values:[JSON] = []
                values.append(item)
                var sectionDict:[String:[JSON]] = [:]
                sectionDict[keyValue!] = values
                compoundArray.append(sectionDict)
            }
            else if keyValue != nil
            {
                let index = uniqueSectionKeys.lastIndex(of:keyValue!)
                compoundArray[index!][keyValue!]?.append(item)
            }
        }
        return compoundArray
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
    
    @objc func dealCellDidChangeNotification(notification: Notification) {
        let indexPath:IndexPath! = notification.userInfo!["indexPath"] as? IndexPath
        if indexPath != nil
        {
            deals[indexPath.section][deals[indexPath.section].keys.first!]![indexPath.row]["wishlist_value"].bool = !deals[indexPath.section][deals[indexPath.section].keys.first!]![indexPath.row]["wishlist_value"].bool!
            dealListView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    @objc func userDidChangeNotification(notification: Notification) {
        deals.removeAll()
        dealListView.reloadData()
        current_page = 1
        loadMoreItems()
    }
}

extension DIYDetailViewController:UITableViewDelegate,UITableViewDataSource
{
    // MARK:- TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        if deals.count == 0
        {
           // tableView.setEmptyView(title:"There are no DIY deals found.", message: "Please swipe down to refresh.")
        }
        else
        {
            tableView.restore()
        }
        return deals.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return deals[section].values.first!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var  cell = tableView.dequeueReusableCell(withIdentifier:"DealsTableViewCell", for: indexPath) as? DealsTableViewCell
        
        if cell == nil
        {
            let nibArray:NSArray = Bundle.main.loadNibNamed("DealsTableViewCell", owner: nil, options: nil )! as NSArray
            cell = (nibArray.object(at: 0) as! DealsTableViewCell)
            
        }
        
        cell?.configureCell(post:&deals[indexPath.section][deals[indexPath.section].keys.first!]![indexPath.row])
        cell?.controller = self
        cell?.indexPath = indexPath
        let totalSection = deals.count
        let totalItems = deals[indexPath.section].values.first!.count
        
        if indexPath.section == totalSection - 1 && indexPath.row == totalItems - 1 && current_page <= max_num_pages && loaderActivityIndicator.isAnimating == false
        {
            loadMoreItems()
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = DealTableViewSection()
        header.title.text
            = deals[section].keys.first
        return  header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        performSegue(withIdentifier: Identifiers.DetailViewIdentifier.rawValue, sender:deals[indexPath.section][deals[indexPath.section].keys.first!]![indexPath.row])
    }
}

extension DIYDetailViewController:UISearchBarDelegate
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
        deals.removeAll()
        dealListView.reloadData()
        current_page = 1
        loadMoreItems()
        searchBar.resignFirstResponder()
    }
}
