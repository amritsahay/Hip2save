//
//  BorderView.swift
//  Write Off Rocket
//
//  Created by ip-d on 22/08/18.
//  Copyright © 2018 Esferasoft Solutions. All rights reserved.
//

import UIKit

class BorderView: UIView {

    @IBInspectable var Color:UIColor = UIColor.white
    @IBInspectable var cornerEdge:CGFloat = 0
    @IBInspectable var witdh:CGFloat = 0
    @IBInspectable var isRounded:Bool = false
    
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.layer.borderColor = Color.cgColor
        self.layer.borderWidth = witdh
        if isRounded
        {
            self.layer.cornerRadius = self.bounds.size.height/2
        }
        else
        {
            self.layer.cornerRadius = cornerEdge
        }
        self.layer.masksToBounds = true
    }


}
