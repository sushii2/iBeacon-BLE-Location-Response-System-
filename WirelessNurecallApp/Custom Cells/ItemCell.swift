//
//  ItemCell.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 4/12/19.
//  Copyright © 2019 Saksham. All rights reserved.
//
import Foundation
import UIKit

class itemCell: UITableViewCell {
    
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    var item: Item? = nil {
        didSet {
            if let item = item {
                lblName.text = item.name
                lblLocation.text = item.locationString()
                
                
            } else {
                lblName.text = ""
                lblLocation.text = ""
            }
        }
    }
    
    func refreshLocation() {
        lblLocation.text = item?.locationString() ?? ""
    }
}
