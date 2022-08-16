//
//  BaseTestCase.swift
//  CoreStore
//
//  Copyright © 2018 John Rommel Estropia
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

#if !SWIFT_PACKAGE

extension Bundle {
    
    static var module: Bundle {
        return Bundle(for: BaseTestCase.self)
    }
}

#endif


// MARK: - BaseTestCase

class BaseTestCase: XCTestCase {
    
    // MARK: Internal
    
    @nonobjc
    func prepareStack(configurations: [ModelConfiguration] = [nil], _ closure: (_ dataStack: DataStack) throws -> Void) {
        
        let stack = DataStack(
            xcodeModelName: "Model",
            bundle: Bundle.module
        )
        do {
            
            try configurations.forEach {
                
                try stack.addStorageAndWait(
                    SQLiteStore(
                        fileURL: SQLiteStore.defaultRootDirectory
                            .appendingPathComponent(UUID().uuidString)
                            .appendingPathComponent("\(Self.self)_\(($0 ?? "-null-")).sqlite"),
                        configuration: $0,
                        localStorageOptions: .recreateStoreOnModelMismatch
                    )
                )
            }
            try closure(stack)
        }
        catch let error as NSError {
            
            XCTFail(error.coreStoreDumpString)
        }
        self.addTeardownBlock {
            stack.unsafeRemoveAllPersistentStoresAndWait()
        }
    }
    
    @nonobjc
    func expectLogger<T>(_ expectations: [TestLogger.Expectation], closure: () throws -> T) rethrows -> T {
        
        CoreStoreDefaults.logger = TestLogger(self.prepareLoggerExpectations(expectations))
        defer {
            
            self.checkExpectationsImmediately()
            CoreStoreDefaults.logger = TestLogger([:])
        }
        return try closure()
    }
    
    @nonobjc
    func expectLogger(_ expectations: [TestLogger.Expectation: XCTestExpectation]) {
        
        CoreStoreDefaults.logger = TestLogger(expectations)
    }

    @nonobjc
    func expectError<T>(code: CoreStoreErrorCode, closure: () throws -> T) {

        CoreStoreDefaults.logger = TestLogger(self.prepareLoggerExpectations([.logError]))
        defer {

            self.checkExpectationsImmediately()
            CoreStoreDefaults.logger = TestLogger([:])
        }
        do {

            _ = try closure()
        }
        catch let error as CoreStoreError {

            if error.errorCode == code.rawValue {

                return
            }
            XCTFail("Expected error code \(code) different from actual error: \((error as NSError).coreStoreDumpString)")
        }
        catch {

            XCTFail("Error not wrapped as \(Internals.typeName(CoreStoreError.self)): \((error as NSError).coreStoreDumpString)")
        }
    }
    
    @nonobjc
    func prepareLoggerExpectations(_ expectations: [TestLogger.Expectation]) -> [TestLogger.Expectation: XCTestExpectation] {
        
        var testExpectations: [TestLogger.Expectation: XCTestExpectation] = [:]
        for expectation in expectations {
            
            testExpectations[expectation] = self.expectation(description: "Logger Expectation: \(expectation)")
        }
        return testExpectations
    }
    
    @nonobjc
    func checkExpectationsImmediately() {
        
        self.waitForExpectations(timeout: 0, handler: { _ in })
    }
    
    @nonobjc
    func waitAndCheckExpectations() {
        
        self.waitForExpectations(timeout: 10, handler: {_ in })
    }
    
    // MARK: XCTestCase
    
    override func setUp() {
        
        super.setUp()
        self.deleteStores()
        CoreStoreDefaults.logger = TestLogger([:])
    }
    
    override func tearDown() {
        
        CoreStoreDefaults.logger = DefaultLogger()
        self.deleteStores()
        super.tearDown()
    }
    
    
    // MARK: Private
    
    private func deleteStores() {
        
        _ = try? FileManager.default.removeItem(at: SQLiteStore.defaultRootDirectory)
    }
}


// MARK: - TestLogger

class TestLogger: CoreStoreLogger {
    
    enum Expectation {
        
        case logWarning
        case logFatal
        case logError
        case assertionFailure
        case fatalError
    }
    
    init(_ expectations: [Expectation: XCTestExpectation]) {
        
        self.expectations = expectations
    }
    
    
    // MARK: CoreStoreLogger
    
    var enableObjectConcurrencyDebugging: Bool = true
    
    func log(level: LogLevel, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        switch level {
            
        case .warning:  self.fulfill(.logWarning)
        case .fatal:    self.fulfill(.logFatal)
        default:        break
        }
    }
    
    func log(error: CoreStoreError, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        self.fulfill(.logError)
    }
    
    func assert(_ condition: @autoclosure () -> Bool, message: @autoclosure () -> String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        if condition() {
            
            return
        }
        self.fulfill(.assertionFailure)
    }
    
    func abort(_ message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        self.fulfill(.fatalError)
    }
    
    
    // MARK: Private
    
    private var expectations: [Expectation: XCTestExpectation]
    
    private func fulfill(_ expectation: Expectation) {
        
        if let instance = self.expectations[expectation] {
            
            instance.fulfill()
            self.expectations[expectation] = nil
        }
        else {
            
            XCTFail("Unexpected Logger Action: \(expectation)")
        }
    }
}
