//
//  SignUpVC.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 4/18/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SignUpVC: UIViewController {

    @IBOutlet weak var emailTxt: UITextField!
    
    @IBOutlet weak var passTxt: UITextField!
    
    @IBOutlet weak var confirmPassText: UITextField!
    
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    


    @IBAction func signin_pressed(_ sender: UIButton) {
        guard let login = storyboard?.instantiateViewController(withIdentifier: "SignInVC") else {return}
        present(login, animated: true, completion: nil)
    }
    
    
    @IBAction func signup_pressed(_ sender: UIButton) {
        if emailTxt.isBlank() {
            showMessage(title: "Oops", message: "Please enter email")
        } else if !emailTxt.isValidEmail() {
            showMessage(title: "Oops", message: "Please enter a valid email")
        } else if passTxt.isBlank() {
            showMessage(title: "Oops", message: "Please enter password")
        } else if confirmPassText.isBlank() {
            showMessage(title: "Oops", message: "Please enter a confirmation password")
        } else if passTxt.text != confirmPassText.text {
            showMessage(title: "Oops", message: "The password does not match confirm password. Please try again.")
        }else {
            signUp()
        }
    }
    
    
    func signUp() {
        FirebaseHelper.signUp(email: emailTxt.text!, password: passTxt.text!){(error) in
            guard let errmsg = error?.localizedDescription else {return}
            self.showMessage(title: "Oops", message: errmsg)
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
