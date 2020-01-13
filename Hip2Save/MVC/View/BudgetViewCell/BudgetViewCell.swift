//
//  BudgetViewCell.swift
//  Hip2Save
//
//  Created by ip-d on 27/12/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit

class BudgetViewCell: UITableViewCell {

    @IBOutlet weak var prices: UILabel!
    @IBOutlet weak var budgetName: UILabel!
    var controller:UIViewController!
    var budgetEnvelope:BudgetEnvelope! = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(envelope:BudgetEnvelope)
    {
        budgetEnvelope = envelope
        let formatter = NumberFormatter.init()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        budgetName.text = envelope.title
        
        
        let transactions = envelope.transactions?.allObjects as! [Transaction]
        var currentAmount:Double = envelope.totalAmount as! Double
        for transaction in transactions
        {
            currentAmount = currentAmount - (transaction.amount as! Double)
        }
        prices.text = formatter.string(from:NSNumber.init(value:currentAmount))
    }
    
    @IBAction func Add(_ sender: Any) {
        controller.performSegue(withIdentifier:Identifiers.AddTransactionIdentifier.rawValue, sender: budgetEnvelope)
    }
    
}
