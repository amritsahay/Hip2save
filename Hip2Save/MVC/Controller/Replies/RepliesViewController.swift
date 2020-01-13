//
//  RepliesViewController.swift
//  Hip2Save
//
//  Created by Shashwat B on 21/09/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import ActiveLabel

class RepliesViewController: UIViewController {
    @IBOutlet weak var nocommentlabel: UILabel!
    @IBOutlet weak var labelname: UILabel!
    @IBOutlet weak var labeltime: UILabel!
    @IBOutlet weak var labelmsg: ActiveLabel!
    @IBOutlet weak var loaderActivityIndicator: UIActivityIndicatorView!
    var comments:[JSON] = []
    var buttontag: Int = 0
    var reply: [JSON] = []
    var crntrplyid:String = ""
     var replyComments:NSMutableDictionary = [:]
    @IBOutlet weak var comments_list: UITableView!{ didSet {
        self.comments_list.register(UINib.init(nibName:"ReplyViewCell", bundle:nil), forCellReuseIdentifier: "ReplyViewCell")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "RepliesViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
        let replies:[JSON]? = replyComments.value(forKey: crntrplyid) as? [JSON]
        
        labelname.text = replies![buttontag]["comment_author"].stringValue
        
        labelmsg.text  = replies![buttontag]["comment_content"].stringValue
        let date = Utility.shared.convertServerTime(serverDate:replies![buttontag]["comment_date"].stringValue)
        
        let headerFormatter = DateFormatter.init()
        headerFormatter.dateStyle = .short
        headerFormatter.timeStyle = .short
        headerFormatter.doesRelativeDateFormatting  = false
        labeltime.text = headerFormatter.string(from:date!)
    }
    
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
   
   
}
extension RepliesViewController: UITableViewDelegate, UITableViewDataSource{
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return reply.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier:"ReplyViewCell", for: indexPath) as? ReplyViewCell
        
//        if cell == nil
//        {
//            let nibArray:NSArray = Bundle.main.loadNibNamed("ReplyViewCell", owner: nil, options: nil )! as NSArray
//            cell = (nibArray.object(at: 0) as! ReplyViewCell)
//
//        }
        
       
        cell?.username.text = reply[indexPath.row]["comment_author"].string
        
        let date = Utility.shared.convertServerTime(serverDate:reply[indexPath.row]["comment_date"].string!)
        
        let headerFormatter = DateFormatter.init()
        headerFormatter.dateStyle = .short
        headerFormatter.timeStyle = .short
        headerFormatter.doesRelativeDateFormatting  = false
        cell?.timestamp.text = headerFormatter.string(from:date!)

        cell?.message.text = reply[indexPath.row]["comment_content"].string
        if reply[indexPath.row]["admin"].boolValue
        {
            cell?.adminHeight.constant = 8
        }
        else
        {
            cell?.adminHeight.constant = 0
        }
        cell?.rplyorplybtn.isHidden = true
        cell?.replybtn.isHidden = true
        cell?.rplyimg.isHidden = true
        
        return cell!
    }
    

}
