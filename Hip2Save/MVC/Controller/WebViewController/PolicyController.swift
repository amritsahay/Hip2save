//
//  PolicyController.swift
//  Hip2Save
//
//  Created by ip-d on 23/04/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import UIKit
import WebKit
class PolicyController: UIViewController {

    @IBOutlet weak var webkit: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let path = Bundle.main.path(forResource:"disclosure", ofType:"html")
        {
            let url = URL.init(fileURLWithPath:path)
            let request = URLRequest.init(url:url)
            webkit.load(request)
        }
        
        /*let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        let logo = UIImage(named: "hip2save_main")
        logoImage.image = logo
        self.navigationItem.titleView = logoImage */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "PolicyController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
