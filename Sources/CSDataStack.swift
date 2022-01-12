//
//  CSDataStack.swift
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


// MARK: - CSDataStack

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
@objc
public final class CSDataStack: NSObject, CoreStoreObjectiveCType {

    @objc
    public convenience override init() {
        
        fatalError()
    }

    @objc
    public convenience init(xcodeModelName: XcodeDataModelFileName?, bundle: Bundle?, versionChain: [String]?) {

        fatalError()
    }

    @objc
    public var modelVersion: String {

        fatalError()
    }

    @objc
    public func entityTypesByNameForType(_ type: NSManagedObject.Type) -> [EntityName: NSManagedObject.Type] {

        fatalError()
    }

    @objc
    public func entityDescriptionForClass(_ type: NSManagedObject.Type) -> NSEntityDescription? {

        fatalError()
    }

    @objc
    @discardableResult
    public func addInMemoryStorageAndWaitAndReturnError(_ error: NSErrorPointer) -> CSInMemoryStore? {

        fatalError()
    }

    @objc
    @discardableResult
    public func addSQLiteStorageAndWaitAndReturnError(_ error: NSErrorPointer) -> CSSQLiteStore? {

        fatalError()
    }

    @objc
    @discardableResult
    public func addInMemoryStorageAndWait(_ storage: CSInMemoryStore, error: NSErrorPointer) -> CSInMemoryStore? {

        fatalError()
    }

    @objc
    @discardableResult
    public func addSQLiteStorageAndWait(_ storage: CSSQLiteStore, error: NSErrorPointer) -> CSSQLiteStore? {

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
    
    public let bridgeToSwift: DataStack
    
    public init(_ swiftValue: DataStack) {

        fatalError()
    }
}


// MARK: - DataStack

@available(*, unavailable, message: "CoreStore Objective-C is now obsoleted in preparation for Swift concurrency.")
extension DataStack: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSDataStack {

        fatalError()
    }
}
