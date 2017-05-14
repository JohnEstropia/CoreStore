//
//  ErrorTests.swift
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


// MARK: - ErrorTests

final class ErrorTests: XCTestCase {

    @objc
    dynamic func test_ThatUnknownErrors_BridgeCorrectly() {
        
        let error = CoreStoreError.unknown
        XCTAssertEqual((error as NSError).domain, CoreStoreErrorDomain)
        XCTAssertEqual((error as NSError).code, CoreStoreErrorCode.unknownError.rawValue)
        
        let userInfo: NSDictionary = [:]
        
        let objcError = error.bridgeToObjectiveC
        XCTAssertEqual(error, objcError.bridgeToSwift)
        XCTAssertEqual(objcError.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError.code, CoreStoreErrorCode.unknownError.rawValue)
        XCTAssertEqual(objcError.userInfo as NSDictionary, userInfo)
        
        let objcError2 = objcError.bridgeToSwift.bridgeToObjectiveC
        XCTAssertEqual(error, objcError2.bridgeToSwift)
        XCTAssertEqual(objcError2.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError2.code, CoreStoreErrorCode.unknownError.rawValue)
        XCTAssertEqual(objcError2.userInfo as NSDictionary, userInfo)
    }
    
    @objc
    dynamic func test_ThatDifferentStorageExistsAtURLErrors_BridgeCorrectly() {
        
        let dummyURL = URL(string: "file:///test1/test2.sqlite")!
        
        let error = CoreStoreError.differentStorageExistsAtURL(existingPersistentStoreURL: dummyURL)
        XCTAssertEqual((error as NSError).domain, CoreStoreErrorDomain)
        XCTAssertEqual((error as NSError).code, CoreStoreErrorCode.differentStorageExistsAtURL.rawValue)
        
        let userInfo: NSDictionary = [
            "existingPersistentStoreURL": dummyURL
        ]
        let objcError = error.bridgeToObjectiveC
        XCTAssertEqual(error, objcError.bridgeToSwift)
        XCTAssertEqual(objcError.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError.code, CoreStoreErrorCode.differentStorageExistsAtURL.rawValue)
        XCTAssertEqual(objcError.userInfo as NSDictionary, userInfo)
        
        let objcError2 = objcError.bridgeToSwift.bridgeToObjectiveC
        XCTAssertEqual(error, objcError2.bridgeToSwift)
        XCTAssertEqual(objcError2.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError2.code, CoreStoreErrorCode.differentStorageExistsAtURL.rawValue)
        XCTAssertEqual(objcError2.userInfo as NSDictionary, userInfo)
    }
    
    @objc
    dynamic func test_ThatMappingModelNotFoundErrors_BridgeCorrectly() {
        
        let dummyURL = URL(string: "file:///test1/test2.sqlite")!
        
        let schemaHistory = SchemaHistory(
            XcodeDataModelSchema.from(
                modelName: "Model",
                bundle: Bundle(for: type(of: self))
            )
        )
        let version = "1.0.0"
        
        let error = CoreStoreError.mappingModelNotFound(localStoreURL: dummyURL, targetModel: schemaHistory.rawModel, targetModelVersion: version)
        XCTAssertEqual((error as NSError).domain, CoreStoreErrorDomain)
        XCTAssertEqual((error as NSError).code, CoreStoreErrorCode.mappingModelNotFound.rawValue)
        
        let userInfo: NSDictionary = [
            "localStoreURL": dummyURL,
            "targetModel": schemaHistory.rawModel,
            "targetModelVersion": version
        ]
        let objcError = error.bridgeToObjectiveC
        XCTAssertEqual(error, objcError.bridgeToSwift)
        XCTAssertEqual(objcError.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError.code, CoreStoreErrorCode.mappingModelNotFound.rawValue)
        XCTAssertEqual(objcError.userInfo as NSDictionary, userInfo)
        
        let objcError2 = objcError.bridgeToSwift.bridgeToObjectiveC
        XCTAssertEqual(error, objcError2.bridgeToSwift)
        XCTAssertEqual(objcError2.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError2.code, CoreStoreErrorCode.mappingModelNotFound.rawValue)
        XCTAssertEqual(objcError2.userInfo as NSDictionary, userInfo)
    }
    
    @objc
    dynamic func test_ThatProgressiveMigrationRequiredErrors_BridgeCorrectly() {
        
        let dummyURL = URL(string: "file:///test1/test2.sqlite")!
        
        let error = CoreStoreError.progressiveMigrationRequired(localStoreURL: dummyURL)
        XCTAssertEqual((error as NSError).domain, CoreStoreErrorDomain)
        XCTAssertEqual((error as NSError).code, CoreStoreErrorCode.progressiveMigrationRequired.rawValue)
        
        let userInfo: NSDictionary = [
            "localStoreURL": dummyURL
        ]
        let objcError = error.bridgeToObjectiveC
        XCTAssertEqual(error, objcError.bridgeToSwift)
        XCTAssertEqual(objcError.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError.code, CoreStoreErrorCode.progressiveMigrationRequired.rawValue)
        XCTAssertEqual(objcError.userInfo as NSDictionary, userInfo)
        
        let objcError2 = objcError.bridgeToSwift.bridgeToObjectiveC
        XCTAssertEqual(error, objcError2.bridgeToSwift)
        XCTAssertEqual(objcError2.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError2.code, CoreStoreErrorCode.progressiveMigrationRequired.rawValue)
        XCTAssertEqual(objcError2.userInfo as NSDictionary, userInfo)
    }
    
    @objc
    dynamic func test_ThatInternalErrorErrors_BridgeCorrectly() {
        
        let internalError = NSError(
            domain: "com.dummy",
            code: 123,
            userInfo: [
                "key1": "value1",
                "key2": 2,
                "key3": Date()
            ]
        )
        let error = CoreStoreError(internalError)
        XCTAssertEqual((error as NSError).domain, CoreStoreErrorDomain)
        XCTAssertEqual((error as NSError).code, CoreStoreErrorCode.internalError.rawValue)
        
        let userInfo: NSDictionary = [
            "NSError": internalError
        ]
        let objcError = error.bridgeToObjectiveC
        XCTAssertEqual(error, objcError.bridgeToSwift)
        XCTAssertEqual(objcError.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError.code, CoreStoreErrorCode.internalError.rawValue)
        XCTAssertEqual(objcError.userInfo as NSDictionary, userInfo)
        
        let objcError2 = objcError.bridgeToSwift.bridgeToObjectiveC
        XCTAssertEqual(error, objcError2.bridgeToSwift)
        XCTAssertEqual(objcError2.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError2.code, CoreStoreErrorCode.internalError.rawValue)
        XCTAssertEqual(objcError2.userInfo as NSDictionary, userInfo)
    }
}
