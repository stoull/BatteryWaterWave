//
//  HUTBatterySOCView.swift
//  WaterWave
//
//  Created by Kevin on 2023/8/25.
//

import UIKit

class HUTBatterySOCView: UIView {
    private enum kConstants {
        static let padding: CGSize = CGSize(width: 2.0, height: 2.0)
        static let mininumWidth: CGFloat = 20.0
        static let mininumHeight: CGFloat = 20.0
        static let lineWidth:CGFloat = 1.0
    }
    
    let outlineColor: UIColor = kHexColor("#8C8C8C")
    var batterySOC_S: CGFloat = 0.0
    var batterySOC: CGFloat {
        get {return batterySOC_S}
        set {
            let oldValue = batterySOC_S
            var rNewValue = newValue
            if newValue < 0 {
                rNewValue = 0.0
            } else if newValue > 1.0 {
                rNewValue = 1.0
            }
            batterySOC_S = rNewValue
            if oldValue != rNewValue {
                self.updateFrame(to: self.bounds)
                self.setNeedsDisplay()
            }
        }
    }
    
    var isPlaceHolder: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        updateFrame(to: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrame(to: self.frame)
    }
    
    private func initViews() {
        self.backgroundColor = UIColor.clear
    }
    
    private func updateFrame(to newFrame: CGRect) {
        batteryBoardPath = batteryOutlineBorderPath(size: newFrame.size)
        batterySOCPath = batterySOCPath(size: newFrame.size, batterySOC: batterySOC)
        batteryShadownPath = batterySOCShadowPath(size: newFrame.size, batterySOC: batterySOC)
    }

    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    
    var batteryBoardPath: UIBezierPath = UIBezierPath()
    var batterySOCPath: UIBezierPath = UIBezierPath()
    var batteryShadownPath: UIBezierPath = UIBezierPath()
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        if let subLayers = self.layer.sublayers {
            for subLayer in subLayers {
                subLayer.removeFromSuperlayer()
            }
        }
        
        // 画背景
        self.drawBackGroundShapeAndColor(context: ctx, bounds: self.bounds, bgColor: UIColor.white)

        let outLineStrokeLayer = CAShapeLayer()
        outLineStrokeLayer.frame = self.bounds
        outLineStrokeLayer.path = batteryBoardPath.cgPath
        outLineStrokeLayer.fillColor = UIColor.clear.cgColor
        outLineStrokeLayer.strokeColor = outlineColor.cgColor
        outLineStrokeLayer.lineWidth = kConstants.lineWidth
        

        var socStatus = HUTBatterySOCView.SOCStatus.init(batterySOC: batterySOC)
        if isPlaceHolder {
            socStatus = .placeHolder
            batterySOC = 1.0
        }
        
        if let lineGradient = lineGradient(startColor:socStatus.localizedInfo.gradientStartColor, endColor: socStatus.localizedInfo.gradientEndColor) {
            ctx.saveGState()
            ctx.addPath(batterySOCPath.cgPath)
            ctx.clip()
            ctx.drawLinearGradient(lineGradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: self.bounds.height), options: .drawsBeforeStartLocation)
            ctx.restoreGState()
        } else {
            let socFillLayer = CAShapeLayer()
            socFillLayer.frame = self.bounds
            socFillLayer.path = batterySOCPath.cgPath
            socFillLayer.fillColor = socStatus.localizedInfo.gradientStartColor.cgColor
            socFillLayer.strokeColor = UIColor.clear.cgColor
            self.layer.addSublayer(socFillLayer)
        }
        
        self.layer.addSublayer(outLineStrokeLayer)
        if !isPlaceHolder {
            let shadowLayer = CAShapeLayer()
            shadowLayer.frame = self.bounds
//            shadowLayer.shadowPath = batteryShadownPath.cgPath
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            shadowLayer.shadowRadius = 1.0
            shadowLayer.shadowOpacity = 1.0
            shadowLayer.shadowColor = socStatus.localizedInfo.shadowColor.cgColor
            shadowLayer.path = batteryShadownPath.cgPath
            shadowLayer.fillColor = UIColor.clear.cgColor
            shadowLayer.strokeColor = socStatus.localizedInfo.gradientEndColor.cgColor
            shadowLayer.lineWidth = 0.5
            self.layer.addSublayer(shadowLayer)
        }
    }
    
    func drawOutline() {
        
    }
    
    private func drawBackGroundShapeAndColor(context: CGContext, bounds: CGRect, bgColor: UIColor) {
        let backgroundRect = bounds
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(backgroundRect)
        let path = UIBezierPath(
            roundedRect: backgroundRect,
            byRoundingCorners: UIRectCorner.allCorners,
            cornerRadii: CGSize.zero
        )
        path.addClip()
        context.addPath(path.cgPath)
        context.setFillColor(bgColor.cgColor)
        context.fillPath()
    }

}

extension HUTBatterySOCView {
    /// 电池外框
    func batteryOutlineBorderPath(size: CGSize) -> UIBezierPath {
        let nobSize = CGSize(width: (14.0/50.0)*size.width, height: (2.5/80.0)*size.height)
        
        let nobRect = CGRect(origin: CGPoint(x: (size.width-nobSize.width)*0.5, y: kConstants.padding.height), size: nobSize)
        let outlinePath = UIBezierPath(roundedRect: nobRect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 4.0, height: 2.0))
        
