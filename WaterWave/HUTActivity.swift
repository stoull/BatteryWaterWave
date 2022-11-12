//
//  HUTActivity.swift
//  WaterWave
//
//  Created by Hut on 2022/10/29.
//

import UIKit

class HUTActivity: UIView {

    var numberOfSegments: Int =  12
    var indicatorRadius: CGFloat = 20.0
    var indicatorScale: Float = 1.0
    var brightestAlpha: CGFloat = 1.0
    var darkestAlpha: CGFloat = 0.5
    var segmentRadius: CGFloat = 3.0
    
    var frameIndex: Int = 0
    
    var animationTimer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        animationTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(startAnimation), userInfo: nil, repeats: true)
        animationTimer?.fire()
        self.backgroundColor = UIColor.black
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func startAnimation() {
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        print("xxxxxx ")
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        
        ctx.translateBy(x: bounds.width*0.5, y: bounds.width*0.5)
        ctx.scaleBy(x: CGFloat(indicatorScale), y: CGFloat(indicatorScale))
        
        let PI2 = Double.pi*2.0
        // Shading
        let semiAmplitude = (self.brightestAlpha - self.darkestAlpha)*0.5
        let alphaAxis = self.darkestAlpha + semiAmplitude
        let frameAngle: CGFloat = (CGFloat(frameIndex)/CGFloat(numberOfSegments))*PI2

        // Offset by half of a segment
        let angleOffset:CGFloat = (0.5/CGFloat(self.numberOfSegments)) * PI2
        
        ctx.clear(self.bounds)
        
        for segmentIndex in 0...numberOfSegments {
            let alphaAngle: CGFloat = CGFloat(self.numberOfSegments - segmentIndex)/CGFloat(self.numberOfSegments)*PI2
            
            let alpha = alphaAxis + (sin(frameAngle + alphaAngle) * semiAmplitude)
            let segmentAngle = angleOffset + CGFloat(CGFloat(segmentIndex)/CGFloat(self.numberOfSegments)*PI2)
            let segmentCenter = CGPoint(x: self.indicatorRadius*cos(segmentAngle), y: self.indicatorRadius*sin(segmentAngle))
            
            let segmentStartPoint = CGPoint(x: segmentCenter.x - (self.segmentRadius*cos(segmentAngle)), y: segmentCenter.y - (self.segmentRadius*sin(segmentAngle)))
            let segmentEndPoint = CGPoint(x: segmentCenter.x + (self.segmentRadius*cos(segmentAngle)), y: segmentCenter.y + (self.segmentRadius*sin(segmentAngle)))
            
            let path = UIBezierPath()
            path.move(to: segmentStartPoint)
            path.addLine(to: segmentEndPoint)
            
            ctx.addPath(path.cgPath)
            ctx.setLineWidth(2.0)
            ctx.setLineCap(.round)
//            ctx.setStrokeColor(UIColor.red.cgColor)
            ctx.setStrokeColor(UIColor.init(white: 1.0, alpha: alpha).cgColor)
            ctx.strokePath()
        }
        
        if frameIndex > numberOfSegments {
            frameIndex = 0
        } else {
            frameIndex += 1
        }
    }

}
