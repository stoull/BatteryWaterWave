//
//  HUTDashProgress.swift
//  WaterWave
//
//  Created by Hut on 2022/10/21.
//

import UIKit

class HUTDashProgress: UIView {
    
    // 当前值
    private var valuePercentageStorage: CGFloat = 0.8
    var valuePercentage: CGFloat {
        get {return valuePercentageStorage}
        set {
            valuePercentageStorage = newValue
            // 计算当前值的位置
            valueEndDeg = (1.0-valuePercentageStorage)*totalDeg
            self.updateValuePath()
        }
    }
    
    let lineWidth: CGFloat = 3.5
    var valueLineColor: UIColor = kHexColor("#82EB0F")
    var emptyLineColor: UIColor = kHexColorA("#333333", 0.1)
    
    private var backgroundShapeLayer: CAShapeLayer = CAShapeLayer()
    private var valueShapeLayer: CAShapeLayer = CAShapeLayer()
    
    // 电量短线图
    private var valueDashPath: UIBezierPath = UIBezierPath()
    // 无电量短线图
    private var emptyDashPath: UIBezierPath = UIBezierPath()
    //
    private var fullDashPath: UIBezierPath = UIBezierPath()
    
    // 极坐标对应在 CGContext 上的坐标
    private var totalDeg: CGFloat = -210.0
    private var valueEndDeg: CGFloat = 0.0
    // 总共短线的个数，如果设置了这一个，gapDeg将会根据这个计算
    private var totalDashCount: Int = 34
    // 间隔的角度
    private var gapDeg: CGFloat = 7.0
    
    private var radius: CGFloat = 90.0
    private let lengthPrecent: CGFloat = 0.2
    
    // 整体图像的角度位移
    lazy var offsetDeg: CGFloat = {
        return (abs(totalDeg)-180)*0.5
    }()
    
    // 当前动画所到的位置
    private var animatingCurrentDeg: CGFloat = -240
    // 动画走完整个弧度的时间
    private var animationDuraitonStorage: Double = 1.4
    var animationDuraiton: Double {
        get {return animationDuraitonStorage}
        set {
            animationDuraitonStorage = newValue
            redrawTimeInterval = animationDuraitonStorage/Double(totalDashCount)
            self.startAnimation()
        }
    }
    
    private var redrawTimeInterval: Double = 0.04
    
    var isAnimating: Bool = false
    
    var animationTimer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 计算当前值的位置
        valueEndDeg = (1.0-valuePercentageStorage)*totalDeg
        
        gapDeg = abs(totalDeg)/CGFloat(totalDashCount)
        
        radius = self.bounds.height*0.7
        
        redrawTimeInterval = animationDuraitonStorage/Double(totalDashCount)
        
        self.updateStilllPaths()
        
        self.createShaperLayers()
        
        self.backgroundColor = UIColor.clear
        
        self.layer.addSublayer(backgroundShapeLayer)
        self.layer.addSublayer(valueShapeLayer)
    }
    
    func updateValuePath() {
        self.updateStilllPaths()
        
        self.valueShapeLayer.strokeColor = valueLineColor.cgColor
        self.valueShapeLayer.path = valueDashPath.cgPath
        self.setNeedsDisplay()
    }
    
    
    func startAnimation() {
        isAnimating = true
        animatingCurrentDeg = 0
        if let animationTimer = animationTimer {
            animationTimer.invalidate()
        }
        animationTimer = Timer.scheduledTimer(timeInterval: redrawTimeInterval, target: self, selector: #selector(animateWave), userInfo: nil, repeats: true)
        animationTimer?.fire()
    }
    
    func stopAnimation() {
        isAnimating = false
        animationTimer?.invalidate()
        animationTimer=nil
        self.updateValuePath()
    }
    
    @objc func animateWave() {
        self.setNeedsDisplay()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        if isAnimating {
            self.drawAnimationImage(in: ctx)
        } else {
            self.updateValuePath()
        }
    }
    
    /// 绘制有值处的动画
    func drawAnimationImage(in ctx: CGContext) {
        let centerPoint = CGPoint(x: self.bounds.width*0.5, y: self.bounds.height*0.6)

        if animatingCurrentDeg < 2 {
            
            let dDeg = animatingCurrentDeg
            
            let offsetDeg = dDeg+offsetDeg
            let dRad = HUTHelper.deg2rad(offsetDeg)
            let dX = radius*cos(dRad)
            let dY = radius*sin(dRad)
            let sPoint = CGPoint(x: centerPoint.x+dX, y: centerPoint.y+dY)
            let ePoint = CGPoint(x: dX*(1-lengthPrecent)+centerPoint.x, y: dY*(1-lengthPrecent)+centerPoint.y)
            if dDeg < self.valueEndDeg {
                valueDashPath.move(to: sPoint)
                valueDashPath.addLine(to: ePoint)
            } else {
                emptyDashPath.move(to: sPoint)
                emptyDashPath.addLine(to: ePoint)
            }
            animatingCurrentDeg = animatingCurrentDeg + gapDeg
        } else {
            animatingCurrentDeg = self.totalDeg
            
            valueDashPath.removeAllPoints()
            emptyDashPath.removeAllPoints()
        }
        
        self.valueShapeLayer.strokeColor = valueLineColor.cgColor
        self.valueShapeLayer.path = valueDashPath.cgPath
    }
    
    func createShaperLayers() {
        self.valueShapeLayer.frame = self.bounds
        self.backgroundShapeLayer.frame = self.bounds
        
        self.backgroundShapeLayer.lineWidth = lineWidth
        self.valueShapeLayer.lineWidth = lineWidth
        
        self.backgroundShapeLayer.strokeColor = emptyLineColor.cgColor
        self.backgroundShapeLayer.path = fullDashPath.cgPath
        
        self.valueShapeLayer.strokeColor = valueLineColor.cgColor
        self.valueShapeLayer.path = valueDashPath.cgPath
    }
    
    private func updateStilllPaths() {
        let centerPoint = CGPoint(x: self.bounds.width*0.5, y: self.bounds.height*0.6)
        
        fullDashPath.removeAllPoints()
        valueDashPath.removeAllPoints()
        emptyDashPath.removeAllPoints()
        
        // 获取paths
        for dDeg in stride(from: totalDeg, to: 1, by: gapDeg) {
            let offsetDeg = dDeg+offsetDeg
            let dRad = HUTHelper.deg2rad(offsetDeg)
            let dX = radius*cos(dRad)
            let dY = radius*sin(dRad)
            let sPoint = CGPoint(x: centerPoint.x+dX, y: centerPoint.y+dY)
            let ePoint = CGPoint(x: dX*(1-lengthPrecent)+centerPoint.x, y: dY*(1-lengthPrecent)+centerPoint.y)
            if dDeg < self.valueEndDeg {
                valueDashPath.move(to: sPoint)
                valueDashPath.addLine(to: ePoint)
            } else {
                emptyDashPath.move(to: sPoint)
                emptyDashPath.addLine(to: ePoint)
            }
            fullDashPath.move(to: sPoint)
            fullDashPath.addLine(to: ePoint)
        }
    }
}
