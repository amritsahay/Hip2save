//
//  GradientView.swift
//  Write Off Rocket
//
//  Created by ip-d on 21/08/18.
//  Copyright © 2018 Esferasoft Solutions. All rights reserved.
//

import UIKit

class GradientView: UIView {

    @IBInspectable var firstColor:UIColor = UIColor.white
    @IBInspectable var lastColor:UIColor = UIColor.black
    @IBInspectable var angleInDegrees:Int = 0
    @IBInspectable var cornerEdge:CGFloat = 0
    @IBInspectable var isRounded:Bool = false
    
  
    override func layoutSubviews()
    {
        super.layoutSubviews()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [lastColor.cgColor,firstColor.cgColor]
        gradientLayer.startPoint = startAndEndPointsFrom(angle: angleInDegrees).startPoint
        gradientLayer.endPoint = startAndEndPointsFrom(angle: angleInDegrees).endPoint
        self.layer.insertSublayer(gradientLayer, at: 0)
        if isRounded
        {
             self.layer.cornerRadius = self.bounds.size.height/2
        }
        else
        {
            self.layer.cornerRadius = cornerEdge
           
        }
         self.layer.masksToBounds = true
    }

    func startAndEndPointsFrom(angle: Int) -> (startPoint:CGPoint, endPoint:CGPoint) {
        // Set default points for angle of 0°
        var startPointX:CGFloat = 0.5
        var startPointY:CGFloat = 1.0
        
        // Define point objects
        var startPoint:CGPoint
        var endPoint:CGPoint
        
        // Define points
        switch true {
        // Define known points
        case angle == 0:
            startPointX = 0.5
            startPointY = 1.0
        case angle == 45:
            startPointX = 0.0
            startPointY = 1.0
        case angle == 90:
            startPointX = 0.0
            startPointY = 0.5
        case angle == 135:
            startPointX = 0.0
            startPointY = 0.0
        case angle == 180:
            startPointX = 0.5
            startPointY = 0.0
        case angle == 225:
            startPointX = 1.0
            startPointY = 0.0
        case angle == 270:
            startPointX = 1.0
            startPointY = 0.5
        case angle == 315:
            startPointX = 1.0
            startPointY = 1.0
        // Define calculated points
        case angle > 315 || angle < 45:
            startPointX = 0.5 - CGFloat(tan(angle.degreesToRads()) * 0.5)
            startPointY = 1.0
        case angle > 45 && angle < 135:
            startPointX = 0.0
            startPointY = 0.5 + CGFloat(tan(90.degreesToRads() - angle.degreesToRads()) * 0.5)
        case angle > 135 && angle < 225:
            startPointX = 0.5 - CGFloat(tan(180.degreesToRads() - angle.degreesToRads()) * 0.5)
            startPointY = 0.0
        case angle > 225 && angle < 359:
            startPointX = 1.0
            startPointY = 0.5 - CGFloat(tan(270.degreesToRads() - angle.degreesToRads()) * 0.5)
        default: break
        }
        // Build return CGPoints
        startPoint = CGPoint(x: startPointX, y: startPointY)
        endPoint = startPoint.opposite()
        // Return CGPoints
        return (startPoint, endPoint)
    }
    
}

extension CGPoint {
    func opposite() -> CGPoint {
        // Create New Point
        var oppositePoint = CGPoint()
        // Get Origin Data
        let originXValue = self.x
        let originYValue = self.y
        // Convert Points and Update New Point
        oppositePoint.x = 1.0 - originXValue
        oppositePoint.y = 1.0 - originYValue
        return oppositePoint
    }
}

extension Int {
    func degreesToRads() -> Double {
        return (Double(self) * .pi / 180)
    }
}

