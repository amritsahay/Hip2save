//
//  RoundView.swift
//  Inventory System
//
//  Created by ip-d on 10/05/18.
//  Copyright © 2018 Esferasoft Solutions. All rights reserved.
//

import UIKit

class RoundView: UIView {
    
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.size.width * 0.50
        self.layer.masksToBounds = true
    }
    
    
}
