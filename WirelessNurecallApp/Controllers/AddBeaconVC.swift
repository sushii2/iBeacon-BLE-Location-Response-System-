//
//  AddBeaconVC.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 4/19/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SVProgressHUD

protocol AddBeacon {
    func addBeacon(item: Item)
}


class AddBeaconVC: UIViewController {
    
    @IBOutlet weak var text_room: UITextField!
    @IBOutlet weak var text_patient: UITextField!
    @IBOutlet weak var text_uuid: UITextField!
    @IBOutlet weak var text_major: UITextField!
    @IBOutlet weak var text_minor: UITextField!
    @IBOutlet weak var resImage: UIImageView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet var cancelBtn: UIButton!
    
    var imagePicker : UIImagePickerController!
    
    let uuidRegex = try! NSRegularExpression(pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", options: .caseInsensitive)
    
    var delegate: AddBeacon?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resImage.isUserInteractionEnabled = true
        resImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onImage)))
        addBtn.isEnabled = false
        // Do any additional setup after loading the view.
        
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
    
    @IBAction func textFieldEditChanged(_ sender: UITextField) {
        let nameValid = (text_room.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0)
        
        // Is UUID valid?
        var uuidValid = false
        let uuidString = text_uuid.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if uuidString.count > 0 {
            uuidValid = (uuidRegex.numberOfMatches(in: uuidString, options: [], range: NSMakeRange(0, uuidString.count)) > 0)
        }
        text_uuid.textColor = (uuidValid) ? .black : .red
        
        // Toggle btnAdd enabled based on valid user entry
        addBtn.isEnabled = (nameValid && uuidValid)
    }
    
    
    @IBAction func add_pressed(_ sender: UIButton) {
        
        let ref: DatabaseReference = Database.database().reference()

        
        if(text_minor.isBlank() || text_room.isBlank() || text_patient.isBlank()){
            showMessage(title: "Oops", message: "Please don't leave fields blank")
            return
        }
        
        let uuidString = text_uuid.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard let uuid = UUID(uuidString: uuidString) else { return }
        let major = Int(text_major.text!) ?? 0
        let minor = Int(text_minor.text!) ?? 0
        let room = text_room.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let patient = text_patient.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard let residentImg = resImage.image else {
            showMessage(title: "Oops", message: "Please select an Image for resident by pressing the white circle above.")
            return
        }
        
        let newItem = Item(room: room, patient: patient, uuid: uuid, majorVal: major, minorVal: minor, resImage: residentImg)
        
        delegate?.addBeacon(item: newItem)
        
        SVProgressHUD.show()
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagename = String(describing: patient).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "+", with: "")
        guard let imageData = residentImg.jpegData(compressionQuality: 0.5) else {return}
        
        let beacRef = storageRef.child("/beacons/\(imagename).jpg")
        
        _ = beacRef.putData(imageData, metadata: nil) { (metadata, error) in
            SVProgressHUD.dismiss()
            
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                self.showMessage(title: "Oops", message: error?.localizedDescription ?? "Something went wrong")
                return
                
            }
            
            beacRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    self.showMessage(title: "Oops", message: error?.localizedDescription ?? "Something went wrong")
                    return
                }
                ref.child("beacons").setValue(["room": room, "resident": patient, "residentimage": url?.absoluteString ?? ""])
            }
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel_pressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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

extension AddBeaconVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Enter key hides keyboard
        textField.resignFirstResponder()
        return true
    }
}

extension AddBeaconVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let edited = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            resImage.image = edited
        } else if let original = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            resImage.image = original
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
