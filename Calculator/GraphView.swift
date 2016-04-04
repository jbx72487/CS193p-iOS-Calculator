//
//  GraphView.swift
//  Calculator
//
//  Created by Joy Xi on 4/4/16.
//  Copyright © 2016 Joy Xi. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func yForX(sender: GraphView, x: CGFloat) -> CGFloat?
}

// generic x vs. y UIView, independent of the calculator
@IBDesignable
class GraphView: UIView {
    
    weak var dataSource: GraphViewDataSource?
    
    @IBInspectable var scale = CGFloat(1.0) {
        didSet {
            pointsPerUnit *= scale
            setNeedsDisplay()
        }
    }
    
    // var for origin
    var origin: CGPoint? {
        didSet {
            setNeedsDisplay()
        }
    }

    /* TODO why didn't this work?
    var pointsPerUnit:CGFloat = 50.0 {
        didSet {
            setNeedsDisplay()
        }
    }*/
    
    var pointsPerUnit = CGFloat(50.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        // default origin to middle of screen TODO is this the best way to do this?
        if (origin == nil) {
            origin = CGPoint(x: bounds.midX, y: bounds.midY)
        }

        // TODO why do i need this???
        if (pointsPerUnit == 0) {
            pointsPerUnit = 50.0
        }

        // make an axesDrawer object with the current scale factor etc
        let axesDrawer = AxesDrawer(color: UIColor.blackColor(),contentScaleFactor: contentScaleFactor)
        
        // draw axes
        axesDrawer.drawAxesInRect(bounds, origin: origin!, pointsPerUnit: pointsPerUnit)
    }
    
    // use GraphingViewController as a delegate to get data using yForX
    // loop through x pixels from end to end on the shown axes
    // if let y = dataSource?.yForX(self, x), then graph it (if drawing, addLineToPoint, if not, just move there). otherwise stop drawing
    
    // graph a function
    
    // draw the description of the function on screen (ex. sin(M))

    // must graph discontinuous functions ok: it must only draw lines to or from points which, for a given value of M, the program being graphed evaluates to a Double (i.e. not nil) that .isNormal or .isZero).
    
    // gesture handlers that belong in graphing view: support pinch to zoom, pan to follow touch around, double-tap to move origin to double tap location
    func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Changed, .Ended:
            let translation = gesture.translationInView(self)
            // update origin accordingly
            origin!.x += translation.x
            origin!.y += translation.y
            gesture.setTranslation(CGPointZero, inView: self)
        default: break
        }
    }
    
    func moveOrigin(gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            origin = gesture.locationOfTouch(0, inView: self)
            print("Double tap recognized at \(origin)")
        default: break
        }
    }
    
    
    func zoom(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .Changed:
            print("pinch gesture recognized. multiplying scale of \(scale) by \(gesture.scale)")
            scale *= gesture.scale
            gesture.scale = 1
        default: break
        }
    }
    
    
    
}

// 3. graph the program that's in MVC at that time of graphing button
// what should be this MVC's model?