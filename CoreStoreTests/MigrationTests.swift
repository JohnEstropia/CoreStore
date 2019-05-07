//
//  MigrationChainTests.swift
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


// MARK: - MigrationTests

final class MigrationTests: BaseTestCase {
    
    func test_ThatEntityDescriptionExtension_CanMapAttributes() {
        
        // Should match attributes by renaming identifier.
        do {
            let src = NSEntityDescription([NSAttributeDescription("foo")])
            let dst = NSEntityDescription([NSAttributeDescription("bar", renamingIdentifier: "foo")])
            
            var map: [NSAttributeDescription: NSAttributeDescription] = [:]
            XCTAssertNoThrow(map = try dst.mapAttributes(in: src))
            XCTAssertEqual(map.count, 1)
            XCTAssertEqual(map.keys.first?.renamingIdentifier, "foo")
            XCTAssertEqual(map.values.first?.name, "foo")
        }
        
        // Should match attributes by name when matching by renaming identifier fails.
        do {
            let src = NSEntityDescription([NSAttributeDescription("bar")])
            let dst = NSEntityDescription([NSAttributeDescription("bar", renamingIdentifier: "foo")])
            
            var map: [NSAttributeDescription: NSAttributeDescription] = [:]
            XCTAssertNoThrow(map = try dst.mapAttributes(in: src))
            XCTAssertEqual(map.count, 1)
            XCTAssertEqual(map.keys.first?.renamingIdentifier, "foo")
            XCTAssertEqual(map.keys.first?.name, "bar")
            XCTAssertEqual(map.values.first?.name, "bar")
        }
        
        // Should not throw exception when optional attributes cannot be matched.
        do {
            let src = NSEntityDescription([NSAttributeDescription("foo")])
            let dst = NSEntityDescription([NSAttributeDescription("bar")])
            
            var map: [NSAttributeDescription: NSAttributeDescription] = [:]
            XCTAssertNoThrow(map = try dst.mapAttributes(in: src))
            XCTAssertEqual(map.count, 0)
        }
        
        // Should not throw exception when required attributes with default value cannot be matched.
        do {
            let src = NSEntityDescription([NSAttributeDescription("foo")])
            let dst = NSEntityDescription([NSAttributeDescription("bar", optional: false, defaultValue: "baz")])
            
            var map: [NSAttributeDescription: NSAttributeDescription] = [:]
            XCTAssertNoThrow(map = try dst.mapAttributes(in: src))
            XCTAssertEqual(map.count, 0)
        }
        
        // Should throw exception when required attributes without default value cannot be matched.
        do {
            let src = NSEntityDescription([NSAttributeDescription("foo")])
            let dst = NSEntityDescription([NSAttributeDescription("bar", optional: false)])
            XCTAssertThrowsError(try dst.mapAttributes(in: src))
        }
    }
    
    func test_ThatCustomSchemaMappingProvider_CanDeleteAndInsertEntitiesWithCustomEntityMapping() {
        class Foo: CoreStoreObject {
            var name = Value.Optional<String>("name")
        }
        
        class Bar: CoreStoreObject {
            var nickname = Value.Optional<String>("nickname", renamingIdentifier: "name")
        }
        
        let src: CoreStoreSchema = CoreStoreSchema(modelVersion: "1", entities: [Entity<Foo>("Foo")])
        let dst: CoreStoreSchema = CoreStoreSchema(modelVersion: "2", entities: [Entity<Bar>("Bar")])
        
        let migration: CustomSchemaMappingProvider = CustomSchemaMappingProvider(from: "1", to: "2", entityMappings: [
            .deleteEntity(sourceEntity: "Foo"),
            .insertEntity(destinationEntity: "Bar")
        ])
        
        /// Create the source store and data set.
        withExtendedLifetime(DataStack(src), { stack in
            try! stack.addStorageAndWait(SQLiteStore())
            try! stack.perform(synchronous: { $0.create(Into<Foo>()).name.value = "Willy" })
        })
        
        let expectation: XCTestExpectation = self.expectation(description: "migration-did-complete")
        
        withExtendedLifetime(DataStack(src, dst, migrationChain: ["1", "2"]), { stack in
            _ = stack.addStorage(SQLiteStore(fileURL: SQLiteStore.defaultFileURL, migrationMappingProviders: [migration]), completion: {
                switch $0 {
                case .success(_):
                    XCTAssertEqual(stack.modelSchema.rawModel().entities.count, 1)
                    try! stack.perform(synchronous: { $0.create(Into<Bar>()).nickname.value = "Bobby" })
                case .failure(let error):
                    XCTFail("\(error)")
                }
                expectation.fulfill()
            })
        })
        
        self.waitAndCheckExpectations()
    }
    
