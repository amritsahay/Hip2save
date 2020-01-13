//
//  CustomTabBarViewController.swift
//  Hip2Save
//
//  Created by ip-d on 29/11/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit

class CustomTabBarViewController: UIViewController {
    
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var restaurtantButton: UIButton!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var tipButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    var tabButtons:[UIButton] = []
    var tabViewControllers:[UINavigationController?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configurationUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "CustomTabBarViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    @IBAction func dealAction(_ sender: Any) {
        select(index:(sender as! UIButton).tag)
        switchTabViewController(index:(sender as! UIButton).tag)
    }
    
    @IBAction func restaurantAction(_ sender: Any) {
        select(index:(sender as! UIButton).tag)
        switchTabViewController(index:(sender as! UIButton).tag)
    }
    
    @IBAction func storeAction(_ sender: Any) {
        select(index:(sender as! UIButton).tag)
        switchTabViewController(index:(sender as! UIButton).tag)
    }
    
    @IBAction func tipAction(_ sender: Any) {
        select(index:(sender as! UIButton).tag)
        switchTabViewController(index:(sender as! UIButton).tag)
    }
    
    @IBAction func shareAction(_ sender: Any) {
        select(index:(sender as! UIButton).tag)
        switchTabViewController(index:(sender as! UIButton).tag)
    }
    
    @IBAction func moreAction(_ sender: Any) {
        select(index:(sender as! UIButton).tag)
        switchTabViewController(index:(sender as! UIButton).tag)
    }
    
    func configurationUI()
    {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        tabButtons = [dealButton,restaurtantButton,storeButton,tipButton,shareButton,moreButton]
        tabViewControllers = [nil,nil,nil,nil,nil,nil]
        select(index:0)
        switchTabViewController(index:0)
    }
    
    func unselectAll()
    {
        for tabButton in tabButtons
        {
            tabButton.tintColor = UIColor.lightGray
        }
    }
    
    func select(index:Int)
    {
        unselectAll()
        let selectedTabButton = tabButtons[index]
        selectedTabButton.tintColor = Constants.selectedColor
    }
    
    func switchTabViewController(index:Int)
    {
        for containerSubView in contentView.subviews
        {
            containerSubView.removeFromSuperview()
        }
        
        if let navigation = tabViewControllers[index]
        {
            addChild(navigation)
            contentView.addSubview(navigation.view)
            navigation.view.frame = contentView.bounds
            navigation.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            navigation.didMove(toParent: self)
        }
        else
        {
            let navigation = UINavigationController.init()
            switch index
            {
            case 0:
                let viewController  = self.storyboard?.instantiateViewController(withIdentifier:Identifiers.DealsViewController.rawValue) as! DealsViewController
                
                navigation.pushViewController(viewController, animated: true)
                //navigation.setViewControllers([viewController!], animated: true)
                break
            case 1:
                let viewController  = self.storyboard?.instantiateViewController(withIdentifier:Identifiers.RestaurantViewController.rawValue)
                navigation.setViewControllers([viewController!], animated: true)
                break
            case 2:
                let viewController  = self.storyboard?.instantiateViewController(withIdentifier:Identifiers.StoresViewControllers.rawValue)
                navigation.setViewControllers([viewController!], animated: true)
                break
            case 3:
                let viewController  = self.storyboard?.instantiateViewController(withIdentifier:Identifiers.TipsViewController.rawValue)
                navigation.setViewControllers([viewController!], animated: true)
                break
            case 4:
                let viewController  = self.storyboard?.instantiateViewController(withIdentifier:Identifiers.Hip2ShareViewController.rawValue)
                navigation.setViewControllers([viewController!], animated: true)
                break
            case 5:
                let viewController  = self.storyboard?.instantiateViewController(withIdentifier:Identifiers.MoreViewController.rawValue)
                navigation.setViewControllers([viewController!], animated: true)
                break
            default:
                break
            }
            
            tabViewControllers[index] = navigation
            addChild(navigation)
            contentView.addSubview(navigation.view)
            navigation.view.frame = contentView.bounds
            navigation.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            navigation.didMove(toParent: self)
            
        }
        
    }
}
