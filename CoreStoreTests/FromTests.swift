//
//  FromTests.swift
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


//MARK: - FromTests

final class FromTests: BaseTestCase {
    
    @objc
    dynamic func test_ThatFromClauses_ConfigureCorrectly() {
        
        do {
            
            let from = From<NSManagedObject>()
            XCTAssert(from.entityClass === NSManagedObject.self)
            XCTAssertNil(from.configurations)
        }
        do {
            
            let from = From<TestEntity1>()
            XCTAssert(from.entityClass === TestEntity1.self)
            XCTAssertNil(from.configurations)
        }
        do {
            
            let from = From<TestEntity1>("Config1")
            XCTAssert(from.entityClass === TestEntity1.self)
            XCTAssertEqual(from.configurations?.count, 1)
            XCTAssertEqual(from.configurations?[0], "Config1")
        }
        do {
            
            let from = From<TestEntity1>(nil, "Config1")
            XCTAssert(from.entityClass === TestEntity1.self)
            XCTAssertEqual(from.configurations?.count, 2)
            XCTAssertEqual(from.configurations?[0], nil)
            XCTAssertEqual(from.configurations?[1], "Config1")
        }
    }
    
    @objc
    dynamic func test_ThatFromClauses_ApplyToFetchRequestsCorrectlyForDefaultConfigurations() {
        
        self.prepareStack { (dataStack) in
            
            do {
                
                let from = From<TestEntity1>()
                
                let request = CoreStoreFetchRequest()
                let storesFound = from.applyToFetchRequest(request, context: dataStack.mainContext)
                XCTAssertTrue(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertEqual(affectedConfigurations, ["PF_DEFAULT_CONFIGURATION_NAME"])
            }
            do {
                
                let from = From<TestEntity1>("Config1")
                
                let request = CoreStoreFetchRequest()
                let storesFound = self.expectLogger([.logWarning]) {
                    
                    from.applyToFetchRequest(request, context: dataStack.mainContext)
                }
                XCTAssertFalse(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertTrue(affectedConfigurations.isEmpty)
            }
        }
    }
    
    @objc
    dynamic func test_ThatFromClauses_ApplyToFetchRequestsCorrectlyForSingleConfigurations() {
        
        self.prepareStack(configurations: ["Config1"]) { (dataStack) in
            
            do {
                
                let from = From<TestEntity1>()
                
                let request = CoreStoreFetchRequest()
                let storesFound = from.applyToFetchRequest(request, context: dataStack.mainContext)
                XCTAssertTrue(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertEqual(affectedConfigurations, ["Config1"])
            }
            do {
                
                let from = From<TestEntity1>("Config1")
                
                let request = CoreStoreFetchRequest()
                let storesFound = from.applyToFetchRequest(request, context: dataStack.mainContext)
                XCTAssertTrue(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertEqual(affectedConfigurations, ["Config1"])
            }
            do {
                
                let from = From<TestEntity1>("Config2")
                
                let request = CoreStoreFetchRequest()
                let storesFound = self.expectLogger([.logWarning]) {
                    
                    from.applyToFetchRequest(request, context: dataStack.mainContext)
                }
                XCTAssertFalse(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertTrue(affectedConfigurations.isEmpty)
            }
            do {
                
                let from = From<TestEntity2>()
                
                let request = CoreStoreFetchRequest()
                let storesFound = self.expectLogger([.logWarning]) {
                    
                    from.applyToFetchRequest(request, context: dataStack.mainContext)
                }
                XCTAssertFalse(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertTrue(affectedConfigurations.isEmpty)
            }
            do {
                
                let from = From<TestEntity2>("Config1")
                
                let request = CoreStoreFetchRequest()
                let storesFound = self.expectLogger([.logWarning]) {
                    
                    from.applyToFetchRequest(request, context: dataStack.mainContext)
                }
                XCTAssertFalse(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertTrue(affectedConfigurations.isEmpty)
            }
            do {
                
                let from = From<TestEntity2>("Config2")
                
                let request = CoreStoreFetchRequest()
                let storesFound = self.expectLogger([.logWarning]) {
                    
                    from.applyToFetchRequest(request, context: dataStack.mainContext)
                }
                XCTAssertFalse(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertTrue(affectedConfigurations.isEmpty)
            }
        }
    }
    
    @objc
    dynamic func test_ThatFromClauses_ApplyToFetchRequestsCorrectlyForDefaultAndCustomConfigurations() {
        
        self.prepareStack(configurations: [nil, "Config1"]) { (dataStack) in
            
            do {
                
                let from = From<TestEntity1>()
                
                let request = CoreStoreFetchRequest()
                let storesFound = from.applyToFetchRequest(request, context: dataStack.mainContext)
                XCTAssertTrue(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertEqual(Set(affectedConfigurations), ["PF_DEFAULT_CONFIGURATION_NAME", "Config1"] as Set)
            }
            do {
                
                let from = From<TestEntity1>("Config1")
                
                let request = CoreStoreFetchRequest()
                let storesFound = from.applyToFetchRequest(request, context: dataStack.mainContext)
                XCTAssertTrue(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertEqual(affectedConfigurations, ["Config1"])
            }
            do {
                
                let from = From<TestEntity1>("Config2")
                
                let request = CoreStoreFetchRequest()
                let storesFound = self.expectLogger([.logWarning]) {
                    
                    from.applyToFetchRequest(request, context: dataStack.mainContext)
                }
                XCTAssertFalse(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertTrue(affectedConfigurations.isEmpty)
            }
            do {
                
                let from = From<TestEntity2>()
                
                let request = CoreStoreFetchRequest()
                let storesFound = from.applyToFetchRequest(request, context: dataStack.mainContext)
                XCTAssertTrue(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertEqual(affectedConfigurations, ["PF_DEFAULT_CONFIGURATION_NAME"])
            }
            do {
                
                let from = From<TestEntity2>("Config1")
                
                let request = CoreStoreFetchRequest()
                let storesFound = self.expectLogger([.logWarning]) {
                    
                    from.applyToFetchRequest(request, context: dataStack.mainContext)
                }
                XCTAssertFalse(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertTrue(affectedConfigurations.isEmpty)
            }
            do {
                
                let from = From<TestEntity2>("Config2")
                
                let request = CoreStoreFetchRequest()
                let storesFound = self.expectLogger([.logWarning]) {
                    
                    from.applyToFetchRequest(request, context: dataStack.mainContext)
                }
                XCTAssertFalse(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertTrue(affectedConfigurations.isEmpty)
            }
        }
    }
    
    @objc
    dynamic func test_ThatFromClauses_ApplyToFetchRequestsCorrectlyForMultipleConfigurations() {
        
        self.prepareStack(configurations: ["Config1", "Config2"]) { (dataStack) in
            
            do {
                
                let from = From<TestEntity1>()
                
                let request = CoreStoreFetchRequest()
                let storesFound = from.applyToFetchRequest(request, context: dataStack.mainContext)
                XCTAssertTrue(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertEqual(affectedConfigurations, ["Config1"])
            }
            do {
                
                let from = From<TestEntity1>("Config1")
                
                let request = CoreStoreFetchRequest()
                let storesFound = from.applyToFetchRequest(request, context: dataStack.mainContext)
                XCTAssertTrue(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertEqual(affectedConfigurations, ["Config1"])
            }
            do {
                
                let from = From<TestEntity1>("Config2")
                
                let request = CoreStoreFetchRequest()
                let storesFound = self.expectLogger([.logWarning]) {
                    
                    from.applyToFetchRequest(request, context: dataStack.mainContext)
                }
                XCTAssertFalse(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertTrue(affectedConfigurations.isEmpty)
            }
            do {
                
                let from = From<TestEntity2>()
                
                let request = CoreStoreFetchRequest()
                let storesFound = from.applyToFetchRequest(request, context: dataStack.mainContext)
                XCTAssertTrue(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertEqual(affectedConfigurations, ["Config2"])
            }
            do {
                
                let from = From<TestEntity2>("Config1")
                
                let request = CoreStoreFetchRequest()
                let storesFound = self.expectLogger([.logWarning]) {
                    
                    from.applyToFetchRequest(request, context: dataStack.mainContext)
                }
                XCTAssertFalse(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertTrue(affectedConfigurations.isEmpty)
            }
            do {
                
                let from = From<TestEntity2>("Config2")
                
                let request = CoreStoreFetchRequest()
                let storesFound = from.applyToFetchRequest(request, context: dataStack.mainContext)
                XCTAssertTrue(storesFound)
                XCTAssertNotNil(request.entity)
                XCTAssertNotNil(request.safeAffectedStores)
                
                XCTAssert(from.entityClass == NSClassFromString(request.entity!.managedObjectClassName))
                
                let affectedConfigurations = request.safeAffectedStores!.map { $0.configurationName }
                XCTAssertEqual(affectedConfigurations, ["Config2"])
            }
        }
    }
}
