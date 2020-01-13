//
//  ReplyViewCell.swift
//  Hip2Save
//
//  Created by ip-d on 19/02/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import UIKit
import ActiveLabel

protocol TableViewButton{
    func OnClick(index: Int)
}

class ReplyViewCell: UITableViewCell {
    @IBOutlet weak var replybtn: UIButton!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var rplyorplybtn: UIButton!
    @IBOutlet weak var message: ActiveLabel!
    @IBOutlet weak var rplyimg: UIImageView!
    @IBOutlet weak var rplyspace: NSLayoutConstraint!
    @IBOutlet weak var adminHeight: NSLayoutConstraint!
    var celldeligate: TableViewButton?
    var index: IndexPath?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.message.enabledTypes = [.url]
        self.message.handleURLTap{ URL in
            print("url\(URL)")
            UIApplication.shared.open(URL)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    
    }
    @IBAction func selectcard(_ sender: Any) {
        celldeligate?.OnClick(index: (index!.row))
    }
    
}
