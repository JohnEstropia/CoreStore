//
//  CoreStoreLogger.swift
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


// MARK: - LogLevel

/**
 The `LogLevel` indicates the severity of a log message.
 */
public enum LogLevel {
    
    case Trace
    case Notice
    case Warning
    case Fatal
}


// MARK: - CoreStoreLogger

/**
 Custom loggers should implement the `CoreStoreLogger` protocol and pass its instance to `CoreStore.logger`. Calls to `log(...)`, `handleError(...)`, and `assert(...)` are not tied to a specific queue/thread, so it is the implementer's job to handle thread-safety.
 */
public protocol CoreStoreLogger {
    
    /**
     Handles log messages sent by the `CoreStore` framework.
     
     - parameter level: the severity of the log message
     - parameter message: the log message
     - parameter fileName: the source file name
     - parameter lineNumber: the source line number
     - parameter functionName: the source function name
     */
    func log(level level: LogLevel, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString)
    
    /**
     Handles errors sent by the `CoreStore` framework.
     
     - parameter error: the error
     - parameter message: the error message
     - parameter fileName: the source file name
     - parameter lineNumber: the source line number
     - parameter functionName: the source function name
     */
    func log(error error: CoreStoreError, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString)
    
    /**
     Handles assertions made throughout the `CoreStore` framework.
     
     - parameter condition: the assertion condition
     - parameter message: the assertion message
     - parameter fileName: the source file name
     - parameter lineNumber: the source line number
     - parameter functionName: the source function name
     */
    func assert(@autoclosure condition: () -> Bool, @autoclosure message: () -> String, fileName: StaticString, lineNumber: Int, functionName: StaticString)
    
    /**
     Handles fatal errors made throughout the `CoreStore` framework. The app wil terminate after this method is called.
     - Important: Implementers may guarantee that the function doesn't return, either by calling another `@noreturn` function such as `fatalError()` or `abort()`, or by raising an exception. If the implementation does not terminate the app, CoreStore will call an internal `fatalError()` to do so.
     
     - parameter message: the fatal error message
     - parameter fileName: the source file name
     - parameter lineNumber: the source line number
     - parameter functionName: the source function name
     */
    func abort(message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString)
    
    
    // MARK: Deprecated
    
    /**
     Deprecated. Use `log(error:message:fileName:lineNumber:functionName:)` instead.
     */
    @available(*, deprecated=2.0.0, message="Use log(error:message:fileName:lineNumber:functionName:) instead.")
    func handleError(error error: NSError, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString)
}

extension CoreStoreLogger {
    
    /**
     Deprecated. Use `log(error:message:fileName:lineNumber:functionName:)` instead.
     */
    @available(*, deprecated=2.0.0, message="Use log(error:message:fileName:lineNumber:functionName:) instead.")
    public func handleError(error error: NSError, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
    
        self.log(error: error.bridgeToSwift, message: message, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    public func abort(message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        Swift.fatalError(message, file: fileName, line: UInt(lineNumber))
    }
}
