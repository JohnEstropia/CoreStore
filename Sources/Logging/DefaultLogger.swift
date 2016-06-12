//
//  DefaultLogger.swift
//  CoreStore
//
//  Copyright © 2015 John Rommel Estropia
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


// MARK: - DefaultLogger

/**
 The `DefaultLogger` is a basic implementation of the `CoreStoreLogger` protocol.
 
 - The `log(...)` method calls `print(...)` to print the level, source file name, line number, function name, and the log message.
 - The `handleError(...)` method calls `print(...)` to print the source file name, line number, function name, and the error message.
 - The `assert(...)` method calls `assert(...)` on the arguments.
 */
public final class DefaultLogger: CoreStoreLogger {
    
    /**
     Creates a `DefaultLogger`.
     */
    public init() { }
    
    /**
     Handles log messages sent by the `CoreStore` framework.
     
     - parameter level: the severity of the log message
     - parameter message: the log message
     - parameter fileName: the source file name
     - parameter lineNumber: the source line number
     - parameter functionName: the source function name
     */
    public func log(level level: LogLevel, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        #if DEBUG
            let icon: String
            let levelString: String
            switch level {
                
            case .Trace:
                icon = "🔹"
                levelString = "Trace"
                
            case .Notice:
                icon = "🔸"
                levelString = "Notice"
                
            case .Warning:
                icon = "⚠️"
                levelString = "Warning"
                
            case .Fatal:
                icon = "❗"
                levelString = "Fatal"
            }
            Swift.print("\(icon) [CoreStore: \(levelString)] \((fileName.stringValue as NSString).lastPathComponent):\(lineNumber) \(functionName)\n  ↪︎ \(message)\n")
        #endif
    }
    
    /**
     Handles errors sent by the `CoreStore` framework.
     
     - parameter error: the error
     - parameter message: the error message
     - parameter fileName: the source file name
     - parameter lineNumber: the source line number
     - parameter functionName: the source function name
     */
    public func log(error error: CoreStoreError, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        #if DEBUG
            Swift.print("⚠️ [CoreStore: Error] \((fileName.stringValue as NSString).lastPathComponent):\(lineNumber) \(functionName)\n  ↪︎ \(message)\n    \(error)\n")
        #endif
    }
    
    /**
     Handles assertions made throughout the `CoreStore` framework.
     
     - parameter :condition: the assertion condition
     - parameter message: the assertion message
     - parameter fileName: the source file name
     - parameter lineNumber: the source line number
     - parameter functionName: the source function name
     */
    public func assert(@autoclosure condition: () -> Bool, @autoclosure message: () -> String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        #if DEBUG
            if condition() {
                
                return
            }
            Swift.print("❗ [CoreStore: Assertion Failure] \((fileName.stringValue as NSString).lastPathComponent):\(lineNumber) \(functionName)\n  ↪︎ \(message())\n")
            Swift.fatalError(file: fileName, line: UInt(lineNumber))
        #endif
    }
    
    /**
     Handles fatal errors made throughout the `CoreStore` framework.
     - Important: This method should be marked `@noreturn` and implementers should guarantee that the function doesn't, either by calling another `@noreturn` function such as `fatalError()` or `abort()`, or by raising an exception.
     
     - parameter message: the fatal error message
     - parameter fileName: the source file name
     - parameter lineNumber: the source line number
     - parameter functionName: the source function name
     */
    public func abort(message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        Swift.print("❗ [CoreStore: Fatal Error] \((fileName.stringValue as NSString).lastPathComponent):\(lineNumber) \(functionName)\n  ↪︎ \(message)\n")
        Swift.fatalError(file: fileName, line: UInt(lineNumber))
    }
}
