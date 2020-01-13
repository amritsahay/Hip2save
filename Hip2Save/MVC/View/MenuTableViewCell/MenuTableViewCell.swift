//
//  MenuTableViewCell.swift
//  Hip2Save
//
//  Created by ip-d on 20/11/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var menuName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
         self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
