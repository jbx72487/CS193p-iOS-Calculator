//
//  ViewController.swift
//  Calculator
//
//  Created by Joy Xi on 3/9/16.
//  Copyright © 2016 Joy Xi. All rights reserved.
//


//change displayValue to be optional

import UIKit

class CalculatorViewController: UIViewController {


    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!

    var userIsInTheMiddleOfTypingANumber = false
    var brain = CalculatorBrain() // this is how the controller talks to the model
    
    var displayValue: Double? {
        get {
            if (display.text == " ") {
                return nil
            } else {
                return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
            }
        }
        set {
            // set the display value and stop typing
            if (newValue == nil) {
                display.text = " "
            } else {
                display.text = String(format:"%g",newValue!)
            }
            userIsInTheMiddleOfTypingANumber = false
            updateHistory()
        }
    }

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
            if (!userIsInTheMiddleOfTypingANumber) {
                // if user is not in the middle of typing a number, should add "0."
                display.text = "0" + modifier
                userIsInTheMiddleOfTypingANumber = true
            } else if (display.text!.rangeOfString(".") == nil) {
                // if user is in middle of typing a number and there aren't decimals in it yet...
                // append a decimal point and add it to display test, and indicate that user has started typing
                display.text = display.text! + modifier
            }
        case "+/-":
            if (userIsInTheMiddleOfTypingANumber) {
                // if user is in middle of typing a number, change the sign and allow typing to continue
                if (display.text![display.text!.startIndex] != "-") {
                    display.text = "-" + display.text!
                } else {
                    display.text = String(display.text!.characters.dropFirst())
                }
            } else {
                // otherwise, perform the unary operation of multiplying by -1
                if let result = brain.performOperation(modifier) {
                    displayValue = result
                } else {
                    displayValue = nil
                }
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
        case "pi":
            if let result = brain.pushOperand("π") {
                displayValue = result
            }
        default: break
        }

    }
    
    @IBAction func undo() {
        // if user is currently typing, same as backspace
        if (userIsInTheMiddleOfTypingANumber) {
            if (display.text!.characters.count == 1 ||
                (display.text![display.text!.startIndex] == "-" && display.text!.characters.count == 2)) {
                // if deleting last digit (pos or neg), put 0 there
                display.text = "0"
            } else if (display.text!.characters.count > 1) {
                // if there is a digit to delete, delete that digit
                display.text = String(display.text!.characters.dropLast())
            }
        } else { // otherwise, undo last action
            // if last thing was an Op (incl. all operands, operations, +/-, pi), pop that off the stack and reevaluate
            // if last thing was clear (i.e. opStack is empty), don't do anything
            // if last thing was enter, that means it was an op
            // if last thing was undo, keep undoing
            // in conclusion, if brain is able to do it, drop the last thing in opStack and display new result
            displayValue = brain.removeLastOp()
        }

    }
    
    @IBAction func enter() {
        if let displayVal = displayValue {
            if let result = brain.pushOperand(displayVal) {
                displayValue = result
            }
        } else {
                displayValue = nil
        }
        userIsInTheMiddleOfTypingANumber = false
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            // pressing operate button should implicitly enter whatever user has on screen if we're in middle of typing

            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = nil
            }
            // whichever operation we want, perform it by popping numbers off the stack
        }
    }
    
    @IBAction func clearAll() {
        // clear stack
        brain.clearStack()
        // clear variables
        brain.clearVariables()
        // clear display
        displayValue = nil;
        
    }
    
    
    @IBAction func setVar() {
        if let result = brain.setVar("M",varValue: displayValue) {
            displayValue = result
        }
        userIsInTheMiddleOfTypingANumber = false
    }
    
    @IBAction func getVar() {
        if let result = brain.pushOperand("M") {
            displayValue = result
        }
    }
    
    
    private func updateHistory() {
        // update history and add "="
        if brain.description.characters.count > 0 {
            history.text = brain.description + "="
        } else {
            history.text = " "
        }
    }
    

    private func addCurrentValToStack() {
        // stop typing number, add current value to the stack
        userIsInTheMiddleOfTypingANumber = false
        if let _ = brain.pushOperand(displayValue!) {}
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination:UIViewController? = segue.destinationViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        if let gvc = destination as? GraphingViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "Generate Graph":
                    gvc.program = brain.program
                    // TODO anything else?
                default: break
                }
            }
        }
    }
}
    



