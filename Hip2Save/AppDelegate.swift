//
//  AppDelegate.swift
//  Hip2Save
//
//  Created by ip-d on 31/10/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit
import KYDrawerController
import FBSDKCoreKit
import Firebase
import GoogleSignIn
import IQKeyboardManagerSwift
import CoreData
import CryptoSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var drawerController:KYDrawerController?
    var currentUser:User? = nil
    static var dealreloaddata:Bool = false
    static var restroreloaddata:Bool = false
    static var restrocheck:Bool = false
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Hip2Save")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions:launchOptions)
        
        setAppearance()
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        IQKeyboardManager.shared.enable = true
        currentUser = LocalDBWrapper.shared.readUser()
        loadAppStructure()
        guard let gai = GAI.sharedInstance() else {
            assert(false, "Google Analytics not configured correctly")
            return true
        }
        gai.tracker(withTrackingId: "UA-4801823-1")
        // Optional: automatically report uncaught exceptions.
        gai.trackUncaughtExceptions = true
        
        // Optional: set Logger to VERBOSE for debug information.
        // Remove before app release.
        gai.logger.logLevel = .verbose;
        StoreReviewHelper.incrementAppOpenedCount()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled:Bool = FBSDKApplicationDelegate.sharedInstance().application(app, open: url as URL!, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String!, annotation: nil)
        return handled
    }
    
    
    func loadAppStructure() {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let leftMenuController =  mainStoryboard.instantiateViewController(withIdentifier:Identifiers.SideMenuViewController.rawValue)
        let mainViewController:UINavigationController  = mainStoryboard.instantiateInitialViewController() as! UINavigationController
        //        var contentController:UIViewController? = nil
        //        contentController = mainStoryboard.instantiateViewController(withIdentifier:Identifiers.CustomTabBarViewController.rawValue)
        //        mainViewController.setViewControllers([contentController!], animated:true)
        //    mainViewController.setViewControllers([contentController!,mainStoryboard.instantiateViewController(withIdentifier:Identifiers.CustomTabBarViewController.rawValue)], animated:true)
        
        drawerController = KYDrawerController(drawerDirection: .left, drawerWidth:UIScreen.main.bounds.width - UIScreen.main.bounds.width * (20/100))
        drawerController?.screenEdgePanGestureEnabled = false
        drawerController?.mainViewController = mainViewController
        drawerController?.drawerViewController = leftMenuController
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = drawerController
        window?.makeKeyAndVisible()
    }
    
    func openDrawer(){
//        if currentUser == nil
//        {
//            Utility.shared.showSnackBarMessage(message:"Please login before access this feature.")
//            return
//        }
        drawerController?.setDrawerState(.opened, animated: true)
    }
    
    func setAppearance()
    {
        UIApplication.shared.statusBarStyle = .lightContent
        
        let attributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        
        UINavigationBar.appearance().barTintColor = Constants.headerColor
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
    }
    
    func getEncryptionToken() -> String
    {
        if currentUser != nil
        {
            let input: Array<UInt8> = Array((currentUser?.cookie ?? "").utf8)
            let key: Array<UInt8> = Array("secrethipkey2enc".utf8)
            let iv: Array<UInt8> = Array("ivhipsecret5npkl".utf8)
            
            do {
                let encrypted = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs5).encrypt(input)
                //  let decrypted = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs5).decrypt(encrypted)
                return (encrypted.toBase64()! + ":" + iv.toBase64()!)
                
            } catch {
                print(error)
            }
        }
        return ""
    }
    
    
}

