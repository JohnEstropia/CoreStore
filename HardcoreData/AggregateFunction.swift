//
//  AggregateFunction.swift
//  HardcoreData
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import CoreData


// MARK: - AggregateFunction

public enum AggregateFunction {
    
    // MARK: Public
    
    case Average(AttributeName)
    case Sum(AttributeName)
    case Count(AttributeName)
    case Minimum(AttributeName)
    case Maximum(AttributeName)
    case Medium(AttributeName)
    case Mode(AttributeName)
    case StandardDeviation(AttributeName)
    
    
    // MARK: Internal
    
    internal func createExpression() -> NSExpression {
        
        switch self {
            
        case .Average(let attributeName):
            return NSExpression(
                forFunction: "average:",
                arguments: [NSExpression(forKeyPath: "\(attributeName)")]
            )
            
        case .Sum(let attributeName):
            return NSExpression(
                forFunction: "sum:",
                arguments: [NSExpression(forKeyPath: "\(attributeName)")]
            )
            
        case .Count(let attributeName):
            return NSExpression(
                forFunction: "count:",
                arguments: [NSExpression(forKeyPath: "\(attributeName)")]
            )
            
        case .Minimum(let attributeName):
            return NSExpression(
                forFunction: "min:",
                arguments: [NSExpression(forKeyPath: "\(attributeName)")]
            )
            
        case .Maximum(let attributeName):
            return NSExpression(
                forFunction: "max:",
                arguments: [NSExpression(forKeyPath: "\(attributeName)")]
            )
            
        case .Medium(let attributeName):
            return NSExpression(
                forFunction: "medium:",
                arguments: [NSExpression(forKeyPath: "\(attributeName)")]
            )
            
        case .Mode(let attributeName):
            return NSExpression(
                forFunction: "mode:",
                arguments: [NSExpression(forKeyPath: "\(attributeName)")]
            )
            
        case .StandardDeviation(let attributeName):
            return NSExpression(
                forFunction: "stddev:",
                arguments: [NSExpression(forKeyPath: "\(attributeName)")]
            )
        }
    }
}
