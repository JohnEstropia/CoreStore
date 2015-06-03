//
//  BaseDataTransaction.swift
//  CoreStore
//
//  Copyright (c) 2014 John Rommel Estropia
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
import GCDKit


// MARK: - Into

/**
A `Into` clause contains the destination entity and destination persistent store for a `create(...)` method. A common usage is to just indicate the entity:

    let person = transaction.create(Into(MyPersonEntity))

For cases where multiple `NSPersistentStore`'s contain the same entity, the destination configuration's name needs to be specified as well:

    let person = transaction.create(Into<MyPersonEntity>("Configuration1"))

This helps the `NSManagedObjectContext` to determine which
*/
public struct Into<T: NSManagedObject> {
    
    // MARK: Public
    
    internal static var defaultConfigurationName: String {
        
        return "PF_DEFAULT_CONFIGURATION_NAME"
    }
    
    /**
    Initializes an `Into` clause.
    Sample Usage:
    
        let person = transaction.create(Into<MyPersonEntity>())
    */
    public init(){
        
        self.configuration = nil
        self.inferStoreIfPossible = true
    }
    
    /**
    Initializes an `Into` clause with the specified entity type.
    Sample Usage:
    
        let person = transaction.create(Into(MyPersonEntity))
    
    :param: entity the `NSManagedObject` type to be created
    */
    public init(_ entity: T.Type) {
        
        self.configuration = nil
        self.inferStoreIfPossible = true
    }
    
    /**
    Initializes an `Into` clause with the specified configuration.
    Sample Usage:
    
        let person = transaction.create(Into<MyPersonEntity>("Configuration1"))
    
    :param: configuration the `NSPersistentStore` configuration name to associate the object to. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
    */
    public init(_ configuration: String?) {
        
        self.configuration = configuration
        self.inferStoreIfPossible = false
    }
    
    /**
    Initializes an `Into` clause with the specified entity type and configuration.
    Sample Usage:
    
        let person = transaction.create(Into(MyPersonEntity.self, "Configuration1"))
    
    :param: entity the `NSManagedObject` type to be created
    :param: configuration the `NSPersistentStore` configuration name to associate the object to. This parameter is required if multiple configurations contain the created `NSManagedObject`'s entity type. Set to `nil` to use the default configuration.
    */
    public init(_ entity: T.Type, _ configuration: String?) {
        
        self.configuration = configuration
        self.inferStoreIfPossible = false
    }
    
    
    // MARK: Internal
    
    internal let configuration: String?
    internal let inferStoreIfPossible: Bool
}


// MARK: - BaseDataTransaction

