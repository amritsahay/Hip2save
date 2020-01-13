//
//  DismissSegue.swift
//  Hip2Save
//
//  Created by ip-d on 14/11/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit

class DismissSegue: UIStoryboardSegue {
    override func perform() {
        self.source.dismiss(animated: true,completion:nil)
    }
}
