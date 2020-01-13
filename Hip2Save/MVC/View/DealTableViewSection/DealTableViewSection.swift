//
//  DealTableViewSection.swift
//  Hip2Save
//
//  Created by ip-d on 20/11/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit

class DealTableViewSection: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var popular: UILabel!
    @IBOutlet weak var title: UILabel!
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
        Bundle.main.loadNibNamed("DealTableViewSection", owner: self, options:nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }

}
