//
//  resCell.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 4/19/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import Foundation
import UIKit

class resCell: UITableViewCell {
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var roomLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.setCard()
    }
    
}
