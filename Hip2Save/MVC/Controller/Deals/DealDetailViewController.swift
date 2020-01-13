//
//  DealDetailViewController.swift
//  Hip2Save
//
//  Created by ip-d on 24/01/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
import SafariServices

class DealDetailViewController: UIViewController {
    @IBOutlet weak var webview: UIWebView!
    
    var hasFlag:Bool = false
    var item:JSON? = nil
    var isHip2Share = false
    lazy var refreshControl = UIRefreshControl()
    @IBOutlet weak var comments: BadgeBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        let attributedText = NSMutableAttributedString.init(string:"Pull to Close", attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        refreshControl.attributedTitle = attributedText
        refreshControl.tintColor = .white
        
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        webview.scrollView.addSubview(refreshControl)
        //webview.addSubview(refreshControl)
        // Do any additional setup after loading the view.
        
    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        refreshControl.endRefreshing()
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "DealDetailViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadContent()
    }
    
    func  setUI()
    {
        comments.badgeNumber = Int(item![Key.comment_count.rawValue].stringValue) ?? 0
        if item![Key.post_flag_url.rawValue].string == nil || item![Key.post_flag_url.rawValue].stringValue == ""
        {
            hasFlag = false
        }
        else
        {
            hasFlag = true
        }
        
        let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        let logo = UIImage(named: "hip2save_main")
        logoImage.image = logo
        self.navigationItem.titleView = logoImage
        
    }
    
    func loadContent()
    {
        let html = NSMutableString.init()
        // Open html and head tags
        html.append("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n")
        
        html.append("<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n")
        
        html.append("<head>\n")
        
        html.append("<link href='hip2save.css' rel='stylesheet' type='text/css' media='all'/>")
        
        html.append("<link href=\"https://fonts.googleapis.com/css?family=Open+Sans:300,300i,400,400i,600,600i,700,700i,800,800i&display=swap\" rel=\"stylesheet\">")
        
        html.append("<link href=\"https://fonts.googleapis.com/css?family=Arvo:400,400i,700,700i&display=swap\" rel=\"stylesheet\">")
        
       html.append("<link href=\"https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.9.0/css/all.min.css\" rel=\"stylesheet\">")
        html.append("<style>.accordion.shipping .accordion-item .accordion-title:before{display:none!important;}.accordion.shipping .accordion-item .accordion-title i.down_icon{left:auto;right:0px;background:0 0;height:auto;font-size:16px;font-size:1rem;position:absolute;text-align:center;top:50%;margin-top:-9px}.accordion.shipping .accordion-item .accordion-title.active i.down_icon{transform: rotate(-180deg);}</style>")
        html.append("<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js\"></script>")
        html.append("<script>$(document).ready(function(){$(\".accordion-title\").click(function(){$(this).toggleClass(\"active\"),$(\".accordion-content\").slideToggle()})});</script>")
        
        
        html.append("</head><body>")
        html.append("<div class=\"grid-container\">")
        html.append("<div class=\"grid-x grid-padding-x grid-padding-y align-center\">")
        html.append("<div class=\"cell small-12 large-9\">")
        html.append("<div class=\"single shadow\">")
        html.append("<div class=\"entry-content\">")
        html.append("<div class=\"body-content\">")

        if hasFlag
        {
            html.append("<img src=\"\(item![Key.post_flag_url.rawValue].stringValue)\"  id=\"flagImage\">")
            html.append("<br/>")
        }
        
        // Headline
        let check =  item![Key.post_flag_url.rawValue].stringValue
        if check.contains("expired.png"){
            html.appendFormat("<del><h1>%@</h1></del>",item![Key.post_title.rawValue].stringValue)
        }else{
            html.appendFormat("<h1>%@</h1>",item![Key.post_title.rawValue].stringValue)
        }
        
        
        // Content
        if item?["type"] != nil && item?["type"].stringValue == "hip2share"
        {
            if item!["thumbnail_image"].stringValue != ""
            {
                html.append("<img src=\"\(item!["thumbnail_image"].stringValue)\">")
                html.append("<br/>")
            }
            
        }
        
        html.append(item![Key.post_content.rawValue].stringValue)
        
        if item![Key.shipping_info.rawValue].stringValue != ""
        {
            html.append("<ul class=\"accordion shipping\" data-accordion=\"\" data-allow-all-closed=\"true\" role=\"tablist\" data-m=\"1bz1s1-m\">")
            html.append("<li class=\"accordion-item\" data-accordion-item=\"\">")
            html.append("<a href=\"javascript:void(0);\" class=\"accordion-title\" aria-controls=\"g7b45b-accordion\" role=\"tab\" id=\"g7b45b-accordion-label\" aria-expanded=\"true\" aria-selected=\"true\">")
            html.append("<i class=\"fas fa-truck\"></i><i class=\"fas fa-chevron-down down_icon\"></i>Shipping Info</a>")
            html.append("<div class=\"accordion-content\" data-tab-content=\"\" role=\"tabpanel\" aria-labelledby=\"g7b45b-accordion-label\" aria-hidden=\"true\" id=\"g7b45b-accordion\" style=\"display: none;\">")
            html.append(item![Key.shipping_info.rawValue].stringValue.replacingOccurrences(of:"<h5><strong>Shipping Info</strong></h5>", with:""))
            html.append("</div></li></ul>")
        }
        
        html.append("</div>")
        html.append("</div>")
        html.append("</div>")
        html.append("</div>")
        html.append("</div>")
        html.append("</div>")
        html.append("</body></html>\n")
        
        let url =  URL.init(fileURLWithPath:Bundle.main.bundlePath)
        webview.loadHTMLString(html as String, baseURL: url)
    }
    
    @IBAction func share(_ sender: Any) {
        
        let postlink:URL = URL.init(string:item!["link"].stringValue)!
        // let itemLink:URL = postlink.deletingLastPathComponent()
        let activityItems:[Any] = [postlink,webview.viewPrintFormatter()]
        let activity = UIActivityViewController.init(activityItems: activityItems, applicationActivities:nil)
        self.present(activity, animated: true, completion:nil)
    }
    
    @IBAction func comments(_ sender: Any) {
        performSegue(withIdentifier:Identifiers.commentsIdentifier.rawValue, sender:item)
    }
    
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == Identifiers.commentsIdentifier.rawValue
        {
            let navigation = segue.destination as! UINavigationController
            let controller = navigation.viewControllers.last as! CommentsViewController
            controller.post = item
            
        }
    }
    
    
}

extension DealDetailViewController : UIWebViewDelegate
{
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        
        if request.url?.absoluteString.hasPrefix("file") ?? false
        {
            return true
        }
        if navigationType == UIWebView.NavigationType.linkClicked
        {
            let safariVC = SFSafariViewController(url:request.url!)
            safariVC.preferredBarTintColor = Constants.headerColor
            self.present(safariVC, animated:true, completion:nil)
            return false
        }
        else
        {
            return true
        }
        
    }
    
    
}
