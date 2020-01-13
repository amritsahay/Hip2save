//
//  CardView.swift
//  Hip2Save
//
//  Created by Shashwat B on 07/11/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//


import Foundation
import UIKit

@IBDesignable
class CardView: UIView {
    @IBInspectable var Color:UIColor = UIColor.lightGray
    @IBInspectable var bgColor:UIColor = UIColor.white
    @IBInspectable var cornerEdge:CGFloat = 15
    @IBInspectable var witdh:CGFloat = 0.5
    @IBInspectable var isRounded:Bool = false
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.backgroundColor = bgColor.cgColor
        self.layer.borderColor = Color.cgColor
        self.layer.borderWidth = witdh
        //self.backgroundColor = bgColor.cgColor
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.7
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
