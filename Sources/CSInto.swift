//
//  CSInto.swift
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


// MARK: - CSInto

/**
 The `CSInto` serves as the Objective-C bridging type for `Into<T>`.
 
 - SeeAlso: `Into`
 */
@objc
public final class CSInto: NSObject {
    
    /**
     The associated `NSManagedObject` entity class
     */
    @objc
    public var entityClass: NSManagedObject.Type {
        
        return self.bridgeToSwift.entityClass
    }
    
    /**
     The `NSPersistentStore` configuration name to associate objects from.
     May contain a `String` to pertain to a named configuration, or `nil` to pertain to the default configuration
     */
    @objc
    public var configuration: ModelConfiguration {
        
        return self.bridgeToSwift.configuration
    }
    
    /**
     Initializes a `CSInto` clause with the specified entity class.
     ```
     MyPersonEntity *person = [transaction createInto:
        CSIntoClass([MyPersonEntity class])];
     ```
     - parameter entityClass: the `NSManagedObject` class type to be created
     */
    @objc
    public convenience init(entityClass: NSManagedObject.Type) {
        
        self.init(Into(entityClass))
    }
    
    /**
     Initializes a `CSInto` clause with the specified configuration.
     ```
     MyPersonEntity *person = [transaction createInto:
        CSIntoClass([MyPersonEntity class])];
     ```
     - parameter entityClass: the `NSManagedObject` class type to be created
     - parameter configuration: the `NSPersistentStore` configuration name to associate the object to. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
     */
    @objc
    public convenience init(entityClass: NSManagedObject.Type, configuration: ModelConfiguration) {
        
        self.init(Into(entityClass, configuration))
    }
    

    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.bridgeToSwift.hashValue
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        guard let object = object as? CSInto else {
            
            return false
        }
        return self.bridgeToSwift == object.bridgeToSwift
    }
    
    public override var description: String {
        
        return "(\(String(reflecting: Self.self))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: Into<NSManagedObject>
    
    public required init<O: NSManagedObject>(_ swiftValue: Into<O>) {
        
        self.bridgeToSwift = swiftValue.downcast()
        super.init()
    }
}


// MARK: - Into

extension Into where O: NSManagedObject {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSInto {
        
        return CSInto(self)
    }
    
    
    // MARK: FilePrivate
    
    fileprivate func downcast() -> Into<NSManagedObject> {
        
        return Into<NSManagedObject>(
            entityClass: self.entityClass,
            configuration: self.configuration,
            inferStoreIfPossible: self.inferStoreIfPossible
        )
    }
}
