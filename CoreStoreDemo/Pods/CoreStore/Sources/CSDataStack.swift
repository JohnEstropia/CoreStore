//
//  CSDataStack.swift
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

import Foundation
import CoreData


// MARK: - CSDataStack

/**
 The `CSDataStack` serves as the Objective-C bridging type for `DataStack`.
 
 - SeeAlso: `DataStack`
 */
@objc
public final class CSDataStack: NSObject, CoreStoreObjectiveCType {
    
    /**
     Initializes a `CSDataStack` with default settings. CoreStore searches for <CFBundleName>.xcdatamodeld from the main `NSBundle` and loads an `NSManagedObjectModel` from it. An assertion is raised if the model could not be found.
     */
    @objc
    public convenience override init() {
        
        self.init(DataStack())
    }
    
    /**
     Initializes a `CSDataStack` from the model with the specified `modelName` in the specified `bundle`.
     
     - parameter xcodeModelName: the name of the (.xcdatamodeld) model file. If not specified, the application name (CFBundleName) will be used if it exists, or "CoreData" if it the bundle name was not set.
     - parameter bundle: an optional bundle to load models from. If not specified, the main bundle will be used.
     - parameter versionChain: the version strings that indicate the sequence of model versions to be used as the order for progressive migrations. If not specified, will default to a non-migrating data stack.
     */
    @objc
    public convenience init(xcodeModelName: XcodeDataModelFileName?, bundle: Bundle?, versionChain: [String]?) {
        
        self.init(
            DataStack(
                xcodeModelName: xcodeModelName ?? DataStack.applicationName,
                bundle: bundle ?? Bundle.main,
                migrationChain: versionChain.flatMap { MigrationChain($0) } ?? nil
            )
        )
    }
    
    /**
     Returns the stack's model version. The version string is the same as the name of the version-specific .xcdatamodeld file.
     */
    @objc
    public var modelVersion: String {
        
        return self.bridgeToSwift.modelVersion
    }
    
    /**
     Returns the entity name-to-class type mapping from the `CSDataStack`'s model.
     */
    @objc
    public func entityTypesByNameForType(_ type: NSManagedObject.Type) -> [EntityName: NSManagedObject.Type] {
        
        return self.bridgeToSwift.entityTypesByName(for: type)
    }
    
    /**
     Returns the `NSEntityDescription` for the specified `NSManagedObject` subclass from stack's model.
     */
    @objc
    public func entityDescriptionForClass(_ type: NSManagedObject.Type) -> NSEntityDescription? {
        
        return self.bridgeToSwift.entityDescription(for: type)
    }
    
    /**
     Creates an `CSInMemoryStore` with default parameters and adds it to the stack. This method blocks until completion.
     ```
     CSSQLiteStore *storage = [dataStack addInMemoryStorageAndWaitAndReturnError:&error];
     ```
     - parameter error: the `NSError` pointer that indicates the reason in case of an failure
     - returns: the `CSInMemoryStore` added to the stack
     */
    @objc
    @discardableResult
    public func addInMemoryStorageAndWaitAndReturnError(_ error: NSErrorPointer) -> CSInMemoryStore? {
        
        return bridge(error) {
            
            try self.bridgeToSwift.addStorageAndWait(InMemoryStore())
        }
    }
    
    /**
     Creates an `CSSQLiteStore` with default parameters and adds it to the stack. This method blocks until completion.
     ```
     CSSQLiteStore *storage = [dataStack addSQLiteStorageAndWaitAndReturnError:&error];
     ```
     - parameter error: the `NSError` pointer that indicates the reason in case of an failure
     - returns: the `CSSQLiteStore` added to the stack
     */
    @objc
    @discardableResult
    public func addSQLiteStorageAndWaitAndReturnError(_ error: NSErrorPointer) -> CSSQLiteStore? {
        
        return bridge(error) {
            
            try self.bridgeToSwift.addStorageAndWait(SQLiteStore())
        }
    }
    
