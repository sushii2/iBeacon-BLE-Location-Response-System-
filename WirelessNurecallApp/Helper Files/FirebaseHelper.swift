//
//  FirebaseHelper.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 4/18/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class FirebaseHelper {
    class func login(email:String, password:String, completion:@escaping ((_ error:Error?) -> Void)) {
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            completion(error)
        }
    }
    class func signUp(email:String, password:String, completion:@escaping ((_ error:Error?) -> Void)) {
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            completion(error)
        }
    }
}
