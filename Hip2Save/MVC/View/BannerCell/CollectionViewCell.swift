//
//  CollectionViewCell.swift
//  Hip2Save
//
//  Created by ip-d on 28/02/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import UIKit
import FSPagerView

class CollectionViewCell: FSPagerViewCell {

    @IBOutlet weak var lTitle: UILabel!
    @IBOutlet weak var banner: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
