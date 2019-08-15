//
//  Extensions.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 4/18/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

extension NSDictionary {
    
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func toModel<T: Decodable>(completion: @escaping (T) -> ()) {
        do {
            let obj = try JSONDecoder().decode(T.self, from: self.json.data(using: String.Encoding.utf8)!)
            completion(obj)
        } catch {
            print(error) // any decoding error will be printed here!
        }
    }
    
}

extension UITextField {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.text ?? "")
    }
    
    func isBlank() -> Bool {
        return self.text?.isEmptyOrWhitespace() ?? true
    }
}

extension Date {
    func formattedDateString() -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        
        return "\(String(format: "%02d", day))-\(String(format: "%02d", month))-\(String(describing: year))"
    }
}

extension UIViewController {
    func showMessage(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func checkForCameraPermission(completion:@escaping ((_ permitted:Bool) -> Void)) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            // Already Authorized
            completion(true)
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                completion(granted)
            })
        }
    }
    
    func checkForGalleryPermission(completion:@escaping ((_ permitted:Bool) -> Void)) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
            completion(true)
        }
            
        else if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
            completion(false)
        }
            
        else if (status == PHAuthorizationStatus.notDetermined) {
            
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                completion(newStatus == .authorized)
            })
        }
            
        else if (status == PHAuthorizationStatus.restricted) {
            // Restricted access - normally won't happen.
            completion(false)
        }
    }
}

extension String {
    func isEmptyOrWhitespace() -> Bool {
        if(self.isEmpty) {
            return true
        }
        return (self.trimmingCharacters(in: NSCharacterSet.whitespaces) == "")
    }
}

extension UIView {
    
    func setRounded() {
        layer.masksToBounds = true
        layer.cornerRadius = frame.height / 2
    }
    
    func setCard() {
        let cornerRadius: CGFloat = 2
        let shadowOffsetWidth: Int = 0
        let shadowOffsetHeight: Int = 3
        let shadowColor: UIColor? = UIColor.black
        let shadowOpacity: Float = 0.5
        
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
}

extension UITextField {
    
    func setRightView(icon:UIImage) {
        let padding = -8
        let size = 20
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: padding, y: 0, width: size, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)
        
        rightView = outerView
        rightViewMode = .always
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    func isEmpty() -> Bool {
        return self.text?.isEmptyOrWhitespace() ?? false
    }
}



