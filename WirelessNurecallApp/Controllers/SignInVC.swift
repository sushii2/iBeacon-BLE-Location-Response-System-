//
//  ViewController.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 3/21/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class SignInVC: UIViewController {



    
    @IBOutlet weak var emailTxtField: UITextField!
    
    @IBOutlet weak var passTextField: UITextField!
    
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        textField.layer.borderColor = UIColor.init(fromHexCode: "#0000ff").cgColor
//        textField.layer.borderWidth = 1.5
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        textField.layer.borderWidth = 0.0
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
//        emailTxtField.layer.cornerRadius = 3.0
//        passTextField.layer.cornerRadius = 3.0
//        emailTxtField.layer.borderWidth = 0.5
//        emailTxtField.layer.borderColor = UIColor.black.cgColor
//        passTextField.layer.borderWidth = 0.5
//        passTextField.layer.borderColor = UIColor.black.cgColor
        
        
        
        emailTxtField.text = "Test@test.com"
        passTextField.text = "test1234"
    }
    

    @IBAction func signup_pressed(_ sender: UIButton) {
        guard let signUp = storyboard?.instantiateViewController(withIdentifier: "SignUpVC") else {return}
        present(signUp, animated: true, completion: nil)
    }
    
    
 
    @IBAction func signin_pressed(_ sender: UIButton) {
        if emailTxtField.isBlank() {
            showMessage(title: "Oops", message: "Please enter email")
        } else if !emailTxtField.isValidEmail() {
            showMessage(title: "Oops", message: "Please enter a valid email")
        } else if passTextField.isBlank() {
            showMessage(title: "Oops", message: "Please enter password")
        } else {
            login()
        }
    }
    
    func loginSuccess() {
        guard let homeTab = storyboard?.instantiateViewController(withIdentifier: "HomeTab") else {return}
        present(homeTab, animated: true, completion: nil)
    }
    
    func login() {
        FirebaseHelper.login(email: emailTxtField.text!, password: passTextField.text!) { (error) in
            guard let errmsg = error?.localizedDescription else {
                
                self.loginSuccess()
                return
            }
            
            self.showMessage(title: "Oops", message: errmsg)
            
        }
    }
    
    

}

