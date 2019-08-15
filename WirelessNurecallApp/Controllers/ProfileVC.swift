//
//  ProfileVC.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 4/18/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import SVProgressHUD


class ProfileVC: UIViewController {
    

    @IBOutlet weak var profImgView: UIImageView!
    @IBOutlet weak var employee_firstText: UITextField!
    @IBOutlet weak var employee_lastText: UITextField!
    @IBOutlet weak var employee_IdText: UITextField!
    @IBOutlet weak var updateBtn: UIButton!
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        profImgView.layer.masksToBounds = true
        profImgView.layer.cornerRadius = profImgView.frame.size.width/2
        profImgView.isUserInteractionEnabled = true
        profImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onImage)))
        
        
        fetchProfile()
    }
    
    func fetchProfile() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference().child("users/\(userID)")
        SVProgressHUD.show()
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() {
                self.showMessage(title: "Oops", message: "You haven't setup a profile yet")
                SVProgressHUD.dismiss()
                return
            }
            
            let value = snapshot.value as? NSDictionary
            if let employee_first = value?.value(forKey: "employeefirst") as? String {
                self.employee_firstText.text = employee_first
            }
            if let employee_last = value?.value(forKey: "employeelast") as? String {
                self.employee_lastText.text = employee_last
            }
            if let employee_id = value?.value(forKey: "employeeid") as? String {
                self.employee_IdText.text = employee_id
            }
            if let profile = value?.value(forKey: "profileimage") as? String {
                self.profImgView.downloaded(from: profile, contentMode: UIView.ContentMode.scaleAspectFill)
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            
        })
    }
    
    @objc func onImage() {
        let alertSheet = UIAlertController(title: "Choose", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) { (action) in
            self.checkForCameraPermission(completion: {(permitted) in
                if permitted {
                    self.showMediaController(sourceType: UIImagePickerController.SourceType.camera)
                } else {
                     self.showMessage(title: "Oops", message: "Camera permission is not given!")
                }
            })
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default) { (action) in
            self.checkForGalleryPermission(completion: { (permitted) in
                if permitted {
                    self.showMediaController(sourceType: UIImagePickerController.SourceType.photoLibrary)
                } else {
                    self.showMessage(title: "Oops", message: "Gallery permission is not given!")
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alertSheet.addAction(cameraAction)
        alertSheet.addAction(galleryAction)
        alertSheet.addAction(cancelAction)
        
        if let popoverController = alertSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alertSheet, animated: true, completion: nil)
    }
    
    func showMediaController(sourceType:UIImagePickerController.SourceType) {
        imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        } else {
            showMessage(title: "Oops", message: "This media type is not supported!")
        }
    }

    
    @IBAction func update_pressed(_ sender: UIButton) {
        let ref: DatabaseReference = Database.database().reference()
        guard let userID = Auth.auth().currentUser?.uid else {return}
        guard let employee_first = employee_firstText.text,
            !employee_firstText.isBlank() else {
                showMessage(title: "Oops", message: "Please enter first name")
                return
        }
        guard let employee_last = employee_lastText.text,
            !employee_lastText.isBlank() else {
                showMessage(title: "Oops", message: "Please enter last name")
                return
        }
        guard let employee_id = employee_IdText.text,
            !employee_IdText.isBlank() else {
                showMessage(title: "Oops", message: "Please enter your ID number")
                return
        }
        guard let profileimage = profImgView.image else {
            showMessage(title: "Oops", message: "Please select image.")
            return
        }
        
        SVProgressHUD.show()
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagename = String(describing: Date()).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "+", with: "")
        guard let imageData = profileimage.jpegData(compressionQuality: 0.5) else {return}
        
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
                
                ref.child("users").child(userID).setValue(["employeefirst": employee_first, "employeelast": employee_last, "employeeid": employee_id, "profileimage": url?.absoluteString ?? ""])
                
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
    }
    }
    


extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

extension ProfileVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let edited = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profImgView.image = edited
        } else if let original = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profImgView.image = original
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
