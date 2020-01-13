//
//  StoreTableViewCell.swift
//  Hip2Save
//
//  Created by ip-d on 22/11/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit

class StoreTableViewCell: UITableViewCell {
    
    @IBOutlet weak var storeName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
            self.selectionStyle = .none

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
