//
//  CSInMemoryStore.swift
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


// MARK: - CSInMemoryStore

/**
 The `CSInMemoryStore` serves as the Objective-C bridging type for `InMemoryStore`.
 
 - SeeAlso: `InMemoryStore`
 */
@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
@objc
public final class CSInMemoryStore: NSObject, CSStorageInterface, CoreStoreObjectiveCType {
    
    /**
     Initializes a `CSInMemoryStore` for the specified configuration
     
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration.
     */
    @objc
    public convenience init(configuration: ModelConfiguration) {
        
        self.init(InMemoryStore(configuration: configuration))
    }
    
    /**
     Initializes a `CSInMemoryStore` with the "Default" configuration
     */
    @objc
    public convenience override init() {
        
        self.init(InMemoryStore())
    }
    
    
    // MARK: StorageInterface
    
    /**
     The string identifier for the `NSPersistentStore`'s `type` property. For `CSInMemoryStore`s, this is always set to `NSInMemoryStoreType`.
     */
    @objc
    public static let storeType = NSInMemoryStoreType
    
    /**
     The configuration name in the model file
     */
    @objc
    public var configuration: ModelConfiguration {
        
        return self.bridgeToSwift.configuration
    }
    
    /**
     The options dictionary for the `NSPersistentStore`. For `CSInMemoryStore`s, this is always set to `nil`.
     */
    @objc
    public var storeOptions: [AnyHashable: Any]? {
        
        return self.bridgeToSwift.storeOptions
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return ObjectIdentifier(self.bridgeToSwift).hashValue
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        guard let object = object as? CSInMemoryStore else {
            
            return false
        }
        return self.bridgeToSwift === object.bridgeToSwift
    }
    
    public override var description: String {
        
        return "(\(String(reflecting: Self.self))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: InMemoryStore
    
    public required init(_ swiftValue: InMemoryStore) {
        
        self.bridgeToSwift = swiftValue
        super.init()
    }
}


// MARK: - InMemoryStore

@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
extension InMemoryStore: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSInMemoryStore {
        
        return CSInMemoryStore(self)
    }
}
