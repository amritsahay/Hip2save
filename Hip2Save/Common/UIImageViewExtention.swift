//
//  UIImageViewExtention.swift
//  Inventory System
//
//  Created by ip-d on 31/05/18.
//  Copyright © 2018 Esferasoft Solutions. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

class UIImageViewExtention: NSObject {
    
}

private var activityIndicatorAssociationKey: UInt8 = 0

extension UIImageView {
    var activityIndicator: UIActivityIndicatorView! {
        get {
            return objc_getAssociatedObject(self, &activityIndicatorAssociationKey) as? UIActivityIndicatorView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &activityIndicatorAssociationKey, newValue, objc_AssociationPolicy(rawValue: UInt((objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC).rawValue))!)
        }
    }
    
    func showActivityIndicator() {
        
        if (self.activityIndicator == nil) {
            self.activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
            
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.frame = CGRect.init(x:0, y: 0, width: 40, height: 40)
            self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
            self.activityIndicator.center = CGPoint.init(x: self.frame.size.width/2, y: self.frame.height/2)
            self.activityIndicator.autoresizingMask = [.flexibleLeftMargin,.flexibleRightMargin,.flexibleTopMargin,.flexibleBottomMargin]
            self.activityIndicator.isUserInteractionEnabled = false
            
            OperationQueue.main.addOperation({ () -> Void in
                self.addSubview(self.activityIndicator)
                self.activityIndicator.startAnimating()
            })
        }
        else
        {
            OperationQueue.main.addOperation({ () -> Void in
                self.addSubview(self.activityIndicator)
                self.activityIndicator.startAnimating()
            })
        }
        
    }
    
    
    func hideActivityIndicator() {
        if (self.activityIndicator == nil) {
            return
        }
        OperationQueue.main.addOperation({ () -> Void in
            self.activityIndicator.stopAnimating()
        })
    }
}
