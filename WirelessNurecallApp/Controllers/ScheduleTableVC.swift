//
//  ScheduleTableVC.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 6/21/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SVProgressHUD

class ScheduleTableVC: UITableViewController {
    
    var scheduledResidents = [ResidentModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let ref = Database.database().reference().child("schedule")
        ref.observe(DataEventType.value, with: {
            (snapshot) in
            print (snapshot)
            guard let scheduledResidentSnap = residentsSnapshot(with: snapshot) else {
                return
            }
            self.scheduledResidents = scheduledResidentSnap.scheduledResidents
            self.tableView.reloadData()
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return scheduledResidents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableItem") as! scheduleCell
        cell.resImg.image =  scheduledResidents[indexPath.row].residentImg
        cell.resName?.text = scheduledResidents[indexPath.row].name
        cell.resRoom?.text = scheduledResidents[indexPath.row].room
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            scheduledResidents.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
        
    }

}
