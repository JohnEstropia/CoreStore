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


final class MigrationTests: BaseTestCase {
    func test_ThatCustomSchemaMappingProvider_CanInferTransformation() {
        struct V1 {
            class Animal: CoreStoreObject {
                var name = Value.Required<String>("name", initial: "")
            }
        }
        
        struct V2 {
            class Animal: CoreStoreObject {
                var nickname = Value.Required<String>("nickname", initial: "", renamingIdentifier: "name")
            }
        }
        
        let schemaV1: CoreStoreSchema = CoreStoreSchema(modelVersion: "V1", entities: [Entity<V1.Animal>("Animal")])
        let schemaV2: CoreStoreSchema = CoreStoreSchema(modelVersion: "V2", entities: [Entity<V2.Animal>("Animal")])
        let migration: CustomSchemaMappingProvider = CustomSchemaMappingProvider(from: "V1", to: "V2", entityMappings: [])
        
        /// Create the source store and data set.
        withExtendedLifetime(DataStack(schemaV1), { stack in
            try! stack.addStorageAndWait(SQLiteStore())
            try! stack.perform(synchronous: { $0.create(Into<V1.Animal>()).name.value = "Willy" })
            try! stack.perform(synchronous: { XCTAssertEqual(try! $0.fetchOne(From<V1.Animal>())?.name.value, "Willy") })
        })
        
        let stack: DataStack = DataStack(schemaV1, schemaV2, migrationChain: ["V1", "V2"])
        let store: SQLiteStore = SQLiteStore(fileURL: SQLiteStore.defaultFileURL, migrationMappingProviders: [migration])
        
        let expectation: XCTestExpectation = self.expectation(description: "migration-did-complete")
        
        _ = stack.addStorage(store, completion: {
            switch $0 {
            case .success(_):
                XCTAssertEqual(try! stack.perform(synchronous: { try $0.fetchOne(From<V2.Animal>())?.nickname.value }), "Willy")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        })
        
        self.waitAndCheckExpectations()
    }
}
