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
    @IBOutlet weak var history: UILabel!
    
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var operandStack = Array<Double>()

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        // print("digit = \(digit)")
        if userIsInTheMiddleOfTypingANumber {
            // if user is typing something, add that digit to the number
            display.text = display.text! + digit
        } else {
            // if user isn't in middle of typing something, reset screen to the digit just pressed and say we're typing now
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func modifyNumber(sender: UIButton) {
        let modifier = sender.currentTitle!
        switch modifier {
        case ".":
            // only respond to "." key if user hasn't typed a decimal point yet
            if (display.text!.rangeOfString(".") == nil) {
                // if user is in middle of typing a number...
                if (userIsInTheMiddleOfTypingANumber) {
                    // append a decimal point and add it to display test, and indicate that user has started typing
                    display.text = display.text! + modifier
                } else {
                    // if user is not in the middle of typing a number, should add 0.
                    display.text = "0" + modifier
                    userIsInTheMiddleOfTypingANumber = true
                }
            }
        case "⌫":
            // only work if user is currently typing
            if (userIsInTheMiddleOfTypingANumber) {
                if (display.text!.characters.count == 1 ||
                    (display.text!.rangeOfString("-") != nil && display.text!.characters.count == 2)) {
                    // if deleting last digit (pos or neg), put 0 there
                    display.text = "0"
                } else if (display.text!.characters.count > 1) {
                    // if there is a digit to delete, delete that digit
                    display.text = String(display.text!.characters.dropLast())
                }
            }
        case "+/-":
            if (userIsInTheMiddleOfTypingANumber) {
                // if user is in middle of typing a number, change the sign and allow typing to continue
                if (display.text!.rangeOfString("-") == nil) {
                    display.text = "-" + display.text!
                } else {
                    display.text = String(display.text!.characters.dropFirst())
                }
            } else {
                // otherwise, perform the unary operation of multiplying by -1
                performOperation {-1 * $0}
            }
        default: break
        }
    }
    
    @IBAction func insertConstant(sender: UIButton) {
        let constant = sender.currentTitle!

        // if user is in the middle of typing a number, enter that number

        if (userIsInTheMiddleOfTypingANumber) {
            enter()
        }

        // set display to constant and enter constant too
        switch constant {
        case "pi": displayValue = M_PI
        default: break
        }
        
        enter()

    }
    
    @IBAction func enter() {
        // stop typing number, add current value to the stack
        userIsInTheMiddleOfTypingANumber = false
        operandStack.append(displayValue)
        print("operandStack = \(operandStack)")
        // update history with operand
        history.text = history.text! + " " + "\(displayValue)"
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        // pressing operate button should implicitly enter whatever user has on screen if we're in middle of typing
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        history.text = history.text! + " " + operation
        // whichever operation we want, perform it by popping numbers off the stack
        switch operation {
        case "✕": performOperation { $0 * $1 }
        case "÷": performOperation { $1 / $0 }
        case "+": performOperation { $0 + $1 }
        case "−": performOperation { $1 - $0 }
        case "√": performOperation {sqrt($0)}
        case "sin": performOperation {sin($0)}
        case "cos": performOperation {cos($0)}
        default: break
        }
        
    }
    
    @IBAction func clearAll() {
       // clear history
        history.text = "History:"
        // clear stack
        operandStack = Array<Double>()
        // clear display
        displayValue = 0;
        
    }
    
    private func performOperation(operation: (Double, Double) -> Double) {
        // if there are enough operands in the stack, change the displayValue to the result of the operation, and save that value onto the stack
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
            // set the display value and stop typing
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    

}

