//
//  GraphingViewController.swift
//  Calculator
//
//  Created by Joy Xi on 4/3/16.
//  Copyright © 2016 Joy Xi. All rights reserved.
//

import UIKit

class GraphingViewController: UIViewController, GraphViewDataSource {
    
    // make an instance of GraphView
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            // set itself as the delegate for graphView, so that it can provide graphView with data
            graphView.dataSource = self
            
            // add all 3 gesture recognizers: pan, tap, and pinch
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "pan:"))
            let tapGesture = UITapGestureRecognizer(target: graphView, action: "moveOrigin:")
            tapGesture.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tapGesture)
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "zoom:"))
        }
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList = []{
        didSet {
            updateUI()
        }
        // data will come from CalculatorBrain in form of "program," a property list which is an array of strings representing the opStack
    }
    
    // TODO yValueForX function takes in a CGFloat x and returns the y value
    func yForX(sender: GraphView, x: CGFloat) -> CGFloat? {
    // in program, replace variable M with x value
        // evaluate at that x value and return the outcome
        return CGFloat(0.0)
    }

    
    // func updateUI, to be called each time the Graph button is pressed

    
    func updateUI() {
        graphView.setNeedsDisplay()
    }
}
