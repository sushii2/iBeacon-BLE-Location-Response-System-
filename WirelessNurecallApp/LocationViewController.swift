//
//  LocationViewController.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 4/12/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import UIKit
import CoreLocation

class LocationViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: NSUUID(uuidString:  "EAB24C98-8117-4F69-BA1B-45F4E1875858")! as UUID ,identifier: "Room1")
    let colors = [
        51840: UIColor(red: 84/255, green: 77/255, blue: 160/255, alpha: 1),
        62775: UIColor(red: 142/255, green: 212/255, blue: 220/255, alpha: 1)
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse){
          locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.unknown }
        let closestBeacon = knownBeacons[0] as CLBeacon
        if(knownBeacons.count > 0){
            self.view.backgroundColor = self.colors[closestBeacon.minor.intValue]
        }
    }
    
    func monitorBeacons(){
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self){
            let proxUUID = UUID(uuidString: "EAB24C98-8117-4F69-BA1B-45F4E1875858")
            let beaconID = "Room1"
            
            let regionx = CLBeaconRegion(proximityUUID: proxUUID!, identifier: beaconID)
            self.locationManager.startMonitoring(for: regionx)
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