/**
The `BaseDataTransaction` is an abstract interface for `NSManagedObject` creates, updates, and deletes. All `BaseDataTransaction` subclasses manage a private `NSManagedObjectContext` which are direct children of the `NSPersistentStoreCoordinator`'s root `NSManagedObjectContext`. This means that all updates are saved first to the persistent store, and then propagated up to the read-only `NSManagedObjectContext`.
*/
public /*abstract*/ class BaseDataTransaction {
    
    // MARK: Object management
    
    /**
    Indicates if the transaction has pending changes
    */
    public var hasChanges: Bool {
        
        return self.context.hasChanges
    }
    
    /**
    Creates a new `NSManagedObject` with the specified entity type.
    
    :param: into the `Into` clause indicating the destination `NSManagedObject` entity type and the destination configuration
    :returns: a new `NSManagedObject` instance of the specified entity type.
    */
    public func create<T: NSManagedObject>(into: Into<T>) -> T {
        
        CoreStore.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to create an entity of type <\(T.self)> outside its designated queue.")
        
        let context = self.context
        let object = T.createInContext(context)
        
        if into.inferStoreIfPossible {
            
            switch context.parentStack!.persistentStoreForEntityClass(T.self, configuration: nil, inferStoreIfPossible: true) {
                
            case (.Some(let persistentStore), _):
                context.assignObject(object, toPersistentStore: persistentStore)
                
            case (.None, true):
                CoreStore.assert(false, "Attempted to create an entity of type \(typeName(object)) with ambiguous destination persistent store, but the configuration name was not specified.")
                
            default:
                CoreStore.assert(false, "Attempted to create an entity of type \(typeName(object)), but a destination persistent store containing the entity type could not be found.")
            }
        }
        else {
            
            switch context.parentStack!.persistentStoreForEntityClass(T.self, configuration: into.configuration, inferStoreIfPossible: false) {
                
            case (.Some(let persistentStore), _):
                context.assignObject(object, toPersistentStore: persistentStore)
                
            default:
                if let configuration = into.configuration {
                    
                    CoreStore.assert(false, "Attempted to create an entity of type \(typeName(object)) into the configuration \"\(configuration)\", which it doesn't belong to.")
                }
                else {
                    
                    CoreStore.assert(false, "Attempted to create an entity of type \(typeName(object)) into the default configuration, which it doesn't belong to.")
                }
            }
        }
        
        return object
    }
    
    /**
    Returns an editable proxy of a specified `NSManagedObject`.
    
    :param: object the `NSManagedObject` type to be edited
    :returns: an editable proxy for the specified `NSManagedObject`.
    */
    public func edit<T: NSManagedObject>(object: T?) -> T? {
        
        CoreStore.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to update an entity of type \(typeName(object)) outside its designated queue.")
        
        return object?.inContext(self.context)
    }
    
    /**
    Returns an editable proxy of the object with the specified `NSManagedObjectID`. 
    
    :param: into an `Into` clause specifying the entity type
    :param: objectID the `NSManagedObjectID` for the object to be edited
    :returns: an editable proxy for the specified `NSManagedObject`.
    */
    public func edit<T: NSManagedObject>(into: Into<T>, _ objectID: NSManagedObjectID) -> T? {
        
        CoreStore.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to update an entity of type <\(T.self)> outside its designated queue.")
        CoreStore.assert(into.inferStoreIfPossible || (into.configuration ?? Into.defaultConfigurationName) == objectID.persistentStore?.configurationName, "Attempted to update an entity of type <\(T.self)> but the specified persistent store do not match the `NSManagedObjectID`.")
        
        return T.inContext(self.context, withObjectID: objectID)
    }
    
    /**
    Deletes a specified `NSManagedObject`.
    
    :param: object the `NSManagedObject` type to be deleted
    */
    public func delete(object: NSManagedObject?) {
        
        CoreStore.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to delete an entity outside its designated queue.")
        
        object?.inContext(self.context)?.deleteFromContext()
    }
    
    /**
    Deletes the specified `NSManagedObject`'s.
    
    :param: object1 the `NSManagedObject` type to be deleted
    :param: object2 another `NSManagedObject` type to be deleted
    :param: objects other `NSManagedObject`s type to be deleted
    */
    public func delete(object1: NSManagedObject?, _ object2: NSManagedObject?, _ objects: NSManagedObject?...) {
        
        self.delete([object1, object2] + objects)
    }
    
    /**
    Deletes the specified `NSManagedObject`'s.
    
    :param: objects the `NSManagedObject`'s type to be deleted
    */
    public func delete(objects: [NSManagedObject?]) {
        
        CoreStore.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to delete entities outside their designated queue.")
        
        let context = self.context
        for object in objects {
            
            object?.inContext(context)?.deleteFromContext()
        }
    }
    
    // MARK: Saving changes
    
    /**
    Rolls back the transaction by resetting the `NSManagedObjectContext`. After calling this method, all `NSManagedObjects` fetched within the transaction will become invalid.
    */
    public func rollback() {
        
        CoreStore.assert(self.transactionQueue.isCurrentExecutionContext(), "Attempted to rollback a \(typeName(self)) outside its designated queue.")
        
        self.context.reset()
    }
    
    
    // MARK: Internal
    
    internal let context: NSManagedObjectContext
    internal let transactionQueue: GCDQueue
    internal let childTransactionQueue: GCDQueue = .createSerial("com.corestore.datastack.childtransactionqueue")
    
    internal var isCommitted = false
    internal var result: SaveResult?
    
    internal init(mainContext: NSManagedObjectContext, queue: GCDQueue) {
        
        self.transactionQueue = queue
        
        let context = mainContext.temporaryContextInTransactionWithConcurrencyType(
            queue == .Main
                ? .MainQueueConcurrencyType
                : .PrivateQueueConcurrencyType
        )
        self.context = context
        
        context.parentTransaction = self
    }
}
