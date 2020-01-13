//
//  EnvelopeDetailViewController.swift
//  Hip2Save
//
//  Created by ip-d on 03/01/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import UIKit

class EnvelopeDetailViewController: UIViewController {
    
    @IBOutlet weak var envelopeName: UILabel!
    @IBOutlet weak var envelopePrices: UILabel!
    @IBOutlet weak var envelopeImage: UIImageView!
    
    @IBOutlet weak var navBar: UINavigationItem!
    var currentAmount:Double = 0
    var prices:[Double] = []
    var dataSource:[Transaction] = []
    var envelope:BudgetEnvelope! = nil
    
    
    
    @IBOutlet weak var priceList: UITableView! { didSet {
        self.priceList.register(UINib.init(nibName:"AddEnvelopeCell", bundle:nil), forCellReuseIdentifier: "AddEnvelopeCell")
        self.priceList.allowsSelectionDuringEditing = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
      /*  let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        let logo = UIImage(named: "hip2save_main")
        logoImage.image = logo
        self.navigationItem.titleView = logoImage */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationBarButton()
        processTransaction()
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "EnvelopeDetailViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    @IBAction func addAmount(_ sender: Any) {
        performSegue(withIdentifier:Identifiers.AddTransactionIdentifier.rawValue, sender: envelope)
    }
    
    @objc func action() {
        
        if self.priceList.isEditing
        {
            self.priceList.isEditing = false
            navigationBarButton()
            return
        }
        
        let actionView = UIAlertController.init()
        
        let editButton = UIAlertAction.init(title:"Edit", style: .default) { (action) in
            self.priceList.isEditing = true
            self.navigationBarButton()
        }
        
        let resetButton = UIAlertAction.init(title:"Reset", style: .destructive) { (action) in
            let context = AppDelegate.shared.persistentContainer.viewContext
            for transaction in self.dataSource
            {
                context.delete(transaction)
            }
            do
            {
                try context.save()
                self.dataSource.removeAll()
                self.prices.removeAll()
                self.processTransaction()
            }
            catch
            {
                Utility.shared.showSnackBarMessage(message:error.localizedDescription)
            }
            
            
        }
        
        
        let cancelButton = UIAlertAction.init(title:"Cancel", style: .cancel) { (action) in
            
        }
        
        actionView.addAction(editButton)
        actionView.addAction(resetButton)
        actionView.addAction(cancelButton)
        present(actionView, animated: true, completion: nil)
        
    }
    
    func processTransaction()
    {
        prices.removeAll()
        currentAmount = envelope.totalAmount as! Double
        
        let transactions = envelope.transactions?.allObjects as! [Transaction]
        
        let sortedArray = transactions.sorted {
            $0.transactionDate! < $1.transactionDate!
        }
        
        for transaction in sortedArray
        {
            currentAmount = currentAmount - (transaction.amount as! Double)
            prices.append(currentAmount)
        }
        
        dataSource = sortedArray.sorted {
            $0.transactionDate! > $1.transactionDate!
        }
        
        prices = prices.sorted {
            $0 < $1
        }
        
        priceList.reloadData()
        
        let formatter = NumberFormatter.init()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        
        envelopeName.text = envelope.title
        envelopePrices.text = formatter.string(from:NSNumber.init(value: currentAmount))
        
    }
    
    func navigationBarButton()
    {
        self.navBar.rightBarButtonItems?.removeAll()
        if priceList.isEditing
        {
            let barButton = UIBarButtonItem.init(title:"Done", style: .done, target: self, action: #selector(action))
            self.navBar.rightBarButtonItems = [barButton]
            
        }
        else
        {
            let barButton = UIBarButtonItem.init(barButtonSystemItem:.action, target: self, action: #selector(action))
            self.navBar.rightBarButtonItems = [barButton]
            
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == Identifiers.AddTransactionIdentifier.rawValue
        {
            let navigation:UINavigationController = segue.destination as! UINavigationController
            
            let destination:AddTransactionViewController = navigation.viewControllers.first as! AddTransactionViewController
            if priceList.isEditing
            {
                destination.transaction =  (sender as! Transaction)
                destination.enableEdit = true
            }
            else
            {
                destination.envelope =  (sender as! BudgetEnvelope)
            }
            
        }
    }
    
    
}


extension EnvelopeDetailViewController:UITableViewDelegate,UITableViewDataSource
{
    // MARK:- TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        if dataSource.count > 0
        {
            navigationBarButton()
        }
        else
        {
            self.navBar.rightBarButtonItems?.removeAll()
        }
        
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var  cell = tableView.dequeueReusableCell(withIdentifier:"AddEnvelopeCell", for: indexPath) as? AddEnvelopeCell
        
        if cell == nil
        {
            let nibArray:NSArray = Bundle.main.loadNibNamed("AddEnvelopeCell", owner: nil, options: nil )! as NSArray
            cell = (nibArray.object(at: 0) as! AddEnvelopeCell)
            
        }
        if indexPath.row % 2 == 0
        {
            cell?.background.isHidden = false
        }
        else
        {
            cell?.background.isHidden = true
        }
        cell?.cellConfiguration(transaction: dataSource[indexPath.row], priceLeft: prices[indexPath.row])
        return cell!
    }
    
    // MARK:- TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing
        {
            performSegue(withIdentifier:Identifiers.AddTransactionIdentifier.rawValue, sender: dataSource[indexPath.row])
            
        }
        
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let context = AppDelegate.shared.persistentContainer.viewContext
            context.delete(dataSource[indexPath.row])
            do
            {
                try context.save()
                prices.remove(at:indexPath.row)
                dataSource.remove(at:indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                processTransaction()
            }
            catch
            {
                Utility.shared.showSnackBarMessage(message:error.localizedDescription)
            }
        }
    }
}
