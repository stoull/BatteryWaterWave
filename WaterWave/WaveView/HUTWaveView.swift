//
//  HUTWaveView.swift
//  WaterWave
//
//  Created by Hut on 2021/12/29.
//

import UIKit

class HUTWaveView: UIView {
    let A_max: CGFloat = 7.0
    var A: CGFloat = 7.0 // 振幅
    var T: CGFloat = 3.0 // 周期
    var K: CGFloat = 270 // 波长
    
    /// 第二个波的参数
    let A2_max: CGFloat = 7.0
    var A2: CGFloat = 7.0    // 振幅
    var T2: CGFloat = 3.0   // 周期
    var K2: CGFloat = 270    // 波长
    
    var t: CGFloat = 0.0 // 时间变量
    var dY: CGFloat = 2    // 为与第一个波之间的间距，负数在第一个波的下方（有可能看不到）
    
    var wavePercentageStorage: CGFloat = 0.5
    /// 图形在view中的高度百分比，至下往上
    var wavePercentage: CGFloat {
        get{return wavePercentageStorage}
        set{
            wavePercentageStorage = newValue
            
            if newValue < 0.4 {
                // 0%~40%的 波信息
                print("newvalue: \(newValue) x:\(A_max*(2.5*newValue))")
                
                A = A_max*(2.5*newValue)
                A2 = A2_max*(2.5*newValue)
            } else {
                // 40%~100%的 波信息
                A = A_max*(2.5*(1-newValue))
                A2 = A_max*(2.5*(1-newValue))
                
            }
            
        }
    }
    
    var change = false // 用来改变振幅的大小，增加节奏感
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(animateWave), userInfo: nil, repeats: true)
        wavePercentage = 0.5
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func animateWave() {
        t += 0.05
        self.setNeedsDisplay()
    }
    
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {return}
        let viewWidth = rect.width
        let radius = viewWidth*0.5
        let clippingPath = CGPath(ellipseIn: rect, transform: nil)
        
        let path1 = CGMutablePath()
        let path2 = CGMutablePath()
        
        let yPosition = (1.0-wavePercentage)*rect.height
        var y1 = yPosition
        var y2 = yPosition
        path1.move(to: CGPoint(x: 0.0, y: y1))
        path2.move(to: CGPoint(x: 0.0, y: y2+dY))
        
        // 这是将x轴微分单位为1pt，就是每隔1pt计算一个y值，将所有的y值连起来就是一个波图
        // 可以将微分单位设置大一点，有不一样的效果
        // y 值的计算就用推导出来的公式：y = Acos2PI(t/T - Xp/K)
        let axleYOnScreenHeight2 = yPosition-dY
//        let random = Float.random(in: 0..<1)
        let dt = t-T*0.25
        for x in stride(from: 1, to: viewWidth, by: 2) {
            y1 = CGFloat(A * cos(Double.pi*2 * (t/T - x/K))) + yPosition
            y2 = CGFloat(A2 * cos(Double.pi*2 * (dt/T2 - x/K2))) + axleYOnScreenHeight2
            path1.addLine(to: CGPoint(x: x, y: y1))
            path2.addLine(to: CGPoint(x: x, y: y2))
        }
        
        path1.addLine(to: CGPoint(x: viewWidth, y: rect.height))
        path1.addLine(to: CGPoint(x: 0, y: rect.height))
        path1.addLine(to: CGPoint(x: 0, y: yPosition))
        path2.addLine(to: CGPoint(x: viewWidth, y: rect.height))
        path2.addLine(to: CGPoint(x: 0, y: rect.height))
        path2.addLine(to: CGPoint(x: 0, y: axleYOnScreenHeight2))
        
        context.addPath(clippingPath)
        context.clip()
    
        // 水波填充
        context.saveGState()
        context.addPath(path2)
        context.setFillColor(kHexColor("#2fac9b").cgColor)
        context.fillPath()
        context.restoreGState()
        
        context.saveGState()
        context.addPath(path1)
        context.clip()
        let lineGradient = underLineGradient(startColor: kHexColor("3ad7c4"), endColor: kHexColor("69b836"))
        context.drawLinearGradient(lineGradient, start: CGPoint(x: radius, y: yPosition-3*A), end: CGPoint(x: radius, y: yPosition+(rect.width-yPosition)), options: .drawsBeforeStartLocation)
        context.restoreGState()
        
        // 边框
        context.addPath(clippingPath)
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(2.0)
        context.strokePath()
        
        
    }
    
    // 曲线下的颜色渐变效果
    private func underLineGradient(startColor: UIColor, endColor: UIColor) -> CGGradient{
        
        let sColor = startColor.withAlphaComponent(1.0)
        let eColor = endColor.withAlphaComponent(1.0)
        
        let colors = [sColor.cgColor, eColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let colorLocations: [CGFloat] = [0.0, 1.0]
        return CGGradient(
          colorsSpace: colorSpace,
          colors: colors as CFArray,
          locations: colorLocations
        )!
    }
    
}


func kRGBAColor(_ r: CGFloat,_ g: CGFloat,_ b: CGFloat,_ a: CGFloat) -> UIColor {
    return UIColor.init(red: r, green: g, blue: b, alpha: a)
}
func kRGBColor(_ r: CGFloat,_ g: CGFloat,_ b: CGFloat) -> UIColor {
    return UIColor.init(red: r, green: g, blue: b, alpha: 1.0)
}
func kHexColorA(_ HexString: String,_ a: CGFloat) ->UIColor {
    return UIColor.colorWith(hexString: HexString, alpha: a)
}

func kHexColor(_ HexString: String) ->UIColor {
    return UIColor.colorWith(hexString: HexString)
}

// MARK: - 颜色相关
extension UIColor {
    // MARK: - Convert hex string to a UIColor instance
    class func colorWith(hexString:String, alpha: CGFloat = 1.0) -> UIColor {
        var cString:String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
