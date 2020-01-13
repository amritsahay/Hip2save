//
//  PopSegue.swift
//  BTC Bars
//
//  Created by ip-d on 17/08/18.
//  Copyright © 2018 Esferasoft Solutions. All rights reserved.
//

import UIKit

class PopSegue: UIStoryboardSegue {
    override func perform() {
        self.source.navigationController?.popViewController(animated: true)
    }
}
