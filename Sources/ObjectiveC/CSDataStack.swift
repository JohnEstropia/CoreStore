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
     
     - parameter modelName: the name of the (.xcdatamodeld) model file. If not specified, the application name (CFBundleName) will be used if it exists, or "CoreData" if it the bundle name was not set.
     - parameter bundle: an optional bundle to load models from. If not specified, the main bundle will be used.
     - parameter versionChain: the version strings that indicate the sequence of model versions to be used as the order for progressive migrations. If not specified, will default to a non-migrating data stack.
     */
    @objc
    public convenience init(modelName: String?, bundle: NSBundle?, versionChain: [String]?) {
        
        self.init(
            DataStack(
                modelName: modelName ?? DataStack.applicationName,
                bundle: bundle ?? NSBundle.mainBundle(),
                migrationChain: versionChain.flatMap { MigrationChain($0) } ?? nil
            )
        )
    }
    
    /**
     Initializes a `CSDataStack` from the model with the specified `modelName` in the specified `bundle`.
     
     - parameter modelName: the name of the (.xcdatamodeld) model file. If not specified, the application name (CFBundleName) will be used if it exists, or "CoreData" if it the bundle name was not set.
     - parameter bundle: an optional bundle to load models from. If not specified, the main bundle will be used.
     - parameter versionTree: the version strings that indicate the sequence of model versions to be used as the order for progressive migrations. If not specified, will default to a non-migrating data stack.
     */
    @objc
    public convenience init(modelName: String?, bundle: NSBundle?, versionTree: [String: String]?) {
        
        self.init(
            DataStack(
                modelName: modelName ?? DataStack.applicationName,
                bundle: bundle ?? NSBundle.mainBundle(),
                migrationChain: versionTree.flatMap { MigrationChain($0) } ?? nil
            )
        )
    }
    
    /**
     Initializes a `DataStack` from an `NSManagedObjectModel`.
     
     - parameter model: the `NSManagedObjectModel` for the stack
     - parameter versionChain: the `MigrationChain` that indicates the sequence of model versions to be used as the order for progressive migrations. If not specified, will default to a non-migrating data stack.
     */
    @objc
    public convenience init(model: NSManagedObjectModel, versionChain: [String]?) {
        
        self.init(
            DataStack(
                model: model,
                migrationChain: versionChain.flatMap { MigrationChain($0) } ?? nil
            )
        )
    }
    
    /**
     Initializes a `DataStack` from an `NSManagedObjectModel`.
     
     - parameter model: the `NSManagedObjectModel` for the stack
     - parameter versionTree: the `MigrationChain` that indicates the sequence of model versions to be used as the order for progressive migrations. If not specified, will default to a non-migrating data stack.
     */
    @objc
    public convenience init(model: NSManagedObjectModel, versionTree: [String]?) {
        
        self.init(
            DataStack(
                model: model,
                migrationChain: versionTree.flatMap { MigrationChain($0) } ?? nil
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
     Returns the entity name-to-class type mapping from the stack's model.
     */
    @objc
    public var entityClassesByName: [String: NSManagedObject.Type] {
        
        return self.bridgeToSwift.entityTypesByName
    }
    
    /**
     Returns the entity class for the given entity name from the stack's's model.
     - parameter name: the entity name
     - returns: the `NSManagedObject` class for the given entity name, or `nil` if not found
     */
    @objc
    public func entityClassWithName(name: String) -> NSManagedObject.Type? {
        
        return self.bridgeToSwift.entityTypesByName[name]
    }
    
    /**
     Returns the `NSEntityDescription` for the specified `NSManagedObject` subclass from stack's model.
     */
    @objc
    public func entityDescriptionForClass(type: NSManagedObject.Type) -> NSEntityDescription? {
        
        return self.bridgeToSwift.entityDescriptionForType(type)
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
    public func addInMemoryStorageAndWaitAndReturnError(error: NSErrorPointer) -> CSInMemoryStore? {
        
        return bridge(error) {
            
            try self.bridgeToSwift.addStorageAndWait(InMemoryStore)
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
    public func addSQLiteStorageAndWaitAndReturnError(error: NSErrorPointer) -> CSSQLiteStore? {
        
        return bridge(error) {
            
            try self.bridgeToSwift.addStorageAndWait(SQLiteStore)
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
    public func addInMemoryStorageAndWait(storage: CSInMemoryStore, error: NSErrorPointer) -> CSInMemoryStore? {
        
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
    public func addSQLiteStorageAndWait(storage: CSSQLiteStore, error: NSErrorPointer) -> CSSQLiteStore? {
        
        return bridge(error) {
            
            try self.bridgeToSwift.addStorageAndWait(storage.bridgeToSwift)
        }
    }

    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return ObjectIdentifier(self.bridgeToSwift).hashValue
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        
        guard let object = object as? CSDataStack else {
            
            return false
        }
        return self.bridgeToSwift == object.bridgeToSwift
    }
    
    public override var description: String {
        
        return "(\(String(reflecting: self.dynamicType))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: DataStack
    
    public init(_ swiftValue: DataStack) {
        
        self.bridgeToSwift = swiftValue
        super.init()
    }
}


// MARK: - DataStack

extension DataStack: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public typealias ObjectiveCType = CSDataStack
}