    /**
     Adds a `CSInMemoryStore` to the stack and blocks until completion.
     ```
     NSError *error;
     CSInMemoryStore *storage = [dataStack
         addStorageAndWait: [[CSInMemoryStore alloc] initWithConfiguration: @"Config1"]
         error: &error];
     ```
     - parameter storage: the `CSInMemoryStore`
     - parameter error: the `NSError` pointer that indicates the reason in case of an failure
     - returns: the `CSInMemoryStore` added to the stack
     */
    @objc
    @discardableResult
    public func addInMemoryStorageAndWait(_ storage: CSInMemoryStore, error: NSErrorPointer) -> CSInMemoryStore? {
        
        return bridge(error) {
            
            try self.bridgeToSwift.addStorageAndWait(storage.bridgeToSwift)
        }
    }
    
    /**
     Adds a `CSSQLiteStore` to the stack and blocks until completion.
     ```
     NSError *error;
     CSSQLiteStore *storage = [dataStack
         addStorageAndWait: [[CSSQLiteStore alloc] initWithConfiguration: @"Config1"]
         error: &error];
     ```
     - parameter storage: the `CSSQLiteStore`
     - parameter error: the `NSError` pointer that indicates the reason in case of an failure
     - returns: the `CSSQLiteStore` added to the stack
     */
    @objc
    @discardableResult
    public func addSQLiteStorageAndWait(_ storage: CSSQLiteStore, error: NSErrorPointer) -> CSSQLiteStore? {
        
        return bridge(error) {
            
            try self.bridgeToSwift.addStorageAndWait(storage.bridgeToSwift)
        }
    }

    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return ObjectIdentifier(self.bridgeToSwift).hashValue
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        guard let object = object as? CSDataStack else {
            
            return false
        }
        return self.bridgeToSwift == object.bridgeToSwift
    }
    
    public override var description: String {
        
        return "(\(String(reflecting: type(of: self)))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: DataStack
    
    public init(_ swiftValue: DataStack) {
        
        self.bridgeToSwift = swiftValue
        super.init()
    }
    
    
    // MARK: Deprecated
    
    @available(*, deprecated, message: "Use the -[initWithXcodeModelName:bundle:versionChain:] initializer.")
    @objc
    public convenience init(modelName: XcodeDataModelFileName?, bundle: Bundle?, versionChain: [String]?) {
        
        self.init(
            DataStack(
                xcodeModelName: modelName ?? DataStack.applicationName,
                bundle: bundle ?? Bundle.main,
                migrationChain: versionChain.flatMap { MigrationChain($0) } ?? nil
            )
        )
    }
    
    @available(*, deprecated, message: "Use the -[initWithModelName:bundle:versionChain:] initializer.")
    @objc
    public convenience init(model: NSManagedObjectModel, versionChain: [String]?) {
        
        self.init(
            DataStack(
                model: model,
                migrationChain: versionChain.flatMap { MigrationChain($0) } ?? nil
            )
        )
    }
    
    @available(*, deprecated, message: "Use the -[initWithModelName:bundle:versionTree:] initializer.")
    @objc
    public convenience init(model: NSManagedObjectModel, versionTree: [String]?) {
        
        self.init(
            DataStack(
                model: model,
                migrationChain: versionTree.flatMap { MigrationChain($0) } ?? nil
            )
        )
    }
    
    @available(*, deprecated, message: "Use the new -entityTypesByNameForType: method passing `[NSManagedObject class]` as argument.")
    @objc
    public var entityClassesByName: [EntityName: NSManagedObject.Type] {
        
        return self.bridgeToSwift.entityTypesByName
    }
    
    @available(*, deprecated, message: "Use the new -entityTypesByNameForType: method passing `[NSManagedObject class]` as argument.")
    @objc
    public func entityClassWithName(_ name: EntityName) -> NSManagedObject.Type? {
        
        return self.bridgeToSwift.entityTypesByName[name]
    }
}


// MARK: - DataStack

extension DataStack: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSDataStack {
        
        return CSDataStack(self)
    }
}
