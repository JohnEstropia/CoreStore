//
//  HardcoreData.swift
//  HardcoreData
//
//  Copyright (c) 2014 John Rommel Estropia
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

import CoreData
import GCDKit


/**
HardcoreData - Simple, elegant, and smart Core Data management with Swift

The HardcoreData struct is the main entry point for all other APIs.
*/
public struct HardcoreData {
    
    /**
    The default DataStack instance to be used. If defaultStack is not set before the first time accessed, a default-configured DataStack will be created.
    
    Changing the defaultStack is thread safe.
    */
    public static var defaultStack: DataStack {
        
        get {
        
            self.defaultStackBarrierQueue.barrierSync {
        
                if self.defaultStackInstance == nil {
        
                    self.defaultStackInstance = DataStack()
                }
            }
            return self.defaultStackInstance!
        }
        set {
            
            self.defaultStackBarrierQueue.barrierAsync {
                
                self.defaultStackInstance = newValue
            }
        }
    }
    
    /**
    Using the defaultStack, begins a transaction asynchronously where NSManagedObject creates, updates, and deletes can be made.
    
    :param: closure the block where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent NSManagedObjectContext.
    */
    public static func performTransaction(closure: (transaction: DataTransaction) -> ()) {
        
        self.defaultStack.performTransaction(closure)
    }
    
    /**
    Using the defaultStack, begins a transaction asynchronously where NSManagedObject creates, updates, and deletes can be made.
    
    :param: closure the block where creates, updates, and deletes can be made to the transaction. Transaction blocks are executed serially in a background queue, and all changes are made from a concurrent NSManagedObjectContext.
    :returns: a SaveResult value indicating success or failure.
    */
    public static func performTransactionAndWait(closure: (transaction: DataTransaction) -> ()) -> SaveResult {
        
        return self.defaultStack.performTransactionAndWait(closure)
    }
    
    
    public enum LogLevel {
        
        case Trace
        case Notice
        case Alert
        case Fatal
    }
    
    public typealias LogHandlerType = (level: LogLevel, message: String, fileName: StaticString, lineNumber: UWord, functionName: StaticString) -> ()
    
    public typealias ErrorHandlerType = (error: NSError, message: String, fileName: StaticString, lineNumber: UWord, functionName: StaticString) -> ()
    
    public typealias AssertionHandlerType = (condition: @autoclosure() -> Bool, message: String, fileName: StaticString, lineNumber: UWord, functionName: StaticString) -> ()
    
    
    /**
    Sets the closure that handles all logging that occur within HardcoreData. The default logHandler logs via println() only when DEBUG is defined.
    */
    public static func setLogHandler(logHandler: LogHandlerType) {
        
        self.logHandler = logHandler
    }
    
    /**
    Sets the closure that handles all errors that occur within HardcoreData. The default errorHandler logs via println() only when DEBUG is defined.
    */
    public static func setErrorHandler(errorHandler: ErrorHandlerType) {
        
        self.errorHandler = errorHandler
    }
    
    /**
    Sets the closure that handles all assertions that occur within HardcoreData. The default assertHandler calls assert().
    */
    public static func setAssertionHandler(assertionHandler: AssertionHandlerType) {
        
        self.assertionHandler = assertionHandler
    }
    
    internal static func log(level: LogLevel, message: String, fileName: StaticString = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
        
        self.logHandler(
            level: level,
            message: message,
            fileName: fileName,
            lineNumber: lineNumber,
            functionName: functionName)
    }
    
    internal static func handleError(error: NSError, _ message: String, fileName: StaticString = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
        
        self.errorHandler(
            error: error,
            message: message,
            fileName: fileName,
            lineNumber: lineNumber,
            functionName: functionName)
    }
    
    internal static func assert(condition: @autoclosure() -> Bool, _ message: String, fileName: StaticString = __FILE__, lineNumber: UWord = __LINE__, functionName: StaticString = __FUNCTION__) {
        
        self.assertionHandler(
            condition: condition,
            message: message,
            fileName: fileName,
            lineNumber: lineNumber,
            functionName: functionName)
    }
    
    
    private static let defaultStackBarrierQueue = GCDQueue.createConcurrent("com.hardcoredata.defaultstackbarrierqueue")
    
    private static var defaultStackInstance: DataStack?
    
    private static var logHandler: LogHandlerType = { (level: LogLevel, message: String, fileName: StaticString, lineNumber: UWord, functionName: StaticString) -> () in
        
        #if DEBUG
            println("[HardcoreData] \(fileName.stringValue.lastPathComponent):\(lineNumber) \(functionName)\n  ↪︎ \(message)\n")
        #endif
    }
    
    private static var errorHandler: ErrorHandlerType = { (error: NSError, message: String, fileName: StaticString, lineNumber: UWord, functionName: StaticString) -> () in
        
        #if DEBUG
            println("[HardcoreData] \(fileName.stringValue.lastPathComponent):\(lineNumber) \(functionName)\n  ↪︎ \(message): \(error)\n")
        #endif
    }
    
    private static var assertionHandler: AssertionHandlerType = { (condition: @autoclosure() -> Bool, message: String, fileName: StaticString, lineNumber: UWord, functionName: StaticString) -> () in
        
        #if DEBUG
            assert(condition, message, file: fileName, line: lineNumber)
        #endif
    }
}


