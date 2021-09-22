//
//  CSSQLiteStore.swift
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

import Foundation
import CoreData


// MARK: - CSSQLiteStore

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
@objc
public final class CSSQLiteStore: NSObject, CSLocalStorage, CoreStoreObjectiveCType {

    @objc
    public convenience init(fileURL: URL, configuration: ModelConfiguration, localStorageOptions: Int) {

        fatalError()
    }

    @objc
    public convenience init(fileName: String, configuration: ModelConfiguration, localStorageOptions: Int) {

        fatalError()
    }

    @objc
    public convenience override init() {

        fatalError()
    }
    
    
    // MAKR: CSLocalStorage

    @objc
    public var fileURL: URL {

        fatalError()
    }

    @objc
    public var migrationMappingProviders: [Any] {

        fatalError()
    }

    @objc
    public var localStorageOptions: Int {

        fatalError()
    }
    
    
    // MARK: CSStorageInterface

    @objc
    public static let storeType = NSSQLiteStoreType

    public var configuration: ModelConfiguration {

        fatalError()
    }

    @objc
    public var storeOptions: [AnyHashable: Any]? {

        fatalError()
    }

    @objc
    public func cs_eraseStorageAndWait(metadata: NSDictionary, soureModelHint: NSManagedObjectModel?, error: NSErrorPointer) -> Bool {

        fatalError()
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {

        fatalError()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {

        fatalError()
    }
    
    public override var description: String {

        fatalError()
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: SQLiteStore
    
    public required init(_ swiftValue: SQLiteStore) {

        fatalError()
    }
}


// MARK: - SQLiteStore

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
extension SQLiteStore: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSSQLiteStore {

        fatalError()
    }
}
