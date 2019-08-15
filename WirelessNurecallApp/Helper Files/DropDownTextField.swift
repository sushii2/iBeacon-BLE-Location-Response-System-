//
//  DropDownTextField.swift
//  No Limit Fantasy Sports
//
//  Created by Admin on 01/06/18.
//  Copyright © 2018 ok. All rights reserved.
//

import DropDown
import IQKeyboardManagerSwift

protocol DropDownTextFieldDelegate {
    func onSelected(index: Int, item: String)
}

@IBDesignable class DropDownTextField:UITextField,UITextFieldDelegate {
    
    let dropdowndelegate:DropDownTextFieldDelegate? = nil
    let dropDown:DropDown = DropDown()
    
    var datasource = [String]() {
        didSet {
            dropDown.dataSource = datasource
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        IQKeyboardManager.shared.enableAutoToolbar = false
        self.dropDown.show()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    override func awakeFromNib() {
        dropDown.anchorView = self
        self.inputView = UIView()
        self.setLeftPaddingPoints(10)
        self.delegate = self
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.resignFirstResponder()
            if let thedelegate = self.dropdowndelegate {
                thedelegate.onSelected(index: 0, item: item)
            }
        }
        
        dropDown.cancelAction = { () in
            self.resignFirstResponder()
        }
        
    }
}
