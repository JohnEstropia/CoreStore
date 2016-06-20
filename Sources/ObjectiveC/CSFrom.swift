//
//  CSFrom.swift
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


// MARK: - CSFrom

/**
 The `CSFrom` serves as the Objective-C bridging type for `From`.
 
 - SeeAlso: `From`
 */
@objc
public final class CSFrom: NSObject, CoreStoreObjectiveCType {
    
    /**
     The associated `NSManagedObject` entity class
     */
    @objc
    public var entityClass: AnyClass {
        
        return self.bridgeToSwift.entityClass
    }
    
    /**
     The `NSPersistentStore` configuration names to associate objects from.
     May contain `NSString` instances to pertain to named configurations, or `NSNull` to pertain to the default configuration
     */
    @objc
    public var configurations: [AnyObject]? {
        
        return self.bridgeToSwift.configurations?.map {
            
            switch $0 {
                
            case nil: return NSNull()
            case let string as NSString: return string
            }
        }
    }
    
    /**
     Initializes a `CSFrom` clause with the specified entity class.
     ```
     MyPersonEntity *people = [transaction fetchAllFrom:CSFromClass([MyPersonEntity class])];
     ```
     
     - parameter entityClass: the `NSManagedObject` class type to be created
     */
    @objc
    public convenience init(entityClass: AnyClass) {
        
        self.init(From(entityClass))
    }
    
    /**
     Initializes a `CSFrom` clause with the specified configurations.
     ```
     MyPersonEntity *people = [transaction fetchAllFrom:
        CSFromClass([MyPersonEntity class], @"Config1")];
     ```
     
     - parameter configuration: the `NSPersistentStore` configuration name to associate objects from. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `[NSNull null]` to use the default configuration.
     */
    @objc
    public convenience init(entityClass: AnyClass, configuration: AnyObject) {
        
        switch configuration {
            
        case let string as String:
            self.init(From(entityClass, string))
            
        case is NSNull:
            self.init(From(entityClass, nil))
            
        default:
            CoreStore.abort("The configuration argument only accepts NSString and NSNull values")
        }
    }
    
    /**
     Initializes a `CSFrom` clause with the specified configurations.
     ```
     MyPersonEntity *people = [transaction fetchAllFrom:
        CSFromClass([MyPersonEntity class],
                     @[[NSNull null], @"Config1"])];
     ```
     
     - parameter entity: the associated `NSManagedObject` entity class
     - parameter configurations: an array of the `NSPersistentStore` configuration names to associate objects from. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `[NSNull null]` to use the default configuration.
     */
    @objc
    public convenience init(entityClass: AnyClass, configurations: [AnyObject]) {
        
        var arguments = [String?]()
        for configuration in configurations {
            
            switch configuration {
                
            case let string as String:
                arguments.append(string)
                
            case is NSNull:
                arguments.append(nil)
                
            default:
                CoreStore.abort("The configurations argument only accepts NSString and NSNull values")
            }
        }
        self.init(From(entityClass, arguments))
    }
    
    
    // MARK: NSObject
    
    public override var description: String {
        
        return "(\(String(reflecting: self.dynamicType))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: From<NSManagedObject>
    
    public init<T: NSManagedObject>(_ swiftValue: From<T>) {
        
        self.bridgeToSwift = swiftValue.upcast()
        super.init()
    }
}


// MARK: - From

extension From: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSFrom {
        
        return CSFrom(self)
    }
}
