//
//  Item.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 4/19/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

struct ItemModel {
    static let roomKey = "room"
    static let patientKey = "patient"
    static let uuidValKey = "uuid"
    static let majorValKey = "major"
    static let minorValKey = "minor"
    static let resImgKey = "resimage"
}

class Item: NSObject, NSCoding {
    
    let room: String
    let patient: String
    let uuid: UUID
    let majorVal: CLBeaconMajorValue
    let minorVal: CLBeaconMinorValue
    let resImage: UIImage
    
    var beacon: CLBeacon?
    
    init(room: String, patient: String, uuid: UUID, majorVal: Int, minorVal: Int, resImage: UIImage) {
        self.room = room
        self.patient = patient
        self.uuid = uuid
        self.majorVal = CLBeaconMajorValue(majorVal)
        self.minorVal = CLBeaconMinorValue(minorVal)
        self.resImage = resImage
    }
    
    
    required init(coder aDecoder: NSCoder) {
        let aRoom = aDecoder.decodeObject(forKey: ItemModel.roomKey) as? String
        room = aRoom ?? ""
        
        let aPatient = aDecoder.decodeObject(forKey: ItemModel.patientKey) as? String
        patient = aPatient ?? ""
        
        let aUUID = aDecoder.decodeObject(forKey: ItemModel.uuidValKey) as? UUID
        uuid = aUUID ?? UUID()
        
        majorVal = UInt16(aDecoder.decodeInteger(forKey: ItemModel.majorValKey))
        minorVal = UInt16(aDecoder.decodeInteger(forKey: ItemModel.minorValKey))
        
        let aResImg = aDecoder.decodeObject(forKey: ItemModel.resImgKey) as? UIImage
        resImage = aResImg ?? UIImage()
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(room, forKey: ItemModel.roomKey)
        aCoder.encode(patient, forKey: ItemModel.patientKey)
        aCoder.encode(uuid, forKey: ItemModel.uuidValKey)
        aCoder.encode(Int(majorVal), forKey: ItemModel.majorValKey)
        aCoder.encode(Int(minorVal), forKey: ItemModel.minorValKey)
        aCoder.encode(resImage, forKey: ItemModel.resImgKey)
    }
    
    func asBeaconRegion() -> CLBeaconRegion {
        return CLBeaconRegion(proximityUUID: uuid, major: majorVal, minor: minorVal, identifier: room)
    }
    
    func nameForProximity(_ proximity: CLProximity) -> String {
        switch proximity {
        case .unknown:
            return "Unknown"
        case .immediate:
            return "Immediate"
        case .near:
            return "Near"
        case .far:
            return "Far"
        @unknown default:
            return "Device position unknown"
        }
    }
    
    func locationString() -> String {
        guard let beacon  = beacon else {return "Location: Unknown"}
        let proximity = nameForProximity(beacon.proximity)
        let calcAcc = calculateAccuracy(txPower: -72, rssi: Double(beacon.rssi))
        let stringCalcAcc = String(format: "%.2f", calcAcc)
        
        var location = "Location: \(proximity)"
        if beacon.proximity != .unknown {
            location += " (approx. \(stringCalcAcc)m)"
        }
        
        return location
    }
    
    func calculateAccuracy(txPower: Int, rssi: Double) -> Double {
        if(rssi == 0){
            return -1.0
        }
        
        let ratio = (rssi*1.0)/Double(txPower)
        
        if(ratio < 1.0){
            return pow(ratio, 10.0)
        }
        else {
            let calcAccuracy = (0.89976)*pow(ratio, 7.7095) + 0.111
            return calcAccuracy
        }
    }
    
    
}

func ==(item: Item, beacon: CLBeacon) -> Bool {
    return ((beacon.proximityUUID.uuidString == item.uuid.uuidString)
        && (Int(beacon.major) == Int(item.majorVal))
        && (Int(beacon.minor) == Int(item.minorVal)))
}
