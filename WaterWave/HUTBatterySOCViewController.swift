//
//  HUTBatterySOCViewController.swift
//  WaterWave
//
//  Created by Kevin on 2023/8/25.
//

import UIKit

class HUTBatterySOCViewController: UIViewController {

    @IBOutlet weak var batteryView: HUTBatterySOCView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.white
        
        batteryView.backgroundColor = UIColor.white
        
        batteryView.isPlaceHolder = false
        batteryView.batterySOC = 0.8
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
