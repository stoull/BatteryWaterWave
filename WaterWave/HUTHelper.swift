//
//  HUTHelper.swift
//  WaterWave
//
//  Created by Hut on 2022/10/21.
//

import Foundation
import UIKit

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

class HUTHelper {
    /// 角度转弧度
    static func rad2deg(_ number: Double) -> Double {
        return number * 180 / .pi
    }

    /// 弧度转角度
    static func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
}
