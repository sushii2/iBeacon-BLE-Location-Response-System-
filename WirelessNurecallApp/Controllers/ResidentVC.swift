//
//  ResidentVC.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 5/14/19.
//  Copyright © 2019 Saksham. All rights reserved.
//
/*
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SVProgressHUD


class ResidentVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var residents = [ResidentModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let ref = Database.database().reference().child("residents")
        ref.observe(DataEventType.value, with: {
            (snapshot) in
            print (snapshot)
            guard let residentsSnap = residentsSnapshot(with: snapshot) else { return }
            self.residents = residentsSnap.residents
            self.tableView.reloadData()
            
        })
        
    }
    

    
    @IBAction func onAdd(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add resident", message: "Add a resident to your directory", preferredStyle: .alert)
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
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let add = UIAlertAction(title: "Add", style: .default) { _ in
            guard
                let name = alert.textFields?.first?.text,
                let age = alert.textFields?[1].text!,
                let room = alert.textFields?.last?.text
                else {return}
            
        SVProgressHUD.show()
            
            let ref: DatabaseReference = Database.database().reference()
            ref.child("residents").childByAutoId().setValue(["name": name,"age": age,"room": room])
            
        SVProgressHUD.dismiss()
            
        }
        alert.addAction(add)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

}

extension ResidentVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return residents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "residentCell") as! resCell
        cell.nameLbl?.text = residents[indexPath.row].name
        cell.roomLbl?.text = residents[indexPath.row].room
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            residents.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
        
    }
    
    
}*/


