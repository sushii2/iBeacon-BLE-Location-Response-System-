//
//  ItemCell.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 4/19/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import Foundation
import UIKit

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var lblRoom: UILabel!
    @IBOutlet weak var lblPatient: UILabel!
    @IBOutlet weak var lblLoc: UILabel!
    @IBOutlet weak var residentImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var item: Item? = nil {
        didSet {
            if let item = item {
                residentImgView.image = item.resImage
                lblRoom.text = item.room
                lblPatient.text = item.patient
                lblLoc.text = item.locationString()
            } else {
                residentImgView.image = UIImage(named: "logo")
                lblRoom.text = ""
                lblPatient.text = ""
                lblLoc.text = ""
            }
        }
    }
    
    func refreshLocation() {
        lblLoc.text = item?.locationString() ?? ""
    }
    
    
}
