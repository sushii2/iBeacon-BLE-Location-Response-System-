//
//  residentsSnapshot.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 5/14/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import Foundation
import Firebase

struct residentsSnapshot {
    
    let scheduledResidents: [ResidentModel]
    
    init?(with snapshot: DataSnapshot){
        var scheduled = [ResidentModel]()
        guard let snapDict = snapshot.value as? [String: [String:Any]] else {return nil}
        for snap in snapDict{
            guard let resident = ResidentModel(residentID: snap.key, dict: snap.value) else { continue }
            scheduled.append(resident)
        }
        self.scheduledResidents = scheduled
    }
}
