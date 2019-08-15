//
//  ReportVC.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 4/18/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import UIKit
import SVProgressHUD
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import CoreLocation

var items = [Item]()

class ReportVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
   
    
    @IBOutlet weak var incidentImgView: UIImageView!
    @IBOutlet weak var notesTxtArea: UITextView!
    @IBOutlet weak var pickerCtrl: UIPickerView!
    @IBOutlet weak var causeLbl: UILabel!
    @IBOutlet weak var reportTxtArea: UITextView!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    
    
    @IBOutlet weak var nameBeac: UILabel!
    @IBOutlet weak var roomBeac: UILabel!
    @IBOutlet weak var imgBeac: UIImageView!
    @IBOutlet weak var passAcclbl: UILabel!
    @IBOutlet weak var nextQueueLbl: UILabel!
    
    let locationManager = CLLocationManager()
    
    
    
    var reportTimer = Timer()

    //@IBOutlet var submitBtn: UIButton!
    
    var imagePicker : UIImagePickerController!
    
    var passedRes: String = ""
    var passedRoom: String = ""
    var passResImg: UIImage = UIImage()
    var nextPassedRes: String = ""
    var nextPassedRoom: String = ""
    var timer = Timer()
    var counter = 0.0
    var timerString: String = ""
    var selectedBeacon: CLBeacon?
    var progress: Double = 0
    var selectedBeacAcc: Double = 0.0
    
    
    
    
    let timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .full, timeStyle: .full)
    
    @objc func runTimer(){
        counter += 0.1
        let flooredCounter = Int(floor(counter))
        
        let hour = flooredCounter / 3600
        
        let minute = (flooredCounter % 3600) / 60
        var minuteString = "\(minute)"
        if minute < 10 {
            minuteString = "0\(minute)"
        }
        
        let second = (flooredCounter % 3600) % 60
        var secondString = "\(second)"
        if second < 10 {
            secondString = "0\(second)"
        }
        
        let finalTime = "\(hour):\(minuteString):\(secondString)"
        timerLbl.text = finalTime
        timerString = finalTime
    }
    
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameBeac.text = passedRes
        roomBeac.text = passedRoom
        imgBeac.image = passResImg
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
        
        pickerCtrl.dataSource = self
        pickerCtrl.delegate = self
        incidentImgView.layer.masksToBounds = true
        incidentImgView.layer.cornerRadius = incidentImgView.frame.size.width/2
        incidentImgView.isUserInteractionEnabled = true
        incidentImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onImage)))
        
        if(nextPassedRes == "" && nextPassedRoom == ""){
            nextQueueLbl.text = "No one is present in queue to check"
        }else{
            if(nextQueueLbl.text != nil){
                nextQueueLbl.text = "Next Queue: \(nextPassedRes) in room: \(nextPassedRoom)"
            }else{
                nextQueueLbl.text = "No one is present in queue to check"
            }
        }
        
        locationManager.delegate = self
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways){
            locationManager.requestAlwaysAuthorization()
        }
        let beaconRegion = CLBeaconRegion(proximityUUID: selectedBeacon!.proximityUUID, major: selectedBeacon?.major as! CLBeaconMajorValue, minor: selectedBeacon?.minor as! CLBeaconMinorValue, identifier: "passedbeacon")
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
        locationManager.startUpdatingLocation()
        selectedBeacAcc = calculateAccuracy(txPower: -71, rssi: Double(selectedBeacon!.rssi))
       
        
        scheduledTimerWithTimeInterval()
        
        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let beaconRegion = CLBeaconRegion(proximityUUID: selectedBeacon!.proximityUUID, major: selectedBeacon?.major as! CLBeaconMajorValue, minor: selectedBeacon?.minor as! CLBeaconMinorValue, identifier: "passedbeacon")
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
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
    
    
    
    
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 60 seconds
        reportTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(submitReport), userInfo: nil, repeats: true)
    }
    
    
    var cause:Int = 0
    var causeString:String = ""
    
    var roomIndex : Int = -1
    
    let causeDataSource = ["Needs to refill medicine now", "Needs something to eat...", "Needs something to drink...", "Needs to go out ...", "was cold, provided with care", "headache, give headache medicine..."]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return causeDataSource.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        causeString = causeDataSource[row]
        return causeString
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
    
    
    @objc func submitReport() {
        
        print(selectedBeacAcc)
        if selectedBeacAcc > 4.0 {
            
            counter = 0.0
            timer.invalidate()
            
            let ref: DatabaseReference = Database.database().reference()
            guard let userID = Auth.auth().currentUser?.uid else {return}
            
            guard let notesgen = notesTxtArea.text else {return}
            
            guard let reportgen = reportTxtArea.text,
                !reportgen.isEmpty else {
                    showMessage(title: "Oops", message: "Please enter some report")
                    return
            }
            guard let incidentimage = incidentImgView.image else {
                showMessage(title:"Oops", message: "Please select image")
                return
            }
            
            
            SVProgressHUD.show()
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imagename = String(describing: Date()).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "+", with: "")
            guard let imageData = incidentimage.jpegData(compressionQuality: 0.5) else {return}
            
            // Create a reference to the file you want to upload
            let riversRef = storageRef.child("/report/\(imagename).jpg")
            
            _ = riversRef.putData(imageData, metadata: nil) { (metadata, error) in
                SVProgressHUD.dismiss()
                guard metadata != nil else {
                    // Uh-oh, an error occurred!
                    self.showMessage(title: "Oops", message: error?.localizedDescription ?? "Something went wrong")
                    return
                }
                // You can also access to download URL after upload.
                riversRef.downloadURL { (url, error) in
                    guard url != nil else {
                        // Uh-oh, an error occurred!
                        self.showMessage(title: "Oops", message: error?.localizedDescription ?? "Something went wrong")
                        return
                    }
                    ref.child("reports").childByAutoId().setValue(["empName": userID, "notes": notesgen,"cause": self.causeString,"report": reportgen, "incidentimage" : url?.absoluteString ?? "", "room" : self.passedRoom, "name" : self.passedRes, "timeTaken": self.timerString, "timeStamp": self.timestamp])
                }
            }
            
            let solutionVC = SolutionViewController()
            solutionVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.dismiss(animated: false, completion: nil)
            
            
            
        }
    }
 
    /*
    func printAccuracy() {
        
    }
    
    
     
     
    @objc func submitReport(){
    
    for item in items {
        let acc = item.calculateAccuracy(txPower: -70, rssi: Double(selectedBeacon?.rssi ?? 0))
        print(acc)
        let prox = selectedBeacon?.proximity ?? .unknown
        if acc > 3.0 {
            
            counter = 0.0
            timer.invalidate()
            
            let ref: DatabaseReference = Database.database().reference()
            guard let userID = Auth.auth().currentUser?.uid else {return}
            
            guard let notesgen = notesTxtArea.text else {return}
            
            guard let reportgen = reportTxtArea.text,
                !reportgen.isEmpty else {
                    showMessage(title: "Oops", message: "Please enter some report")
                    return
            }
            guard let incidentimage = incidentImgView.image else {
                showMessage(title:"Oops", message: "Please select image")
                return
            }
            
            
            SVProgressHUD.show()
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imagename = String(describing: Date()).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "+", with: "")
            guard let imageData = incidentimage.jpegData(compressionQuality: 0.5) else {return}
            
            // Create a reference to the file you want to upload
            let riversRef = storageRef.child("/report/\(imagename).jpg")
            
            _ = riversRef.putData(imageData, metadata: nil) { (metadata, error) in
                SVProgressHUD.dismiss()
                guard metadata != nil else {
                    // Uh-oh, an error occurred!
                    self.showMessage(title: "Oops", message: error?.localizedDescription ?? "Something went wrong")
                    return
                }
                // You can also access to download URL after upload.
                riversRef.downloadURL { (url, error) in
                    guard url != nil else {
                        // Uh-oh, an error occurred!
                        self.showMessage(title: "Oops", message: error?.localizedDescription ?? "Something went wrong")
                        return
                    }
                    ref.child("reports").childByAutoId().setValue(["empName": userID, "notes": notesgen,"cause": self.causeString,"report": reportgen, "incidentimage" : url?.absoluteString ?? "", "room" : self.passedRoom, "name" : self.passedRes, "timeTaken": self.timerString, "timeStamp": self.timestamp])
                }
            }
            
            self.dismiss(animated: true, completion: nil)

            
        } else {
            print("couldnt submit")
        }
    }
    
        } */
    
    
    


    @IBAction func submit_pressed(_ sender: UIButton) {
        counter = 0.0
        timer.invalidate()
        
        let ref: DatabaseReference = Database.database().reference()
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        guard let notesgen = notesTxtArea.text else {return}
        
        guard let reportgen = reportTxtArea.text,
            !reportgen.isEmpty else {
                showMessage(title: "Oops", message: "Please enter some report")
                return
        }
        guard let incidentimage = incidentImgView.image else {
            showMessage(title:"Oops", message: "Please select image")
            return
        }
        
        
        SVProgressHUD.show()
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagename = String(describing: Date()).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "+", with: "")
        guard let imageData = incidentimage.jpegData(compressionQuality: 0.5) else {return}
        
        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("/report/\(imagename).jpg")
        
        _ = riversRef.putData(imageData, metadata: nil) { (metadata, error) in
            SVProgressHUD.dismiss()
            guard metadata != nil else {
                // Uh-oh, an error occurred!
                self.showMessage(title: "Oops", message: error?.localizedDescription ?? "Something went wrong")
                return
            }
            // You can also access to download URL after upload.
            riversRef.downloadURL { (url, error) in
                guard url != nil else {
                    // Uh-oh, an error occurred!
                    self.showMessage(title: "Oops", message: error?.localizedDescription ?? "Something went wrong")
                    return
                }
                ref.child("reports").childByAutoId().setValue(["empName": userID, "notes": notesgen,"cause": self.causeString,"report": reportgen, "incidentimage" : url?.absoluteString ?? "", "room" : self.passedRoom, "name" : self.passedRes, "timeTaken": self.timerString, "timeStamp": self.timestamp])
            }
        }
        
        let solutionVC = SolutionViewController()
        solutionVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.dismiss(animated: false, completion: nil)
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func addReport(){
        
    }

}

extension ReportVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let edited = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            incidentImgView.image = edited
        } else if let original = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            incidentImgView.image = original
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

extension ReportVC : CLLocationManagerDelegate {
    
   
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
         let beaconRegion = CLBeaconRegion(proximityUUID: selectedBeacon!.proximityUUID, major: selectedBeacon?.major as! CLBeaconMajorValue, minor: selectedBeacon?.minor as! CLBeaconMinorValue, identifier: "passedbeacon")
        self.locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
         let beaconRegion = CLBeaconRegion(proximityUUID: selectedBeacon!.proximityUUID, major: selectedBeacon?.major as! CLBeaconMajorValue, minor: selectedBeacon?.minor as! CLBeaconMinorValue, identifier: "passedbeacon")
        print("Selected beacon found")
        self.locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    
    
    
}

