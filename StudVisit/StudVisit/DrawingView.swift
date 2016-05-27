
//
//  DrawingView.swift
//  StudVisit
//
//  Created by Maxim Galayko on 5/23/16.
//  Copyright © 2016 Maxim Galayko. All rights reserved.
//

import UIKit

class DrawingView: UIView {
    
    var maxNumberOfLines: Int = 10
    var minNumberOfLines: Int = 3
    
    var shouldRedraw = false
    
    private var lines: [(first: CGPoint, last: CGPoint, width: CGFloat, color: UIColor)] = []
    
    override func drawRect(rect: CGRect) {
        if shouldRedraw || lines.isEmpty {
            generateNewLines(rect)
            shouldRedraw = false
        }
        redraw()
        
        
//        if shouldRedraw == false {
//            return
//        }
//        shouldRedraw = false
//        let context = UIGraphicsGetCurrentContext()
//        
//        let numberOfLines = arc4random_uniform(UInt32(maxNumberOfLines - minNumberOfLines)) + UInt32(minNumberOfLines)
//        let drawableRect = rect
//        
//        for _ in 0..<numberOfLines {
//            addCustomLine(drawableRect, context: context)
//        }
    }
    
    private func generateNewLines(rect: CGRect) {
        lines.removeAll()
        let numberOfLines = arc4random_uniform(UInt32(maxNumberOfLines - minNumberOfLines)) + UInt32(minNumberOfLines)
        for _ in 0..<numberOfLines {
            lines.append(createCustomLine(rect))
        }
    }
    
    private func createCustomLine(rect: CGRect) -> (first: CGPoint, last: CGPoint, width: CGFloat, color: UIColor) {
        let startPoint = CGPoint(x: CGFloat(arc4random_uniform(UInt32(rect.width))), y: CGFloat(arc4random_uniform(UInt32(rect.height))))
        let endPoint = CGPoint(x: CGFloat(arc4random_uniform(UInt32(rect.width))), y: CGFloat(arc4random_uniform(UInt32(rect.height))))
        let lineWidth = CGFloat(arc4random_uniform(UInt32(5)))
        let color = randomColor()
        return (first: startPoint, last: endPoint, width: lineWidth, color: color)
    }
    
    private func redraw() {
        for index in 0..<lines.count {
            drawLineAtIndex(index)
        }
    }
    
    private func drawLineAtIndex(index: Int) {
        let context = UIGraphicsGetCurrentContext()
        let line = lines[index]
        
        line.color.setFill()
        line.color.setStroke()
        CGContextSetLineWidth(context, line.width)
        CGContextMoveToPoint(context, line.first.x, line.first.y)
        CGContextAddLineToPoint(context, line.last.x, line.last.y)
        CGContextStrokePath(context)
    }
    
//    private func addCustomLine(rect: CGRect, context: CGContext?) {
//        randomColor().setFill()
//        randomColor().setStroke()
//        CGContextSetLineWidth(context, CGFloat(arc4random_uniform(UInt32(5))))
//        CGContextMoveToPoint(context, CGFloat(arc4random_uniform(UInt32(rect.width))), CGFloat(arc4random_uniform(UInt32(rect.height))))
//        CGContextAddLineToPoint(context, CGFloat(arc4random_uniform(UInt32(rect.width))), CGFloat(arc4random_uniform(UInt32(rect.height))))
//        CGContextStrokePath(context)
//    }
//    
    private func randomColor() -> UIColor {
        return UIColor(red: CGFloat(arc4random_uniform(UInt32(255))) / 255.0, green: CGFloat(arc4random_uniform(UInt32(255))) / 255.0, blue: CGFloat(arc4random_uniform(UInt32(255))) / 255.0, alpha: 1)
    }
}
