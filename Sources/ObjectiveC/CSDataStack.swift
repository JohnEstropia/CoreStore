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


// MARK: - DataStack

extension DataStack: CoreStoreBridgeable {
    
    // MARK: CoreStoreBridgeable
    
    public typealias NativeType = CSDataStack
}


// MARK: - CSDataStack

/**
 The `CSDataStack` serves as the Objective-C bridging type for `DataStack`.
 */
@objc
public final class CSDataStack: NSObject, CoreStoreBridge {
    
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
    public convenience init(modelName: String = DataStack.applicationName, bundle: NSBundle = NSBundle.mainBundle(), versionChain: [String]? = nil) {
        
        self.init(
            DataStack(
                modelName: modelName,
                bundle: bundle,
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
    public convenience init(modelName: String = DataStack.applicationName, bundle: NSBundle = NSBundle.mainBundle(), versionTree: [String: String]? = nil) {
        
        self.init(
            DataStack(
                modelName: modelName,
                bundle: bundle,
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
    public convenience init(model: NSManagedObjectModel, versionChain: [String]? = nil) {
        
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
    public convenience init(model: NSManagedObjectModel, versionTree: [String]? = nil) {
        
        self.init(
            DataStack(
                model: model,
                migrationChain: versionTree.flatMap { MigrationChain($0) } ?? nil
            )
        )
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return ObjectIdentifier(self.swift).hashValue
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        
        guard let object = object as? CSDataStack else {
            
            return false
        }
        return self.swift === object.swift
    }
    
    
    // MARK: CoreStoreBridge
    
    public let swift: DataStack
    
    public required init(_ swiftObject: DataStack) {
        
        self.swift = swiftObject
    }
}
