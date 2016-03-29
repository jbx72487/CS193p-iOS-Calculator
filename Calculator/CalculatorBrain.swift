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
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    // less preferred syntax: Array<Op>()
    
    private var knownOps = [String:Op]()
    // var knownOps = Dictionary<String, Op>()
        // Dictionary where keys are strings, vals are ops
    
    var variableValues = [String:Double]()

    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("✕", *))
        // can also write  knownOps["x"] = Op.BinaryOperation("x") {$0 * $1}
        learnOp(Op.BinaryOperation("÷") {$1 / $0})
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("-") {$1 - $0})
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos") {cos($0)})
        learnOp(Op.UnaryOperation("+/-") {-1*$0})
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
        print("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) ->Double? {
        // push symbol onto stack
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
        // operation here is an optional value, just like anything you're looking up in  a dictionary, because the key you gave it might not be in the dictionary
            opStack.append(operation)
        }        
        return evaluate()
    }
}