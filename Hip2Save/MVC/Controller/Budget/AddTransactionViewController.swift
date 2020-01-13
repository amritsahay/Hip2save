//
//  AddTransactionViewController.swift
//  Hip2Save
//
//  Created by ip-d on 09/01/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import UIKit

class AddTransactionViewController: UIViewController {
    
    @IBOutlet weak var transactionAmount: UITextField!
    
    @IBOutlet weak var transactionTitle: UITextField!
    
    @IBOutlet weak var transactionDate: UITextField!
    
    var envelope:BudgetEnvelope! = nil
    var transaction:Transaction! = nil
    var enableEdit:Bool = false
    
    let datePicker = UIDatePicker.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if enableEdit
        {
            transactionTitle.text = transaction.title
            transactionAmount.text = transaction.amount?.stringValue
            transactionDate.text = Utility.shared.convertTime(format:"dd-MMM-yyyy", time:transaction.transactionDate!)
            datePicker.date = transaction.transactionDate!
        }
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "AddTransactionViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func setUI()
    {
       /* let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        let logo = UIImage(named: "hip2save_main")
        logoImage.image = logo
        self.navigationItem.titleView = logoImage */
        datePicker.datePickerMode = .date
        transactionDate.text = Utility.shared.convertTime(format:"dd-MMM-yyyy", time:datePicker.date)
        transactionDate.inputView = datePicker
        
    }
    
    @IBAction func save(_ sender: Any) {
        if (transactionTitle.text?.isEmpty)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter the title of transaction.")
        }
        else  if (transactionAmount.text?.isEmpty)!
        {
            Utility.shared.showSnackBarMessage(message:"Please enter the title of transaction.")
        }
        else if (transactionDate.text?.isEmpty)!
        {
            Utility.shared.showSnackBarMessage(message:"Please select the date of transaction.")
        }
        else
        {
            save()
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func save()
    {
        let appDelegate = AppDelegate.shared
        let managedContext = appDelegate.persistentContainer.viewContext
        if enableEdit
        {
            transaction.title = transactionTitle.text
            transaction.amount = NSDecimalNumber.init(string:transactionAmount.text)
            transaction.transactionDate = datePicker.date
        }
        else
        {
            let transaction = Transaction(context:managedContext)
            transaction.title = transactionTitle.text
            transaction.amount = NSDecimalNumber.init(string:transactionAmount.text)
            transaction.transactionDate = datePicker.date
            envelope.addToTransactions(transaction)
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
}

extension AddTransactionViewController:UITextFieldDelegate
{
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == transactionDate
        {
            textField.text = Utility.shared.convertTime(format:"dd-MMM-yyyy", time:datePicker.date)
        }
    }
}
