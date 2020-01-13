//
//  Hip2ShareView.swift
//  Hip2Save
//
//  Created by ip-d on 18/12/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit

class Hip2ShareView: UIView {
    
    var controller:UIViewController! = nil
    
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
        Bundle.main.loadNibNamed("Hip2ShareView", owner: self, options:nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }
    @IBAction func submit(_ sender: Any) {
        if controller != nil
        {
            let vc = controller.storyboard?.instantiateViewController(withIdentifier:Identifiers.ShareYourDealViewController.rawValue)
            //controller.navigationController?.pushViewController(vc!, animated:true)
            controller.present(vc!, animated: true, completion:nil)
            
        }
    }
    
}
