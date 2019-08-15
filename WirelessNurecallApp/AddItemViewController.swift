//
//  AddItemViewController.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 4/12/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import UIKit

protocol AddBeacon {
    func addBeacon(item: Item)
}

class AddItemViewController: UIViewController {

    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtUUID: UITextField!
    @IBOutlet weak var txtMajor: UITextField!
    @IBOutlet weak var txtMinor: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    
    let uuidRegex = try! NSRegularExpression(pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", options: .caseInsensitive)
    
    var delegate: AddBeacon?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnAdd.isEnabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss keyboard
        self.view.endEditing(true)
    }

    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        // Is name valid?
        let nameValid = (txtName.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0)
        
        // Is UUID valid?
        var uuidValid = false
        let uuidString = txtUUID.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if uuidString.count > 0 {
            uuidValid = (uuidRegex.numberOfMatches(in: uuidString, options: [], range: NSMakeRange(0, uuidString.count)) > 0)
        }
        txtUUID.textColor = (uuidValid) ? .black : .red
        
        // Toggle btnAdd enabled based on valid user entry
        btnAdd.isEnabled = (nameValid && uuidValid)
    }
    
    
    @IBAction func btnAdd_Pressed(_ sender: UIButton) {
        let uuidString = txtUUID.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard let uuid = UUID(uuidString: uuidString) else { return }
        let major = Int(txtMajor.text!) ?? 0
        let minor = Int(txtMinor.text!) ?? 0
        let name = txtName.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let newItem = Item(name: name, uuid: uuid, majorValue: major, minorValue: minor)
        
        delegate?.addBeacon(item: newItem)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCancel_Pressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension AddItemViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Enter key hides keyboard
        textField.resignFirstResponder()
        return true
}
}
