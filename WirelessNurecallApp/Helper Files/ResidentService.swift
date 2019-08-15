//
//  ResidentService.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 5/14/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import Foundation
import UIKit

class ResidentService {
    
    private init() {}
    
    static func addResident(in vc: ResidentVC, completion: @escaping (ResidentModel) -> Void){
        let alert = UIAlertController(title: "Add resident", message: nil, preferredStyle: .alert)
        alert.addTextField{
            (nameTF) in
            nameTF.placeholder = "Resident Name"
        }
        alert.addTextField{
            (ageTF) in
            ageTF.placeholder = "Resident Age"
            ageTF.keyboardType = UIKeyboardType.numberPad
        }
        alert.addTextField{
            (roomTF) in
            roomTF.placeholder = "Resident Room"
        }
        
        let add = UIAlertAction(title: "Add", style: .default) { _ in
            guard
                let name = alert.textFields?.first?.text,
                let ageString = alert.textFields?[1].text!,
                let room = alert.textFields?.last?.text,
                let age = Int(ageString)
                else {return}
            
            print(name)
            print(age)
            print(room)
            let resident = ResidentModel(name: name, age: age, room: room)
            completion(resident)
            
        }
        alert.addAction(add)
        vc.present(alert, animated: true)
    }
    
    static func updateResident(_ resident: ResidentModel,in vc: ResidentVC, completion: @escaping(ResidentModel) -> Void){
        let alert = UIAlertController(title: "Update \(resident.name)", message: nil, preferredStyle: .alert)
        alert.addTextField{
            (ageTF) in
            ageTF.placeholder = "Resident Age"
            ageTF.keyboardType = UIKeyboardType.numberPad
            ageTF.text = String(resident.age)
        }
        alert.addTextField{
            (roomTF) in
            roomTF.placeholder = "Resident Room"
            roomTF.text = resident.room
        }
        
        let update = UIAlertAction(title: "Update", style: .default) { _ in
            guard
                let ageString = alert.textFields?.first?.text,
                let room = alert.textFields?.last?.text,
                let age = Int(ageString)
                else {return}
            
        var updatedRes = resident
        updatedRes.age = age
        updatedRes.room = room
            
        completion(updatedRes)
            
            print(age)
            print(room)
           
            
        }
        alert.addAction(update)
        vc.present(alert, animated: true)
    }
    
}

