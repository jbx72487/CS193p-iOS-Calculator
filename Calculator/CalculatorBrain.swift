//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Joy Xi on 3/18/16.
//  Copyright © 2016 Joy Xi. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op : CustomStringConvertible // this enum implements the Printable protocol (or in this version of Swift, CustomStringConvertible), which means it has that read-only computed property called description like the way we have it
    {
        case Operand(Double)
        case Variable(String)
        case Constant(String)
        case UnaryOperation(String, Double -> Double) // will have a string for name of the operation and a function
        case BinaryOperation(String, (Double, Double) -> Double)

        var description: String {
            // this is a read-only computed property
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let varName):
                    return varName
                case .Constant(let constName):
                    return constName
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
        
        static var precedenceOf = [String:Int]()
        
        var precedence: Int {
            get {
                switch self {
                case .Operand, .Variable, .Constant, .UnaryOperation:
                    return Int.max
                case .BinaryOperation(let symbol, _):
                    if let p = Op.precedenceOf[symbol] {
                        return p
                    } else {
                        return Int.max
                    }
                }
            }
        }
    }
    

    private var opStack = [Op]()
    // less preferred syntax: Array<Op>()
    
    private var knownOps = [String:Op]()
    // var knownOps = Dictionary<String, Op>()
        // Dictionary where keys are strings, vals are ops
    
    private var variableValues = [String:Double]()
    private var constantValues = [String:Double]()

    var description: String {
        get {
            return describe()
        }
    }
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        func learnPriority(symbol: String, priority: Int) {
            Op.precedenceOf[symbol] = priority
        }
        
        let highPriority = 10
        let lowPriority = 5
        
        learnOp(Op.BinaryOperation("✕", *))
        // can also write  knownOps["x"] = Op.BinaryOperation("x") {$0 * $1}
        learnOp(Op.BinaryOperation("÷") {$1 / $0})
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("-") {$1 - $0})
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos") {cos($0)})
        learnOp(Op.UnaryOperation("+/-") {-1*$0})
        
        learnPriority("x", priority: highPriority)
        learnPriority("÷", priority: highPriority)
        learnPriority("+", priority: lowPriority)
        learnPriority("-", priority: lowPriority)
        
        constantValues["π"] = M_PI
    }
    
    func clearStack() {
        opStack = [Op]()
    }
    
    func clearVariables() {
        variableValues = [String:Double]()
    }
    
    func describe() -> String {
        // calls on other (recursive) describe function to turn opStack into a String
        var finalDescription = [String]()
        var description: String? = nil
        var remainder = opStack
        
        // for as long as remainder.count > 0, keep forming the description of the remainder
        while remainder.count > 0 {
            (description, remainder) = describe(remainder)
            if let expression = description {
                finalDescription.insert(expression, atIndex: 0)
            }
        }
        return finalDescription.joinWithSeparator(",")
    }
    
    private func describe(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        // only do this if ops isnt empty
        if !ops.isEmpty {
            // pop one off of ops
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            // if it's an unary function, add parentheses around everything and put the function up front
            // variable / constant / number should display as is
            case .Variable(let varName):
                return (varName, remainingOps)
            case .Constant(let constName):
                return (constName, remainingOps)
            case .Operand(let operand):
                return (String(format:"%g",operand), remainingOps)
            case .UnaryOperation(let opName, _):
                let operationDescription = describe(remainingOps)
                if let operand = operationDescription.result {
                    return("\(opName)("+"\(operand)"+")", operationDescription.remainingOps)
                } else {
                    return("\(opName)(?)", operationDescription.remainingOps)
                }
            
            // if it's a binary function, display using infix notation
            case .BinaryOperation(let opName, _):
                let op1Description = describe(remainingOps)
                
                if let operand1 = op1Description.result {
                    let op2Description = describe(op1Description.remainingOps)
                    if let operand2 = op2Description.result {
                        if remainingOps.count > 2 {
                            return("(\(operand1))\(opName)(\(operand2))", op2Description.remainingOps)
                        } else {
                            return("\(operand1)\(opName)\(operand2)", op2Description.remainingOps)
                        }
                    } else {
                        if remainingOps.count > 1 {
                            return("?\(opName)(\(operand1))", op2Description.remainingOps)
                        } else {
                            return("?\(opName)\(operand1)", op2Description.remainingOps)
                        }
                    }
                } else {
                    return("?\(opName)?", op1Description.remainingOps)
                }
            }
            // if ops IS empty, return empty string, ops
        }
        return (nil, ops)
    }

    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        if !ops.isEmpty {
            // ops is read-only as a non-class argument
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand): // "let operand" means inside the handling of this switch, operand will have the associated value of the operand
                return (operand, remainingOps)
            case .Variable(let varName):
                return (variableValues[varName], remainingOps)
            case .Constant(let constName):
                return (constantValues[constName], remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
                
            }
            
        }
        return(nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        if let resultNum = result {
            print("\(opStack) = \(result!) with \(remainder) left over")
        }
        return result
    }
    
    func setVar(varName: String, varValue: Double?) -> Double? {
        variableValues[varName] = varValue
        return evaluate()
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) ->Double? {
        // if the symbol is already a constant, push the constant on, if not, push it as a variable
        if let _ = constantValues[symbol] {
            opStack.append(Op.Constant(symbol))
        } else {
            // push symbol onto stack
            opStack.append(Op.Variable(symbol))
        }
        return evaluate()
    }
    
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
        // operation here is an optional value, just like anything you're looking up in  a dictionary, because the key you gave it might not be in the dictionary
            opStack.append(operation)
        }
        print(describe())
        return evaluate()
    }
    
    func removeLastOp() -> Double? {
        if !opStack.isEmpty {
            let _ = opStack.removeLast()
            return evaluate()
        } else {
            return nil
        }
    }
}