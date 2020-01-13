//
//  Hip2ShareCell.swift
//  Hip2Save
//
//  Created by ip-d on 18/12/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit
import SwiftyJSON

class Hip2ShareCell: UITableViewCell {

    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var itemPostedBy: UILabel!
    @IBOutlet weak var itemPhoto: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(hip2share:JSON)
    {
        itemTitle.text = hip2share["post_title"].string?.convertHtml()
        itemPostedBy.text = hip2share["user_name"].string
        commentCount.text = hip2share["comment_count"].string
        if let store =  hip2share["store"].array?.last?.string
        {
            storeName.text = store
        }
        else
        {
            storeName.text = "Unknown Store"
        }
        
        
        itemPhoto?.kf.indicatorType = .activity
        let flagPath = hip2share["thumbnail_image"].stringValue
        let flagUrl = URL.init(string:flagPath)
        itemPhoto?.kf.setImage(with: flagUrl, placeholder:UIImage.init(named:"placeholder-image"), options: [.cacheOriginalImage], progressBlock: nil, completionHandler:nil)
       // itemPhoto?.contentMode = .scaleAspectFit
        itemPhoto?.clipsToBounds = true
        
    }
}
