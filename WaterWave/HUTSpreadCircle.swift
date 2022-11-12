//
//  HUTSpreadCircle.swift
//  AnimationCraft
//
//  Created by Kevin on 2022/11/11.
//

import UIKit

class HUTSpreadCircle {
    var size: CGSize = .zero
    private var radiusStorage: CGFloat = 0.0
    var radius: CGFloat {
        get { return radiusStorage }
        set {
            radiusStorage = newValue
            self.circlePath = UIBezierPath(arcCenter: CGPoint(x: size.width*0.5, y: size.height*0.5), radius: newValue, startAngle: 0.0, endAngle: CGFloat(2 * Double.pi), clockwise: false)
        }
    }
    
    var circlePath: UIBezierPath = UIBezierPath()
    
    init(size: CGSize, radius: CGFloat) {
        self.size = size
        self.radius = radius
        self.circlePath = UIBezierPath(arcCenter: CGPoint(x: size.width*0.5, y: size.height*0.5), radius: radius, startAngle: 0.0, endAngle: CGFloat(2 * Double.pi), clockwise: false)
    }
}
