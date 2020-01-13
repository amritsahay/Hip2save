//
//  AddEnvelopeViewController.swift
//  Hip2Save
//
//  Created by ip-d on 04/01/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import UIKit
import CoreData

class AddEnvelopeViewController: UIViewController {
    
    @IBOutlet weak var envelopeTitle: UITextField!
    
    @IBOutlet weak var budgetAmount: UITextField!
    
    var enableEdit:Bool = false
    
    var envelope:BudgetEnvelope! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       /* let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        let logo = UIImage(named: "hip2save_main")
        logoImage.image = logo
        self.navigationItem.titleView = logoImage */
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if enableEdit
        {
            envelopeTitle.text = envelope.title
            budgetAmount.text = envelope.totalAmount?.stringValue
        }
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "AddEnvelopeViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    @IBAction func save(_ sender: Any) {
        if (envelopeTitle.text?.isEmpty)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter the title of envelope.")
        }
        else if (budgetAmount.text?.isEmpty)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter the budget amount of envelope.")
        }
        else
        {
            save()
        }
        
    }
    
    func save()
    {
        let appDelegate = AppDelegate.shared
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if enableEdit
        {
            envelope.title = envelopeTitle.text
            envelope.totalAmount = NSDecimalNumber.init(string:budgetAmount.text)
        }
        else
        {
            let envelope = BudgetEnvelope(context:managedContext)
            envelope.title = envelopeTitle.text
            envelope.totalAmount = NSDecimalNumber.init(string:budgetAmount.text)
        }
        
      
        do
        {
            try managedContext.save()
            self.dismiss(animated:true, completion:nil)
        }
        catch
        {
            Utility.shared.showSnackBarMessage(message:error.localizedDescription)
        }
        
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
