//
//  CommentsViews.swift
//  Hip2Save
//
//  Created by ip-d on 19/02/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import UIKit
import ActiveLabel

class CommentsViews: UIView {
    @IBOutlet weak var messageHeight: NSLayoutConstraint!
    @IBOutlet weak var adminHeight: NSLayoutConstraint!
    @IBOutlet weak var replysHeight: NSLayoutConstraint!
    @IBOutlet weak var viewReply: UIButton!
    @IBOutlet weak var reply: UIButton!
    @IBOutlet weak var message: ActiveLabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var contentView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit()
    {
        Bundle.main.loadNibNamed("CommentsViews", owner: self, options:nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        self.message.enabledTypes = [.url]
        self.message.handleURLTap{ URL in
            print("url\(URL)")
            UIApplication.shared.open(URL)
        }
    }

}
