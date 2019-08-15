//
//  MainVC.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 3/21/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase

class MainVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pickerCtrl: UIPickerView!
    
    @IBOutlet weak var causeLbl: UILabel!
    
    @IBOutlet weak var reportTxtView: UITextView!
    
    
    @IBOutlet weak var notesTextView: UITextView!
    
    
    @IBOutlet weak var imgView: UIImageView!
    
    
    @IBOutlet weak var imgBtn: UIButton!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var timerLbl: UILabel!
    
    @IBOutlet weak var timerStartbtn: UIButton!
    
    @IBOutlet weak var timerStopbtn: UIButton!
    
    @IBOutlet weak var timerPauseBtn: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    var report = [Report]()
    
    var cause:Int = 0
    var causeString:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerCtrl.dataSource = self
        pickerCtrl.delegate = self
        self.imgBtn.layer.cornerRadius = 20
        self.submitBtn.layer.cornerRadius = 20
        self.imgView.image = nil
        self.causeLbl.isHidden = true
        timerStopbtn.isEnabled = false
        timerPauseBtn.isEnabled = false
        timerStartbtn.isEnabled = true
        timerLbl.layer.cornerRadius = 5.0
        timerLbl.layer.masksToBounds = true
        
        timerStartbtn.layer.cornerRadius = timerStartbtn.bounds.width / 2.0
        timerStartbtn.layer.masksToBounds = true
        
        timerStopbtn.layer.cornerRadius = timerStartbtn.bounds.width / 2.0
        timerStopbtn.layer.masksToBounds = true
        
        timerPauseBtn.layer.cornerRadius = timerStartbtn.bounds.width / 2.0
        timerPauseBtn.layer.masksToBounds = true

        // Do any additional setup after loading the view.
    }
    
    let dataSource = ["Needs to refill medicine now", "Needs something to eat...", "Needs something to drink...", "Needs to go out ...", "was cold, provided with care", "headache, give headache medicine..."]

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        causeLbl.isHidden = false
        causeLbl.text = dataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        causeString = dataSource[row]
        return causeString
    }
    
    @IBAction func onSubmitTapped(_ sender: UIButton) {
        
        let dateString = String(describing: Date())
        var reportTxt = reportTxtView.text
        var reportNote = notesTextView.text
        
        let parameters = ["cause":          causeString,
                          "reportMsg":      reportTxt,
                          "reportNotes":    reportNote,
                          "date":           dateString]
        
        DatabaseService.shared.reportReference.childByAutoId().setValue(parameters)
        
        
    }
    
    
    @IBAction func onPicTapped(_ sender: Any) {
        
        let msg: String = "Please select an image source"
        let alert = UIAlertController(title: "Add image through", message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                self.imagePicker.allowsEditing = false
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.imagePicker.cameraCaptureMode = .photo
                self.imagePicker.modalPresentationStyle = .fullScreen
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else
            {
                print("No camera found on the device")
            }
            
        }))
        
        self.present(alert, animated: true)
        
    }
    
    var imgReference: StorageReference {
        return Storage.storage().reference().child("images")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        let selImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        imgView.image = selImage
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    var timer = Timer()
    var isTimerRunning = false
    var counter = 0.0
    
    
    @IBAction func timerStartTap(_ sender: Any) {
        
        if !isTimerRunning{
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
        }
        
        timerStopbtn.isEnabled = true
        timerPauseBtn.isEnabled = true
        timerStartbtn.isEnabled = false
        
    }
    
    @objc func runTimer(){
        counter += 0.1
        
        let flooredCounter = Int(floor(counter))
        let hour = flooredCounter / 3600
        
        let minute = (flooredCounter % 3600) / 60
        var minuteString = "\(minute)"
        if minute < 10 {
            minuteString = "0\(minute)"
        }
        
        let second = (flooredCounter % 3600) / 60
        var secondString = "\(second)"
        if minute < 10 {
            minuteString = "0\(second)"
        }
        
        let decisecond = String(format: "%.1f", counter).components(separatedBy: ".").last!
        
        timerLbl.text = "\(hour):\(minuteString):\(secondString).\(decisecond)"
        
        
    }
    
    
    
    @IBAction func timerPauseTap(_ sender: Any) {
        
        timerStopbtn.isEnabled = true
        timerStartbtn.isEnabled = true
        timerPauseBtn.isEnabled = false
        
        isTimerRunning = false
        timer.invalidate()
        
    }
    
    

    @IBAction func timerStopTap(_ sender: Any) {
        
        timer.invalidate()
        isTimerRunning = false
        counter = 0.0
        
        timerLbl.text = "00:00:00.0"
        timerStopbtn.isEnabled = false
        timerPauseBtn.isEnabled = false
        timerStartbtn.isEnabled = true
        
    }
    
}
