//
//  CSInMemoryStore.swift
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


// MARK: - InMemoryStore

extension InMemoryStore: CoreStoreBridgeable {
    
    // MARK: CoreStoreBridgeable
    
    public typealias ObjCType = CSInMemoryStore
}


// MARK: - CSInMemoryStore

/**
 The `CSInMemoryStore` serves as the Objective-C bridging type for `InMemoryStore`.
 */
@objc
public final class CSInMemoryStore: NSObject, CoreStoreBridge {
    
    /**
     Initializes a `CSInMemoryStore` for the specified configuration
     
     - parameter configuration: an optional configuration name from the model file. If not specified, defaults to `nil`, the "Default" configuration.
     */
    @objc
    public convenience init(configuration: String?) {
        
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
    public var configuration: String? {
        
        return self.swift.configuration
    }
    
    /**
     The options dictionary for the `NSPersistentStore`. For `CSInMemoryStore`s, this is always set to `nil`.
     */
    @objc
    public var storeOptions: [String: AnyObject]? {
        
        return self.swift.storeOptions
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return ObjectIdentifier(self.swift).hashValue
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        
        guard let object = object as? CSInMemoryStore else {
            
            return false
        }
        return self.swift === object.swift
    }
    
    
    // MARK: CoreStoreBridge
    
    public let swift: InMemoryStore
    
    public required init(_ swiftObject: InMemoryStore) {
        
        self.swift = swiftObject
    }
}
