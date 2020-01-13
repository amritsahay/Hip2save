//
//  MoreTableViewCell.swift
//  Hip2Save
//
//  Created by ip-d on 24/12/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit

class MoreTableViewCell: UITableViewCell {

    @IBOutlet weak var cellName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showDisclosure()
    {
        self.accessoryType = .disclosureIndicator
    }
    
}
