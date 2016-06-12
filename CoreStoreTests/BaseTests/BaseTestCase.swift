//
//  BaseTestCase.swift
//  CoreStore
//
//  Copyright © 2016 John Rommel Estropia
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

import XCTest

@testable
import CoreStore


// MARK: - BaseTestCase

class BaseTestCase: XCTestCase {
    
    // MARK: Internal
    
    @nonobjc
    func prepareStack<T>(configurations configurations: [String?] = [nil], @noescape _ closure: (dataStack: DataStack) -> T) -> T {
        
        let stack = DataStack(
            modelName: "Model",
            bundle: NSBundle(forClass: self.dynamicType)
        )
        do {
            
            try configurations.forEach {
                
                try stack.addStorageAndWait(
                    SQLiteStore(
                        fileURL: SQLiteStore.defaultRootDirectory
                            .URLByAppendingPathComponent(NSUUID().UUIDString)
                            .URLByAppendingPathComponent("\(self.dynamicType)_\(($0 ?? "-null-")).sqlite"),
                        configuration: $0,
                        localStorageOptions: .RecreateStoreOnModelMismatch
                    )
                )
            }
        }
        catch let error as NSError {
            
            XCTFail(error.coreStoreDumpString)
        }
        return closure(dataStack: stack)
    }
    
    @nonobjc
    func expectLogger<T>(expectations: [TestLogger.Expectation], @noescape closure: () -> T) -> T {
        
        CoreStore.logger = TestLogger(self.prepareLoggerExpectations(expectations))
        defer {
            
            self.checkExpectationsImmediately()
            CoreStore.logger = TestLogger([:])
        }
        return closure()
    }
    
    @nonobjc
    func expectLogger(expectations: [TestLogger.Expectation: XCTestExpectation]) {
        
        CoreStore.logger = TestLogger(expectations)
    }
    
    @nonobjc
    func prepareLoggerExpectations(expectations: [TestLogger.Expectation]) -> [TestLogger.Expectation: XCTestExpectation] {
        
        var testExpectations: [TestLogger.Expectation: XCTestExpectation] = [:]
        for expectation in expectations {
            
            testExpectations[expectation] = self.expectationWithDescription("Logger Expectation: \(expectation)")
        }
        return testExpectations
    }
    
    @nonobjc
    func checkExpectationsImmediately() {
        
        self.waitForExpectationsWithTimeout(0, handler: nil)
    }
    
    @nonobjc
    func waitAndCheckExpectations() {
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    // MARK: XCTestCase
    
    override func setUp() {
        
        super.setUp()
        self.deleteStores()
        CoreStore.logger = TestLogger([:])
    }
    
    override func tearDown() {
        
        CoreStore.logger = DefaultLogger()
        self.deleteStores()
        super.tearDown()
    }
    
    
    // MARK: Private
    
    private func deleteStores() {
        
        _ = try? NSFileManager.defaultManager().removeItemAtURL(SQLiteStore.defaultRootDirectory)
    }
}


// MARK: - TestLogger

class TestLogger: CoreStoreLogger {
    
    enum Expectation {
        
        case LogWarning
        case LogFatal
        case LogError
        case AssertionFailure
        case FatalError
    }
    
    init(_ expectations: [Expectation: XCTestExpectation]) {
        
        self.expectations = expectations
    }
    
    
    // MARK: CoreStoreLogger
    
    func log(level level: LogLevel, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        switch level {
            
        case .Warning:  self.fulfill(.LogWarning)
        case .Fatal:    self.fulfill(.LogFatal)
        default:        break
        }
    }
    
    func log(error error: CoreStoreError, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        self.fulfill(.LogError)
    }
    
    func assert(@autoclosure condition: () -> Bool, @autoclosure message: () -> String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        if condition() {
            
            return
        }
        self.fulfill(.AssertionFailure)
    }
    
    func abort(message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        self.fulfill(.FatalError)
    }
    
    
    // MARK: Private
    
    private var expectations: [Expectation: XCTestExpectation]
    
    private func fulfill(expectation: Expectation) {
        
        if let instance = self.expectations[expectation] {
            
            instance.fulfill()
            self.expectations[expectation] = nil
        }
        else {
            
            XCTFail("Unexpected Logger Action: \(expectation)")
        }
    }
}
