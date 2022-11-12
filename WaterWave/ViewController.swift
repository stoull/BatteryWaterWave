//
//  ViewController.swift
//  WaterWave
//
//  Created by Hut on 2021/12/29.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var activityView: UIView!
    
    @IBOutlet weak var contianer_1: UIView!
    @IBOutlet weak var contianer_2: UIView!

    @IBOutlet weak var slider_1: UISlider!
    @IBOutlet weak var slider_2: UISlider!
    @IBOutlet weak var speedLabel: UILabel!
    
    var waveView: HUTWaveView!
    var dashProgress: HUTDashProgress!
    @IBOutlet weak var spreadAnimationView: HUTSpreadAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let screenSize = UIScreen.main.bounds.size
        
        // 显示 半圆形dash进度图
        dashProgress = HUTDashProgress(frame: CGRect(origin: CGPoint(x: 0.0, y: 30.0), size: CGSize(width: UIScreen.main.bounds.size.width, height: 150)))
        contianer_1.addSubview(dashProgress)
        
        speedLabel.text = "1.4s"
        
        // 显示水波图形示例
        let waveSize = CGSize(width: 160.0, height: 160.0)
        let originPoint = CGPoint(x: (screenSize.width-waveSize.width)*0.5, y: 20.0)
        waveView = HUTWaveView(frame: CGRect(origin: originPoint, size: waveSize))
        contianer_2.insertSubview(waveView, at: 0)
        slider_2.setValue(0.5, animated: true)
        
        activityView.addSubview(HUTActivity(frame: CGRect(origin: .zero, size: CGSize(width: 60.0, height: 60.0))))
        
        spreadAnimationView.startAnimation()
    }
    
    @IBAction func sliderDidSlide(_ sender: UISlider) {
        // 显示水波图形示例
        waveView.wavePercentage = CGFloat(sender.value)
    }
    
    // dash进度图 控制
    
    // 电量
    @IBAction func dashProgressSliderDidChange(_ sender: UISlider) {
        if sender.value < 0.1 {
            self.dashProgress.valueLineColor = kHexColor("#FF7878")
        } else if sender.value < 0.3 {
            self.dashProgress.valueLineColor = kHexColor("#FFAF32")
        } else {
            self.dashProgress.valueLineColor = kHexColor("#82EB0F")
        }
        self.dashProgress.valuePercentage = CGFloat(sender.value)
    }
    
    @IBAction func chargingButtonDidClick(_ sender: UIButton) {
        if sender.titleLabel?.text == "充电" {
            sender.setTitle("停止充电", for: .normal)
            self.dashProgress.startAnimation()
        } else {
            sender.setTitle("充电", for: .normal)
            self.dashProgress.stopAnimation()
        }
    }
    
    @IBAction func faultButtonDidClick(_ sender: UIButton) {
        if sender.titleLabel?.text == "低电量" {
            sender.setTitle("变正常", for: .normal)
            self.dashProgress.startAnimation()
        } else {
            sender.setTitle("变故障", for: .normal)
            self.dashProgress.stopAnimation()
        }
    }
    
    @IBAction func speedMinus(_ sender: Any) {
        dashProgress.animationDuraiton = dashProgress.animationDuraiton-0.1
        speedLabel.text = NSString(format: "%.1fs", dashProgress.animationDuraiton) as String
    }
    
    @IBAction func speedAdd(_ sender: Any) {
        dashProgress.animationDuraiton = dashProgress.animationDuraiton+0.1
        speedLabel.text = NSString(format: "%.1fs", dashProgress.animationDuraiton) as String
    }
    
}