        let realSize = CGSize(width: size.width - kConstants.padding.width*2, height: size.height - kConstants.padding.height*2-nobSize.height)
        let batteryRect = CGRect(origin: CGPoint(x: kConstants.padding.width, y: kConstants.padding.height+nobSize.height), size: realSize)
        let batteryBoardPath = UIBezierPath(roundedRect: batteryRect, byRoundingCorners:.allCorners, cornerRadii: CGSize(width: 5.0, height: 5.0))
        
        outlinePath.append(batteryBoardPath)
        return outlinePath
    }
    
    /// 电量形状 batterySOC为 0～1.0
    func batterySOCPath(size: CGSize, batterySOC: CGFloat) -> UIBezierPath {
        let socPadding: CGFloat = 2.0
        let nobHeight: CGFloat = (2.5/80.0)*size.height
        
        let realHeight = (size.height - kConstants.padding.height*2-nobHeight-socPadding*2 - kConstants.lineWidth*2)*batterySOC
        let realSize = CGSize(width: size.width - kConstants.padding.width*2 - socPadding*2 - kConstants.lineWidth*2, height: realHeight)
        let socRect = CGRect(origin: CGPoint(x: kConstants.padding.width+socPadding + kConstants.lineWidth, y: size.height - kConstants.padding.height - socPadding - kConstants.lineWidth - realHeight), size: realSize)
        
        var socPath = UIBezierPath(roundedRect: socRect, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 3.0, height: 3.0))
        if batterySOC > 0.9 {
            socPath = UIBezierPath(roundedRect: socRect, byRoundingCorners: .allCorners , cornerRadii: CGSize(width: 3.0, height: 3.0))
        }
        
        return socPath
    }
    
    /// 电量形状阴影path batterySOC为 0～1.0
    func batterySOCShadowPath(size: CGSize, batterySOC: CGFloat) -> UIBezierPath {
        let socPadding: CGFloat = 2.0
        let nobHeight: CGFloat = (2.5/80.0)*size.height
        
        let realHeight = (size.height - kConstants.padding.height*2-nobHeight-socPadding*2 - kConstants.lineWidth*2)*batterySOC
        let realSize = CGSize(width: size.width - kConstants.padding.width*2 - socPadding*2 - kConstants.lineWidth*2, height: realHeight)
        let socRect = CGRect(origin: CGPoint(x: kConstants.padding.width+socPadding + kConstants.lineWidth, y: size.height - kConstants.padding.height - socPadding - kConstants.lineWidth - realHeight), size: realSize)
        
        let shadowPath = UIBezierPath()
        shadowPath.move(to: CGPoint(x: socRect.minX-0.5, y: socRect.maxY-0.5))
        shadowPath.addLine(to: CGPoint(x: socRect.minX-0.5, y: socRect.minY+0.5))
        shadowPath.addLine(to: CGPoint(x: socRect.maxX-0.5, y: socRect.minY+0.5))
        shadowPath.addLine(to: CGPoint(x: socRect.maxX-0.5, y: socRect.maxY-0.5))
        
        return shadowPath
    }
    
    // 线性颜色渐变效果
    private func lineGradient(startColor: UIColor, endColor: UIColor) -> CGGradient? {
        let colors = [startColor.cgColor, endColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let colorLocations: [CGFloat] = [0.0, 1.0]
        return CGGradient(
          colorsSpace: colorSpace,
          colors: colors as CFArray,
          locations: colorLocations
        )
    }
}


extension HUTBatterySOCView {
    enum SOCStatus {
        /// 正常
        case normal
        /// 电量低  低于30%
        case lowbattery
        /// 电量低 低于10%
        case veryLowbattery
        
        case placeHolder
        
        var localizedInfo:(gradientStartColor: UIColor, gradientEndColor: UIColor, shadowColor: UIColor) {
            var sColor: UIColor = kHexColor("#82D246")
            var eColor: UIColor = kHexColor("#82D246")
            var shadowColor: UIColor = kHexColor("#82D246")
            switch self {
            case .normal:
                sColor = kHexColor("#c0e8a2")
                eColor = kHexColor("#e0f4d1")
                shadowColor = kHexColor("#82D246")
            case .lowbattery:
                sColor = kHexColor("#ffd798")
                eColor = kHexColor("#e8e2a9")
                shadowColor = kHexColor("#FFAF32")
            case .veryLowbattery:
                sColor = kHexColor("#ffacaf")
                eColor = kHexColor("#ffd6d7")
                shadowColor = kHexColor("#FF5A5F")
            case .placeHolder:
                sColor = kHexColor("#F8F8F9")
                eColor = kHexColor("#F8F8F9")
                shadowColor = kHexColor("#F8F8F9")
            }
            return (sColor, eColor, shadowColor)
        }
        
        // batterySOC为 0～1.0
        init(batterySOC: CGFloat) {
            if batterySOC <= 0.1002 {
                self = .veryLowbattery
            } else if batterySOC <= 0.3 {
                self = .lowbattery
            } else {
                self = .normal
            }
        }
    }
}
