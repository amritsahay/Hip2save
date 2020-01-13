//
//  StoreReviewHelper.swift
//  Hip2Save
//
//  Created by Shashwat B on 14/10/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import Foundation
import StoreKit

struct StoreReviewHelper {
    static func incrementAppOpenedCount() { // called from appdelegate didfinishLaunchingWithOptions:
        guard var appOpenCount = UserDefaults.standard.value(forKey: UserDefaultsKeys.APP_OPENED_COUNT) as? Int else {
            UserDefaults.standard.set(51, forKey: UserDefaultsKeys.APP_OPENED_COUNT)
            return
        }
        appOpenCount += 1
        UserDefaults.standard.set(appOpenCount, forKey: UserDefaultsKeys.APP_OPENED_COUNT)
    }
    static func checkAndAskForReview() { // call this whenever appropriate
        // this will not be shown everytime. Apple has some internal logic on how to show this.
        guard var appOpenCount = UserDefaults.standard.value(forKey: UserDefaultsKeys.APP_OPENED_COUNT) as? Int else {
            UserDefaults.standard.set(1, forKey: UserDefaultsKeys.APP_OPENED_COUNT)
            return
        }
         print(appOpenCount)
        switch appOpenCount {
        case  _ where appOpenCount > 50:
            StoreReviewHelper().requestReview()
            UserDefaults.standard.set(0, forKey: UserDefaultsKeys.APP_OPENED_COUNT)
        default:
            print("App run count is : \(appOpenCount)")
            break;
        }
        
    }
    fileprivate func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
            // Try any other 3rd party or manual method here.
        }
    }
}
