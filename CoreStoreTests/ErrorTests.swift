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
        
        let error = CoreStoreError.Unknown
        XCTAssertEqual((error as NSError).domain, CoreStoreErrorDomain)
        XCTAssertEqual((error as NSError).code, CoreStoreErrorCode.UnknownError.rawValue)
        
        let userInfo: NSDictionary = [:]
        
        let objcError = error.bridgeToObjectiveC
        XCTAssertEqual(error, objcError.bridgeToSwift)
        XCTAssertEqual(objcError.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError.code, CoreStoreErrorCode.UnknownError.rawValue)
        XCTAssertEqual(objcError.userInfo, userInfo)
        
        let objcError2 = objcError.bridgeToSwift.bridgeToObjectiveC
        XCTAssertEqual(error, objcError2.bridgeToSwift)
        XCTAssertEqual(objcError2.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError2.code, CoreStoreErrorCode.UnknownError.rawValue)
        XCTAssertEqual(objcError2.userInfo, userInfo)
    }
    
    @objc
    dynamic func test_ThatDifferentStorageExistsAtURLErrors_BridgeCorrectly() {
        
        let dummyURL = NSURL(string: "file:///test1/test2.sqlite")!
        
        let error = CoreStoreError.DifferentStorageExistsAtURL(existingPersistentStoreURL: dummyURL)
        XCTAssertEqual((error as NSError).domain, CoreStoreErrorDomain)
        XCTAssertEqual((error as NSError).code, CoreStoreErrorCode.DifferentPersistentStoreExistsAtURL.rawValue)
        
        let userInfo: NSDictionary = [
            "existingPersistentStoreURL": dummyURL
        ]
        let objcError = error.bridgeToObjectiveC
        XCTAssertEqual(error, objcError.bridgeToSwift)
        XCTAssertEqual(objcError.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError.code, CoreStoreErrorCode.DifferentPersistentStoreExistsAtURL.rawValue)
        XCTAssertEqual(objcError.userInfo, userInfo)
        
        let objcError2 = objcError.bridgeToSwift.bridgeToObjectiveC
        XCTAssertEqual(error, objcError2.bridgeToSwift)
        XCTAssertEqual(objcError2.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError2.code, CoreStoreErrorCode.DifferentPersistentStoreExistsAtURL.rawValue)
        XCTAssertEqual(objcError2.userInfo, userInfo)
    }
    
    @objc
    dynamic func test_ThatMappingModelNotFoundErrors_BridgeCorrectly() {
        
        let dummyURL = NSURL(string: "file:///test1/test2.sqlite")!
        
        let model = NSManagedObjectModel.fromBundle(NSBundle(forClass: self.dynamicType), modelName: "Model")
        let version = "1.0.0"
        
        let error = CoreStoreError.MappingModelNotFound(localStoreURL: dummyURL, targetModel: model, targetModelVersion: version)
        XCTAssertEqual((error as NSError).domain, CoreStoreErrorDomain)
        XCTAssertEqual((error as NSError).code, CoreStoreErrorCode.MappingModelNotFound.rawValue)
        
        let userInfo: NSDictionary = [
            "localStoreURL": dummyURL,
            "targetModel": model,
            "targetModelVersion": version
        ]
        let objcError = error.bridgeToObjectiveC
        XCTAssertEqual(error, objcError.bridgeToSwift)
        XCTAssertEqual(objcError.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError.code, CoreStoreErrorCode.MappingModelNotFound.rawValue)
        XCTAssertEqual(objcError.userInfo, userInfo)
        
        let objcError2 = objcError.bridgeToSwift.bridgeToObjectiveC
        XCTAssertEqual(error, objcError2.bridgeToSwift)
        XCTAssertEqual(objcError2.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError2.code, CoreStoreErrorCode.MappingModelNotFound.rawValue)
        XCTAssertEqual(objcError2.userInfo, userInfo)
    }
    
    @objc
    dynamic func test_ThatProgressiveMigrationRequiredErrors_BridgeCorrectly() {
        
        let dummyURL = NSURL(string: "file:///test1/test2.sqlite")!
        
        let error = CoreStoreError.ProgressiveMigrationRequired(localStoreURL: dummyURL)
        XCTAssertEqual((error as NSError).domain, CoreStoreErrorDomain)
        XCTAssertEqual((error as NSError).code, CoreStoreErrorCode.ProgressiveMigrationRequired.rawValue)
        
        let userInfo: NSDictionary = [
            "localStoreURL": dummyURL
        ]
        let objcError = error.bridgeToObjectiveC
        XCTAssertEqual(error, objcError.bridgeToSwift)
        XCTAssertEqual(objcError.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError.code, CoreStoreErrorCode.ProgressiveMigrationRequired.rawValue)
        XCTAssertEqual(objcError.userInfo, userInfo)
        
        let objcError2 = objcError.bridgeToSwift.bridgeToObjectiveC
        XCTAssertEqual(error, objcError2.bridgeToSwift)
        XCTAssertEqual(objcError2.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError2.code, CoreStoreErrorCode.ProgressiveMigrationRequired.rawValue)
        XCTAssertEqual(objcError2.userInfo, userInfo)
    }
    
    @objc
    dynamic func test_ThatInternalErrorErrors_BridgeCorrectly() {
        
        let internalError = NSError(
            domain: "com.dummy",
            code: 123,
            userInfo: [
                "key1": "value1",
                "key2": 2,
                "key3": NSDate()
            ]
        )
        let error = CoreStoreError(internalError)
        XCTAssertEqual((error as NSError).domain, CoreStoreErrorDomain)
        XCTAssertEqual((error as NSError).code, CoreStoreErrorCode.InternalError.rawValue)
        
        let userInfo: NSDictionary = [
            "NSError": internalError
        ]
        let objcError = error.bridgeToObjectiveC
        XCTAssertEqual(error, objcError.bridgeToSwift)
        XCTAssertEqual(objcError.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError.code, CoreStoreErrorCode.InternalError.rawValue)
        XCTAssertEqual(objcError.userInfo, userInfo)
        
        let objcError2 = objcError.bridgeToSwift.bridgeToObjectiveC
        XCTAssertEqual(error, objcError2.bridgeToSwift)
        XCTAssertEqual(objcError2.domain, CoreStoreErrorDomain)
        XCTAssertEqual(objcError2.code, CoreStoreErrorCode.InternalError.rawValue)
        XCTAssertEqual(objcError2.userInfo, userInfo)
    }
}
