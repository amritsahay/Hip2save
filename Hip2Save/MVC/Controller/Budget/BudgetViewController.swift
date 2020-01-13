//
//  BudgetViewController.swift
//  Hip2Save
//
//  Created by ip-d on 26/12/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit
import CoreData

class BudgetViewController: UIViewController {
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var listView: UIView!
    @IBOutlet var emptyView: UIView!
    
    var envelopes: [NSManagedObject] = []
    
    @IBOutlet weak var compose: UIBarButtonItem!
    @IBOutlet weak var budgetListView: UITableView! { didSet {
        self.budgetListView.register(UINib.init(nibName:"BudgetViewCell", bundle:nil), forCellReuseIdentifier: "BudgetViewCell")
        self.budgetListView.allowsSelectionDuringEditing = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.budgetListView.reloadData()
        emptyView.center = self.view.center
        self.view.insertSubview(emptyView, at:0)
        isHiddenEmptyView(value:true)
        
       /* let logoImage = UIImageView()
        logoImage.contentMode = .scaleAspectFit
        let logo = UIImage(named: "hip2save_main")
        logoImage.image = logo
        self.navigationItem.titleView = logoImage */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchBudgetEnvelopes()
        //navigationBarButton()
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "BudgetViewController")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated:true, completion:nil)
    }
    
    @IBAction func add(_ sender: Any) {
        performSegue(withIdentifier:Identifiers.AddEnvolopeIdentifier.rawValue, sender: nil)
    }
    
    func isHiddenEmptyView(value:Bool)
    {
        emptyView.isHidden = value
        listView.isHidden = !value
        if !value
        {
            self.navBar.rightBarButtonItems?.removeAll()
            self.navBar.rightBarButtonItems = [compose]
        }
        else
        {
            navigationBarButton()
        }
    }
    
    func navigationBarButton()
    {
        self.navBar.rightBarButtonItems?.removeAll()
        if budgetListView.isEditing
        {
            let barButton = UIBarButtonItem.init(title:"Done", style: .done, target: self, action: #selector(action))
            self.navBar.rightBarButtonItems = [compose,barButton]
            
        }
        else
        {
            let barButton = UIBarButtonItem.init(barButtonSystemItem:.action, target: self, action: #selector(action))
            self.navBar.rightBarButtonItems = [compose,barButton]
            
        }
    }
    
    @objc func action() {
        
        if self.budgetListView.isEditing
        {
            self.budgetListView.isEditing = false
            navigationBarButton()
            return
        }
        
        let actionView = UIAlertController.init()
        
        let editButton = UIAlertAction.init(title:"Edit", style: .default) { (action) in
            self.budgetListView.isEditing = true
            self.navigationBarButton()
        }
        
        let resetButton = UIAlertAction.init(title:"Reset", style: .destructive) { (action) in
            let context = AppDelegate.shared.persistentContainer.viewContext
            for budget in self.envelopes
            {
                context.delete(budget)
            }
            do
            {
                try context.save()
                self.envelopes.removeAll()
                self.budgetListView.reloadData()
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
    
    func fetchBudgetEnvelopes()
    {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName:"BudgetEnvelope")
        
        do {
            envelopes = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        budgetListView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.AddEnvolopeIdentifier.rawValue
        {
            let navigation:UINavigationController = segue.destination as! UINavigationController
            let destination:AddEnvelopeViewController = navigation.viewControllers.first as! AddEnvelopeViewController
            if (sender as? UIBarButtonItem) != nil
            {
                destination.envelope = nil
                destination.enableEdit = false
            }
            else
            {
                destination.envelope = (sender as! BudgetEnvelope)
                destination.enableEdit = true
            }
            
            //self.present(segue.destination, animated:true, completion:nil)
        }
        else if segue.identifier == Identifiers.ShowEnvelopeIdentifier.rawValue
        {
            let destination:EnvelopeDetailViewController = segue.destination as!  EnvelopeDetailViewController
            
            destination.envelope =  (sender as! BudgetEnvelope)
        }
        else if segue.identifier == Identifiers.AddTransactionIdentifier.rawValue
        {
            let navigation:UINavigationController = segue.destination as! UINavigationController
            
            let destination:AddTransactionViewController = navigation.viewControllers.first as! AddTransactionViewController
            
            destination.envelope =  (sender as! BudgetEnvelope)
        }
    }
}

extension BudgetViewController:UITableViewDelegate,UITableViewDataSource
{
    // MARK:- TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if envelopes.count > 0
        {
            isHiddenEmptyView(value:true)
        }
        else
        {
            isHiddenEmptyView(value:false)
        }
        return envelopes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var  cell = tableView.dequeueReusableCell(withIdentifier:"BudgetViewCell", for: indexPath) as? BudgetViewCell
        
        if cell == nil
        {
            let nibArray:NSArray = Bundle.main.loadNibNamed("BudgetViewCell", owner: nil, options: nil )! as NSArray
            cell = (nibArray.object(at: 0) as! BudgetViewCell)
            
        }
        
        let envelope = envelopes[indexPath.row] as! BudgetEnvelope
        
        cell?.configureCell(envelope:envelope)
        cell?.controller = self
        return cell!
    }
    
    // MARK:- TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing
        {
            let envelope = envelopes[indexPath.row] as! BudgetEnvelope
            performSegue(withIdentifier:Identifiers.AddEnvolopeIdentifier.rawValue, sender: envelope)
            return
        }
        let envelope = envelopes[indexPath.row] as! BudgetEnvelope
        performSegue(withIdentifier:Identifiers.ShowEnvelopeIdentifier.rawValue, sender: envelope)
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
            context.delete(envelopes[indexPath.row] )
            envelopes.remove(at:indexPath.row)
            do
            {
                try context.save()
                
            }
            catch
            {
                Utility.shared.showSnackBarMessage(message:error.localizedDescription)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
}
