//
//  BeaconsViewController.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 4/16/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SVProgressHUD

let storedItemskey = "storedItems"


class BeaconsViewController: UIViewController {

    
    @IBOutlet weak var addBeaconBtn: UIButton!
    
    let locationManager = CLLocationManager()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var items = [Item]()
    var timer = Timer()
    let pulsator = Pulsator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        locationManager.requestAlwaysAuthorization()
            locationManager.delegate = self
            tableView.dataSource = self
            tableView.delegate = self
            loadBeacons()
        scheduledTimerWithTimeInterval()
        
    }
    
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 60 seconds
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
        for (index,item) in items.enumerated() {
            let beac = item.beacon
            if beac != nil{
                let acc = item.calculateAccuracy(txPower: -70, rssi: Double(beac?.rssi ?? 0))
                let prox = beac?.proximity ?? .unknown
                if acc < 1.50 && prox != .unknown {
                    if let Level2 = self.storyboard!.instantiateViewController(withIdentifier: "ReportVC") as? ReportVC {
                        Level2.passedRes = item.patient
                        Level2.passedRoom = item.room
                        Level2.passResImg = item.resImage
                        if(index < items.count - 1){
                            let nextItem = items[index + 1]
                            Level2.nextPassedRes = nextItem.patient
                            Level2.nextPassedRoom = nextItem.room
                        }
                        Level2.selectedBeacon = beac
                        self.show(Level2, sender: nil)
                        break
                    }
                }
            }else{
                print("No beacon found")
            }
            
        }
    }
    
    func loadBeacons() {
        guard let storedItems = UserDefaults.standard.array(forKey: storedItemskey) as? [Data] else { return }
        for itemData in storedItems {
            guard let item = NSKeyedUnarchiver.unarchiveObject(with: itemData) as? Item else { continue }
            items.append(item)
            startMonitoringItem(item)
        }
    }
    
    func persistItems() {
        var itemsData = [Data]()
        for item in items {
            let itemData = NSKeyedArchiver.archivedData(withRootObject: item)
            itemsData.append(itemData)
        }
        UserDefaults.standard.set(itemsData, forKey: storedItemskey)
        UserDefaults.standard.synchronize()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueAdd", let viewController = segue.destination as? AddBeaconVC {
            viewController.delegate = self
        }
    }
    
    func startMonitoringItem(_ item: Item) {
        let beaconRegion = item.asBeaconRegion()
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func stopMonitoringItem(_ item: Item) {
        let beaconRegion = item.asBeaconRegion()
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }


}

extension BeaconsViewController: AddBeacon {
    
    func addBeacon(item: Item) {
        items.append(item)
        
        tableView.beginUpdates()
        let newIndexPath = IndexPath(row: items.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        tableView.endUpdates()
        startMonitoringItem(item)
        
        persistItems()
    }
    
}


extension BeaconsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath) as! ItemCell
        cell.item = items[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            tableView.beginUpdates()
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            stopMonitoringItem(items[indexPath.row])
            persistItems()
        }
    }
    
}

// MARK: UITableViewDelegate
extension BeaconsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = items[indexPath.row]
        
            let resName = item.patient
            let resRoom = item.room
            let resImg = item.resImage
        
        SVProgressHUD.show()
        
        let ref = Database.database().reference()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagename = String(describing: Date()).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "+", with: "")
        guard let imageData = resImg.jpegData(compressionQuality: 0.5) else {return}
        let imageRef = storageRef.child("/profile/\(imagename).jpg")
        
        _ = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            SVProgressHUD.dismiss()
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                self.showMessage(title: "Oops", message: error?.localizedDescription ?? "Something went wrong")
                return
            }
            
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    self.showMessage(title: "Oops", message: error?.localizedDescription ?? "Something went wrong")
                    return
                }
            
            
                ref.child("schedule").childByAutoId().setValue(["resName": resName, "resRoom": resRoom, "resImg": url?.absoluteString ?? ""])
        
            }
            
        }
            
        
        let detailMessage = "Succesfully added this resident to your schedule"
        let detailAlert = UIAlertController(title: "Details", message: detailMessage, preferredStyle: .alert)
        detailAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(detailAlert, animated: true, completion: nil)
    }
}

extension BeaconsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        // Find the same beacons in the table.
        var indexPaths = [IndexPath]()
        for beacon in beacons {
            for row in 0..<items.count {
                // TODO: Determine if item is equal to ranged beacon
                if items[row] == beacon {
                    print(items[row].beacon as Any)
                    items[row].beacon = beacon
                    indexPaths += [IndexPath(row: row, section: 0)]
                }
            }
        }
        
        // Update beacon locations of visible rows.
        if let visibleRows = tableView.indexPathsForVisibleRows {
            let rowsToUpdate = visibleRows.filter { indexPaths.contains($0) }
            for row in rowsToUpdate {
                let cell = tableView.cellForRow(at: row) as! ItemCell
                cell.refreshLocation()
            }
        }
    }
    
    
}




    



