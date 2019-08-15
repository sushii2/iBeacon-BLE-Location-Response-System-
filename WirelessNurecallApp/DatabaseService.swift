//
//  DatabaseService.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 3/21/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import Foundation
import Firebase

class DatabaseService {
    
    static let shared = DatabaseService()
    
    private init(){
        
    }
    
    let reportReference = Database.database().reference().child("report")
    
}