    func test_ThatCustomSchemaMappingProvider_CanCopyEntityWithCustomEntityMapping() {
        class Foo: CoreStoreObject {
            var name = Value.Required<String>("name", initial: "")
        }
        
        // Todo: The way this handles different version locks is flaky… It fails face on the ground in debug, but seems
        // todo: to work fine in production, yet it's not clear if it transforms everything as expected.
        
        let src: CoreStoreSchema = CoreStoreSchema(modelVersion: "1", entities: [Entity<Foo>("Foo")])
        let dst: CoreStoreSchema = CoreStoreSchema(modelVersion: "2", entities: [Entity<Foo>("Foo")])
        
        XCTAssertEqual(dst.rawModel().entities.first!.versionHash, src.rawModel().entities.first!.versionHash)
        
        let migration: CustomSchemaMappingProvider = CustomSchemaMappingProvider(from: "1", to: "2", entityMappings: [
            .copyEntity(sourceEntity: "Foo", destinationEntity: "Foo")
        ])
        
        /// Create the source store and data set.
        withExtendedLifetime(DataStack(src), { stack in
            try! stack.addStorageAndWait(SQLiteStore())
            try! stack.perform(synchronous: { $0.create(Into<Foo>()).name.value = "Willy" })
        })
        
        let expectation: XCTestExpectation = self.expectation(description: "migration-did-complete")
        
        withExtendedLifetime(DataStack(src, dst, migrationChain: ["1", "2"]), { stack in
            _ = stack.addStorage(SQLiteStore(fileURL: SQLiteStore.defaultFileURL, migrationMappingProviders: [migration]), completion: {
                switch $0 {
                case .success(_):
                    XCTAssertEqual(stack.modelSchema.rawModel().entities.count, 1)
                    XCTAssertEqual(try! stack.fetchCount(From<Foo>()), 1)
                    try! stack.perform(synchronous: { $0.create(Into<Foo>()).name.value = "Bobby" })
                case .failure(let error):
                    XCTFail("\(error)")
                }
                expectation.fulfill()
            })
        })
        
        self.waitAndCheckExpectations()
    }
    
    func test_ThatCustomSchemaMappingProvider_CanTransformEntityWithCustomEntityMapping() {
        class Foo: CoreStoreObject {
            var name = Value.Required<String>("name", initial: "")
            var futile = Value.Required<String>("futile", initial: "")
        }
        
        class Bar: CoreStoreObject {
            var firstName = Value.Required<String>("firstName", initial: "", renamingIdentifier: "name")
            var lastName = Value.Required<String>("lastName", initial: "", renamingIdentifier: "placeholder")
            var age = Value.Required<Int>("age", initial: 18)
            var gender = Value.Optional<String>("gender")
        }
        
        let src: CoreStoreSchema = CoreStoreSchema(modelVersion: "1", entities: [Entity<Foo>("Foo")])
        let dst: CoreStoreSchema = CoreStoreSchema(modelVersion: "2", entities: [Entity<Bar>("Bar")])
        
        let migration: CustomSchemaMappingProvider = CustomSchemaMappingProvider(from: "1", to: "2", entityMappings: [
            .transformEntity(sourceEntity: "Foo", destinationEntity: "Bar", transformer: CustomSchemaMappingProvider.CustomMapping.inferredTransformation)
        ])
        
        /// Create the source store and data set.
        withExtendedLifetime(DataStack(src), { stack in
            try! stack.addStorageAndWait(SQLiteStore())
            try! stack.perform(synchronous: { $0.create(Into<Foo>()).name.value = "Willy" })
        })
        
        let expectation: XCTestExpectation = self.expectation(description: "migration-did-complete")
        
        withExtendedLifetime(DataStack(src, dst, migrationChain: ["1", "2"]), { stack in
            _ = stack.addStorage(SQLiteStore(fileURL: SQLiteStore.defaultFileURL, migrationMappingProviders: [migration]), completion: {
                switch $0 {
                case .success(_):
                    XCTAssertEqual(stack.modelSchema.rawModel().entities.count, 1)
                    XCTAssertEqual(try! stack.fetchCount(From<Bar>()), 1)
                    try! stack.perform(synchronous: { $0.create(Into<Bar>()).firstName.value = "Bobby" })
                case .failure(let error):
                    XCTFail("\(error)")
                }
                expectation.fulfill()
            })
        })
        
        self.waitAndCheckExpectations()
    }
}

extension NSEntityDescription {
    fileprivate convenience init(_ properties: [NSPropertyDescription]) {
        self.init()
        self.properties = properties
    }
}

extension NSAttributeDescription {
    fileprivate convenience init(_ name: String, renamingIdentifier: String? = nil, optional: Bool? = nil, defaultValue: Any? = nil) {
        self.init()
        self.name = name
        self.renamingIdentifier = renamingIdentifier
        self.isOptional = optional ?? true
        self.defaultValue = defaultValue
    }
}
