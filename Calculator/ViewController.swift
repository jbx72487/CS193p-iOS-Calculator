//
//  ViewController.swift
//  Calculator
//
//  Created by Joy Xi on 3/9/16.
//  Copyright © 2016 Joy Xi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    
    var userIsInTheMiddleOfTypingANumber = false
    var userHasTypedDecimalPoint = false

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        // print("digit = \(digit)")
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    var operandStack = Array<Double>()
    
    @IBAction func modifyNumber(sender: UIButton) {
        let modifier = sender.currentTitle!
        switch modifier {
        case ".":
            // only respond to "." key if user haven't typed a decimal point yet and if user is in middle of typing a number
            if (!userHasTypedDecimalPoint && userIsInTheMiddleOfTypingANumber) {
                // append a decimal point and add it to display test, and indicate that user has typed a decimal point and has started typing
                display.text = display.text! + modifier
                userHasTypedDecimalPoint = true
            } else if (!userIsInTheMiddleOfTypingANumber) {
                // if user is not in the middle of typing a number, should add 0.
                display.text = "0."
                userIsInTheMiddleOfTypingANumber = true
            }
        default: break
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        userHasTypedDecimalPoint = false
        operandStack.append(displayValue)
        print("operandStack = \(operandStack)")
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        switch operation {
        case "✕": performOperation { $0 * $1 }
        case "÷": performOperation { $1 / $0 }
        case "+": performOperation { $0 + $1 }
        case "−": performOperation { $1 - $0 }
        case "√": performOperation {sqrt($0)}
        default: break
        }
    }
    
    private func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    private func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    

}

