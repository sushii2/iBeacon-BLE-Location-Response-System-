//
//  Models.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 4/19/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import Foundation
import UIKit

struct ReportModel: Decodable {
    var userId: String
    var notes: String
    var cause: String
    var report: String
}

struct ResidentModel {
    var name: String
    var age: String
    var room: String
    var residentID: String
    var residentImg: UIImage
        
    init?(residentID: String, dict: [String: Any]){
    
        self.residentID = residentID
        guard let name = dict["name"] as? String,
            let age = dict["age"] as? String,
            let room = dict["room"] as? String,
            let residentImg = dict["residentImg"] as? UIImage
            else { return nil }
        
        self.name = name
        self.age = age
        self.room = room
        self.residentImg = residentImg
        
    }
}

