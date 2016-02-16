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
     
     :level: the severity of the log message
     :message: the log message
     :fileName: the source file name
     :lineNumber: the source line number
     :functionName: the source function name
     */
    func log(level level: LogLevel, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString)
    
    /**
     Handles errors sent by the `CoreStore` framework.
     
     :error: the error
     :message: the error message
     :fileName: the source file name
     :lineNumber: the source line number
     :functionName: the source function name
     */
    func handleError(error error: NSError, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString)
    
    /**
     Handles assertions made throughout the `CoreStore` framework.
     
     :condition: the assertion condition
     :message: the assertion message
     :fileName: the source file name
     :lineNumber: the source line number
     :functionName: the source function name
     */
    func assert(@autoclosure condition: () -> Bool, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString)
}


// MARK: - Utilities

internal func typeName<T>(value: T) -> String {
    
    return "'\(String(reflecting: value.dynamicType))'"
}

internal func typeName<T>(value: T.Type) -> String {
    
    return "'\(value)'"
}

internal func typeName(value: AnyClass) -> String {
    
    return "'\(value)'"
}

internal func typeName(name: String?) -> String {
    
    return "<\(name ?? "unknown")>"
}
