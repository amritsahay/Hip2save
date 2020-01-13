//
//  CommentsViewController.swift
//  Hip2Save
//
//  Created by ip-d on 19/02/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SWXMLHash
import SwiftyXMLParser
import XMLMapper

class CommentsViewController: UIViewController {
    
    var comments:[JSON] = []
    var rplyorply:[JSON] = []
    var subcomment:[JSON] = []
    var replyComments:NSMutableDictionary = [:]
    var dictComments:NSMutableDictionary = [:]
    var rply:Bool = true
    var rplyidf:String = ""
    var current_page:Int = 0
    var found_posts:Int = 0
    var max_num_pages:Int = 0
    var batch_size:Int = 10
    var commentIndex = 0
    var replyindex = 0
    var rpljson:[JSON] = []
    var comm:Bool = false
    var rowNumber:Int = 0
    var replyofreply:Bool = false
    var rplyid:String = ""
    var spacecount:Int = 0
    lazy var refreshControl = UIRefreshControl()
    @IBOutlet weak var nocommentlabel: UILabel!
    @IBOutlet weak var loaderActivityIndicator: UIActivityIndicatorView!
    
    var post:JSON? = nil
    @IBOutlet weak var comments_list: UITableView!{ didSet {
        self.comments_list.register(UINib.init(nibName:"ReplyViewCell", bundle:nil), forCellReuseIdentifier: "ReplyViewCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUI()
        comments.removeAll()
        replyComments.removeAllObjects()
        current_page    = 0
        found_posts     = 0
        max_num_pages   = 0
        batch_size      = 10
        commentIndex    = 0
        
        nocommentlabel.isHidden = true
        let attributedText = NSMutableAttributedString.init(string:"Pull to Close", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        refreshControl.attributedTitle = attributedText
        refreshControl.tintColor = .white
        
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        comments_list.addSubview(refreshControl)
      

    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        refreshControl.endRefreshing()
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nocommentlabel.isHidden = true
        comments.removeAll()
        dictComments.removeAllObjects()
        subcomment.removeAll()
        loadComments()
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "CommentsViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
        Utility.shared.stopProgress()
       
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
    
    @IBAction func reply(_ sender: Any) {
        performSegue(withIdentifier:Identifiers.postCommentIdentifier.rawValue, sender:false)
    }
    
    func setUI()
    {
        
        comments_list.sectionHeaderHeight = UITableView.automaticDimension;
        comments_list.estimatedSectionHeaderHeight = 25;
     /*   let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        let logo = UIImage(named: "hip2save_main")
        logoImage.image = logo
        self.navigationItem.titleView = logoImage */
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == Identifiers.postCommentIdentifier.rawValue
        {
            let navigation = segue.destination as! UINavigationController
            let controller = navigation.viewControllers.last as! PostViewController
            
            
            let isReply = sender as! Bool
            if isReply
            {
                    controller.isReply = isReply
                    controller.postID = "\(post!["ID"].int!)"
                    let commentID = comments[commentIndex]["commentID"].stringValue
                    controller.parentID = "\(commentID)"
                
            }
            else
            {
                
                controller.isReply = isReply
                controller.postID = "\(post!["ID"].int!)"
                
            }
            loaderActivityIndicator.stopAnimating()
        }
    }
    
    func loadComments()
    {
        loaderActivityIndicator.isHidden = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        loaderActivityIndicator.startAnimating()
        let link = post!["link"].stringValue
        //let url = Constants.baseURL
        let url = link + "feed"
       // let post_id = "\(post!["ID"].int!)"
        
        var parameters:Parameters? = nil
//        parameters = [Key.option.rawValue:API.get_comments.rawValue,Key.comments_per_page.rawValue:batch_size,Key.current_page.rawValue:current_page,Key.post_id.rawValue:post_id]
     
        var headers:HTTPHeaders? = nil
        let token = AppDelegate.shared.getEncryptionToken()
        if  token != ""
        {
            headers = ["x-access-cookie":token]
        }
        
        Alamofire.request(url, method: .get).responseData { (response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            Utility.shared.stopProgress()
            if let data =  response.data {
                //let xml = SWXMLHash.config{config in config.shouldProcessLazily = true}.parse(data)
                
                let xml = SWXMLHash.config {
                    config in
                    config.shouldProcessNamespaces = true
                    config.encoding = String.Encoding.utf8
                    }.parse(data)
                print(xml)
                for elem in xml["rss"]["channel"]["item"].all{
                    var json = ["title":"","link":"","creator":"","pubDate":"","description":"","encoded":"","commentID":"","commentParent":"","commentAdmin":"","height":"0","sortdate":""]
                    
                    json["title"] = elem["title"].element?.text
                    json["link"] = elem["link"].element?.text
                    json["creator"] = elem["creator"].element?.text
                   // json["pubDate"] = elem["pubDate"].element?.text
                    json["description"] = elem["description"].element?.text
                    json["encoded"] = elem["encoded"].element?.text
                    json["commentID"] = elem["commentID"].element?.text
                    json["commentParent"] = elem["commentParent"].element?.text
                    json["commentAdmin"] = elem["commentAdmin"].element?.text
                    let pubDate = Utility.shared.convertcommentTime(serverDate:elem["pubDate"].element!.text)
                    let formatter = DateFormatter.init()
                    formatter.dateStyle = .short
                    formatter.timeStyle = .short
                    formatter.doesRelativeDateFormatting  = false
                    json["pubDate"] = formatter.string(from:pubDate!)
                    let date = Utility.shared.convertcommentTime(serverDate:elem["pubDate"].element!.text)
                    let headerFormatter = DateFormatter()
                    headerFormatter.dateFormat = "yyyyMMddHHmmss"
                    json["sortdate"] = headerFormatter.string(from:date!)
             
                    if elem["commentParent"].element?.text == "0"{
                        self.comments.append(JSON(json))
                    }else{
                         //self.dictComments.addEntries(from: [elem["commentID"].element!.text: json])
                        self.subcomment.append(JSON(json))
                        self.dictComments.setValue(json, forKey: elem["commentParent"].element!.text)
                       
                    }
                }
                self.comments = self.comments.sorted(by: { ($0["sortdate"]) < ($1["sortdate"])})
//                self.comments = self.comments
//                    .sorted { $0["sortdate"] < $1["sortdate"] }
                self.subcomment = self.subcomment
                    .sorted(by: { ($0["sortdate"]) < ($1["sortdate"])})
                if (self.comments.count) > 0{
//                    self.max_num_pages += 1
//                    self.current_page =  self.current_page + 1
                    self.insertrply()
                    
                    self.comm = true
                }else{
                    Utility.shared.showSnackBarMessage(message:("No Comments"))
                    if !self.comm{
                            self.nocommentlabel.isHidden = false
                    }

                }
                self.loaderActivityIndicator.isHidden = true
            }
        }
    }
    func siftarray(data:JSON,index:Int) {
        let count = self.comments.count
        self.comments.append(JSON())
        for i in (0...count).reversed(){
            if i == index{
                self.comments[i] = data
                break
            }else{
                self.comments[i] = self.comments[i-1]
            }
            
        }
        
    }
    func comp(value:String,index:Int){
    var val = JSON()
    let count = self.comments.count
    var indx = 0
    var check = false
    for j in 0..<count{
        if value == self.comments[j]["commentID"].stringValue{
         val = self.subcomment[index]
         indx = j
         check = true
        }
    }
    
    //  self.comments[j+1] = self.subcomment[i]
        if check{
             self.siftarray(data: val, index: indx+1)
        }
   
    }
    func insertrply(){
        for i in 0..<self.subcomment.count{
            let count = self.comments.count
            let id = self.subcomment[i]["commentParent"].stringValue
            comp(value: id,index: i)
        }
        for i in 0..<self.comments.count{
            if comments[i]["commentParent"] == "0"{
                self.spacecount = 0
                comments[i]["height"].stringValue = String(self.spacecount)
            }else{
                self.spacecount = self.spacecount + 10
                comments[i]["height"].stringValue = String(self.spacecount)
            }
            
        }
        self.comments_list.reloadData()
    }
    
}

extension CommentsViewController:UITableViewDelegate,UITableViewDataSource
{
    // MARK:- TableView DataSource
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
   
        return comments.count
        
    }
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var  cell = tableView.dequeueReusableCell(withIdentifier:"ReplyViewCell", for: indexPath) as? ReplyViewCell
        cell?.username.text = comments[indexPath.row]["creator"].string

        cell?.timestamp.text = comments[indexPath.row]["pubDate"].stringValue
        //cell?.replybtn.addTarget(self, action:  #selector(ReplyofReply), for: .touchUpInside)
        let msg = comments[indexPath.row]["encoded"].string
        let rp = msg?.convertHtml()
        cell?.message.text = rp
        let sp = Int(comments[indexPath.row]["height"].stringValue)
        cell?.rplyspace.constant = CGFloat(sp!)
        cell?.adminHeight.constant = 0
        if comments[indexPath.row]["commentAdmin"].boolValue
        {
            cell?.adminHeight.constant = 8
        }
        else
        {
            cell?.adminHeight.constant = 0
        }
        let comment_childs = comments[indexPath.row]["comment_childs"].intValue
     
        self.rplyid = comments[indexPath.row]["commentParent"].stringValue
        cell?.rplyorplybtn.setTitle("View \(comment_childs ?? 0) replies", for:.normal)
       // cell?.rplyorplybtn.addTarget(self, action: #selector(viewReply), for: .touchUpInside)
        cell?.celldeligate = self
        cell?.index = indexPath
        //paging(section:indexPath.section)
       
        return cell!
    }
    
    

    @objc func viewReply(button:UIButton) {
        let ids = rplyorply[button.tag]["comment_ID"].stringValue
        let curntparent = rplyorply[button.tag]["comment_parent"].stringValue
        let replies:[JSON]? = replyComments.value(forKey: curntparent) as? [JSON]
      //  loadReplyofReply(parentID: ids,crntprnt:curntparent,buttontag: button.tag)
    }
    
    @objc func commentReply(button:UIButton) {
        commentIndex = button.tag
        performSegue(withIdentifier:Identifiers.postCommentIdentifier.rawValue, sender:true)
    }
    @objc func ReplyofReply(button:UIButton) {
        commentIndex = button.tag
        replyindex = button.tag
        self.replyofreply = true
        performSegue(withIdentifier:Identifiers.postCommentIdentifier.rawValue, sender:true)
    }
    
    func paging(section:Int)
    {
        let totalSection:Int = comments.count
        if section == totalSection - 1  && current_page <= max_num_pages + 1
        {
            loadComments()
        }
    }
}

extension CommentsViewController:TableViewButton{
    func OnClick(index: Int) {
        commentIndex = index
        replyindex = index
        self.replyofreply = true
        performSegue(withIdentifier:Identifiers.postCommentIdentifier.rawValue, sender:true)
    }
    
}
