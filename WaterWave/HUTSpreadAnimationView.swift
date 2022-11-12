//
//  HUTSpreadAnimationView.swift
//  AnimationCraft
//
//  Created by Kevin on 2022/11/11.
//

import UIKit

final class HUTSpreadAnimationView: UIView {
    
    var centerImageView: UIImageView = UIImageView()
    var centerCircelImageView: UIImageView = UIImageView()
    
    var centerImageViewPercentage: CGFloat = 0.2
    var centerCircelImageViewPercentage: CGFloat = 0.3
    
    var shrinkDuration: CGFloat = 1.0
    var spreadDuration: CGFloat = 5.0
    
    private var spreadGradientLayer: CAGradientLayer!
    private var spreadCircePathlLayer: CAShapeLayer!
    
    // From the center to the edge
//    private var spreadGradientColors:[CGColor] = [UIColor.blue.cgColor, UIColor.red.cgColor]
    private var spreadGradientColors:[CGColor] = [kHexColorA("1ED7FF", 1.0).cgColor, kHexColorA("1ED7FF", 0.0).cgColor]
    private var strokeLineWidth: CGFloat = 3.0

    private var viewHalfSize : CGFloat = 0.0
    private var validViewShowRadius: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        spreadCircles = []
        self.setupViewsWith(frame: frame)
        self.viewHalfSize = frame.size.width*0.5
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        spreadCircles = []
        setupViewsWithAutoLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        spreadGradientLayer.frame = CGRect(origin: .zero, size: frame.size)
        spreadCircePathlLayer.frame = CGRect(origin: .zero, size: frame.size)
        spreadGradientLayer.mask = spreadCircePathlLayer
        self.viewHalfSize = frame.size.width*0.5
        self.validViewShowRadius = self.viewHalfSize - self.strokeLineWidth*0.5
    }
    
    let kShrinkAnimationId = "kShrinkAnimation"
    let kSpreadAnimationId = "kSpreadAnimation"
    
    func startAnimation() {
        self.startShrinkAnimation()
        
        if spreadGradientLayer.isHidden == true {
            spreadGradientLayer.isHidden = false
        }
    }
    
    func startShrinkAnimation() {
        let shrinkAnimation = createKeyFrameAnimation(keyPath: "transform.scale", values: [1.0, 0.8, 1.0], keytimes: [0.0, 0.5, 1.0])
        let opacityAnimation = createKeyFrameAnimation(keyPath: "opacity", values: [1.0, 0.2, 1.0], keytimes: [0.0, 0.5, 1.0])
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [shrinkAnimation, opacityAnimation]
        animationGroup.timingFunction = CAMediaTimingFunction(name: .linear)
        animationGroup.duration = shrinkDuration
        animationGroup.repeatCount = 1
        animationGroup.setValue(kShrinkAnimationId, forKey: "animationID")
        animationGroup.delegate = self
        
        let animationGroup2 = CAAnimationGroup()
        animationGroup2.animations = [shrinkAnimation, opacityAnimation]
        animationGroup2.timingFunction = CAMediaTimingFunction(name: .linear)
        animationGroup2.duration = shrinkDuration
        animationGroup2.repeatCount = 1
        
        centerImageView.layer.add(animationGroup, forKey: kShrinkAnimationId)
        centerCircelImageView.layer.add(animationGroup2, forKey: kShrinkAnimationId)
    }
    
    func addANewSpreadAnimation() {
        let spreadPath = HUTSpreadCircle(size: bounds.size, radius: self.bounds.size.width*centerCircelImageViewPercentage*0.44)
        spreadCircles.append(spreadPath)
        if self.spreadAnimationTimer == nil {
            setupSpreadAnimationTimer()
        }
    }
    
    var spreadCircles: [HUTSpreadCircle] = []
    var spreadAnimationTimer: Timer? = nil
    var spreadAnimationRadius: CGFloat = 0.0
    func setupSpreadAnimationTimer() {
        spreadAnimationTimer?.invalidate()
        spreadAnimationTimer = nil
        
        let distance = (self.bounds.width - self.bounds.width*centerCircelImageViewPercentage)*0.5
        let speed = spreadDuration/distance

        spreadAnimationRadius =  self.bounds.size.width*centerCircelImageViewPercentage*0.44
        spreadAnimationTimer = Timer.scheduledTimer(timeInterval: speed, target: self, selector: #selector(processingSpeadAnimation), userInfo: nil, repeats: true)
        spreadAnimationTimer?.fire()
    }
    
    func createKeyFrameAnimation(keyPath: String, values: [Any]?, keytimes: [NSNumber]?) -> CAKeyframeAnimation {
        let scaleAni = CAKeyframeAnimation()
        scaleAni.keyPath = keyPath
        scaleAni.values = values
        scaleAni.keyTimes = keytimes
        scaleAni.duration = shrinkDuration
        scaleAni.repeatCount = Float(CGFloat.greatestFiniteMagnitude)
        return scaleAni
    }
    
    func createAShapeLayer(size: CGSize, strokeColor: UIColor) -> CAShapeLayer {
        let layer: CAShapeLayer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = strokeLineWidth
        layer.backgroundColor = UIColor.clear.cgColor
        let spreadPath = HUTSpreadCircle(size: bounds.size, radius: self.bounds.size.width*centerCircelImageViewPercentage*0.44)
        layer.path = spreadPath.circlePath.cgPath
        layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        return layer
    }
    
    func createAGradientLayer(size: CGSize, colors: [CGColor]) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.type = .radial
        gradient.frame = frame
        gradient.colors = colors // [UIColor.blue.cgColor, UIColor.red.cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
//        gradient.endPoint = CGPoint(x: 1, y: 1)
        let endY = 0.5 + self.frame.size.width/self.frame.size.height*0.5
        gradient.endPoint = CGPoint(x: 1, y: endY)
        return gradient
    }
    
    @objc func processingSpeadAnimation() {
        guard self.spreadCircles.count > 0 else { return }
        
        var allPath: UIBezierPath?
        let validCircles = self.spreadCircles.filter{$0.radius < validViewShowRadius}
        self.spreadCircles = validCircles
        
        for i in 0..<self.spreadCircles.count {
            let circle = self.spreadCircles[i]
            circle.radius += 1
            if i == 0 {
                allPath = circle.circlePath
            } else {
                allPath?.append(circle.circlePath)
            }
        }
        
        if let appPath = allPath?.cgPath {
            
            spreadCircePathlLayer.path = appPath
            spreadGradientLayer.mask = spreadCircePathlLayer
            
        }
    }
    
     private func setupViewsWithAutoLayout() {
        centerImageView.contentMode = .scaleAspectFit
        centerCircelImageView.contentMode = .scaleAspectFit
        self.addSubview(centerCircelImageView)
        self.addSubview(centerImageView)
        centerImageView.image = UIImage(named: "DeviceAdding_bluetooth_light")
        centerCircelImageView.image = UIImage(named: "DeviceAdding_circel_light")
        
        centerImageView.translatesAutoresizingMaskIntoConstraints = false
        centerCircelImageView.translatesAutoresizingMaskIntoConstraints = false
        
        centerImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        centerImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        centerImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: centerImageViewPercentage).isActive = true
        centerImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: centerImageViewPercentage).isActive = true
        
        centerCircelImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        centerCircelImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        centerCircelImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: centerCircelImageViewPercentage).isActive = true
        centerCircelImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: centerCircelImageViewPercentage).isActive = true
         
         spreadGradientLayer = self.createAGradientLayer(size: frame.size, colors: spreadGradientColors)
         spreadCircePathlLayer = self.createAShapeLayer(size: frame.size, strokeColor: kHexColor("1ED7FF"))
         spreadGradientLayer.mask = spreadCircePathlLayer
         self.layer.addSublayer(spreadGradientLayer)
         spreadGradientLayer.isHidden = true
    }
    
    private func setupViewsWith(frame: CGRect) {
        centerImageView.contentMode = .scaleAspectFit
        centerCircelImageView.contentMode = .scaleAspectFit
        self.addSubview(centerImageView)
        self.addSubview(centerCircelImageView)
        centerImageView.image = UIImage(named: "DeviceAdding_bluetooth_light")
        centerCircelImageView.image = UIImage(named: "DeviceAdding_circel_light")
        
        let cenImgWidth = frame.width*centerImageViewPercentage
        let cenCirceWidth = frame.width*centerCircelImageViewPercentage
        
        let originImg = (frame.width - cenImgWidth)*0.5
        let originCircel = (frame.width - cenCirceWidth)*0.5
        
        centerImageView.frame = CGRect(x: originImg, y: originImg, width: cenImgWidth, height: cenImgWidth)
        centerCircelImageView.frame = CGRect(x: originCircel, y: originCircel, width: cenCirceWidth, height: cenCirceWidth)
        
        spreadGradientLayer = self.createAGradientLayer(size: frame.size, colors: spreadGradientColors)
        spreadCircePathlLayer = self.createAShapeLayer(size: frame.size, strokeColor: kHexColor("1ED7FF"))
        spreadGradientLayer.mask = spreadCircePathlLayer
        self.layer.addSublayer(spreadGradientLayer)
        spreadGradientLayer.isHidden = true
    }
    
}

extension HUTSpreadAnimationView: CAAnimationDelegate{
    func animationDidStart(_ anim: CAAnimation) {
        if let animId = anim.value(forKey: "animationID") as? String,
           animId == kShrinkAnimationId {
            self.addANewSpreadAnimation()
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let animId = anim.value(forKey: "animationID") as? String,
           animId == kShrinkAnimationId {
            self.startAnimation()
        } else {
            
        }
    }
}
