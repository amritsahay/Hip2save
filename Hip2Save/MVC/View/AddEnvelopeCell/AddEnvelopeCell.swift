//
//  AddEnvelopeCell.swift
//  Hip2Save
//
//  Created by ip-d on 02/01/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import UIKit

class AddEnvelopeCell: UITableViewCell {
    @IBOutlet weak var cellAmountLeft: UILabel!
    @IBOutlet weak var cellDate: UILabel!
    @IBOutlet weak var background: UIView!
    
    @IBOutlet weak var cellPrices: UILabel!
    @IBOutlet weak var cellTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellConfiguration(transaction:Transaction,priceLeft:Double)
    {
        let formatter = NumberFormatter.init()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        
        cellTitle.text = transaction.title
        cellDate.text = Utility.shared.convertTime(format:"dd/MM/yyyy", time:transaction.transactionDate!)
        cellPrices.text = formatter.string(from:transaction.amount!)
        cellAmountLeft.text = formatter.string(from: NSNumber.init(value:priceLeft))

    }
}
