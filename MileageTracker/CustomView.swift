//
//  CustomView.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 04/04/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//


import UIKit

class CustomView: UIView {

    override func draw(_ rect: CGRect) {
        let transposedFrame = CGRect(x:0, y:0, width:rect.size.width - rect.origin.x, height:rect.size.height - rect.origin.y)
        
        let radius = transposedFrame.size.width/9
        let cornerRadius = radius/3
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x:transposedFrame.width/2+radius,y:radius))
        path.addArc(withCenter: CGPoint(x:transposedFrame.size.width-cornerRadius, y:radius + cornerRadius), radius: cornerRadius, startAngle: CGFloat(3/2*Double.pi), endAngle: CGFloat(2*Double.pi), clockwise: true)
        path.addArc(withCenter: CGPoint(x:transposedFrame.size.width-cornerRadius, y:transposedFrame.size.height-cornerRadius), radius: cornerRadius, startAngle: CGFloat(2*Double.pi), endAngle: CGFloat(Double.pi/2), clockwise: true)
        path.addArc(withCenter: CGPoint(x:cornerRadius, y:transposedFrame.size.height-cornerRadius), radius: cornerRadius, startAngle: CGFloat(Double.pi/2), endAngle: CGFloat(Double.pi), clockwise: true)
        path.addArc(withCenter: CGPoint(x:cornerRadius, y:radius + cornerRadius), radius: cornerRadius, startAngle: CGFloat(Double.pi), endAngle: CGFloat(3/2*Double.pi), clockwise: true)
        path.addArc(withCenter: CGPoint(x:transposedFrame.size.width/2, y:radius), radius: radius, startAngle: CGFloat(Double.pi), endAngle: CGFloat(2*Double.pi), clockwise: true)
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        self.layer.mask = shapeLayer
    }

}
