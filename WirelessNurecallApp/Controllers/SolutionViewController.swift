//
//  SolutionViewController.swift
//  WirelessNurecallApp
//
//  Created by Saksham Saraswat on 6/18/19.
//  Copyright © 2019 Saksham. All rights reserved.
//

import UIKit


let kMaxRadius: CGFloat = 300
let kMaxDuration: TimeInterval = 10


class SolutionViewController: UIViewController {
    
    
    @IBOutlet weak var sourceView: UIImageView!
    
    let pulsator = Pulsator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sourceView.layer.superlayer?.insertSublayer(pulsator, below: sourceView.layer)
        setupInitialValues()
        pulsator.start()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.layoutIfNeeded()
        pulsator.position = sourceView.layer.position
    }

    private func setupInitialValues() {
        pulsator.numPulse = 5
        pulsator.radius = CGFloat(0.7) * kMaxRadius
        pulsator.animationDuration = Double(0.5) * kMaxDuration
        pulsator.backgroundColor = UIColor(
            red: CGFloat(0),
            green: CGFloat(0.455),
            blue: CGFloat(0.756),
            alpha: CGFloat(1)).cgColor
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
