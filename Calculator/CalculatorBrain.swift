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
    private enum Op {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double) // will have a string for name of the operation and a function
        case BinaryOperation(String, (Double, Double) -> Double)
    }
    
    private var opStack = [Op]()
    // less preferred syntax: Array<Op>()
    
    private var knownOps = [String:Op]()
    // var knownOps = Dictionary<String, Op>()
        // Dictionary where keys are strings, vals are ops
    
    init() {
        knownOps["x"] = Op.BinaryOperation("x", *)
        // can also write  knownOps["x"] = Op.BinaryOperation("x") {$0 * $1}
        knownOps["/"] = Op.BinaryOperation("/") {$1 / $0}
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["-"] = Op.BinaryOperation("-") {$1 - $0}
        knownOps["√"] = Op.UnaryOperation("√", sqrt)

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
        let (result, _) = evaluate(opStack)
        return result
    }
    
    func pushOperand(operand: Double) {
        opStack.append(Op.Operand(operand))
    }
    
    func performOperation(symbol: String) {
        if let operation = knownOps[symbol] {
        // operation here is an optional value, just like anything you're looking up in  a dictionary, because the key you gave it might not be in the dictionary
            opStack.append(operation)
        }
    }
}