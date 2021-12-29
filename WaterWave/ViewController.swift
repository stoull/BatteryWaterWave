//
//  ViewController.swift
//  WaterWave
//
//  Created by Hut on 2021/12/29.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var slider: UISlider!
    
    var waveView: HUTWaveView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let screenSize = UIScreen.main.bounds.size
        
        let waveSize = CGSize(width: 160.0, height: 160.0)
        let originPoint = CGPoint(x: (screenSize.width-waveSize.width)*0.5, y: 160.0)
        waveView = HUTWaveView(frame: CGRect(origin: originPoint, size: waveSize))
        self.view.insertSubview(waveView, at: 0)
        
        slider.setValue(0.5, animated: true)
    }
    
    
    @IBAction func sliderDidSlide(_ sender: UISlider) {
        waveView.wavePercentage = CGFloat(sender.value)
    }
    
}

