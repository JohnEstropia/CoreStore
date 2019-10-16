//
//  ObjectRepresentation.swift
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

import CoreData


// MARK - ObjectRepresentation

/**
 An object that acts as interfaces for `CoreStoreObject`s or `NSManagedObject`s
 */
public protocol ObjectRepresentation {
    
    /**
     The object type represented by this protocol
     */
    associatedtype ObjectType: DynamicObject
    
    /**
     The internal ID for the object.
     */
    func objectID() -> ObjectType.ObjectID
    
    /**
     An instance that may be observed for object changes.
     */
    func asLiveObject(in dataStack: DataStack) -> LiveObject<ObjectType>?
    
    /**
     An instance that may be mutated within a transaction.
     */
    func asEditable(in transaction: BaseDataTransaction) -> ObjectType?
    
    /**
     A thread-safe `struct` that is a full-copy of the object's properties
     */
    func asSnapshot(in dataStack: DataStack) -> ObjectSnapshot<ObjectType>?
    
    /**
     A thread-safe `struct` that is a full-copy of the object's properties
     */
    func asSnapshot(in transaction: BaseDataTransaction) -> ObjectSnapshot<ObjectType>?
    
    /**
     An instance that may be observed for property-specific changes.
     */
    func asObjectMonitor(in dataStack: DataStack) -> ObjectMonitor<ObjectType>?
}

extension NSManagedObject: ObjectRepresentation {}

extension CoreStoreObject: ObjectRepresentation {}

extension DynamicObject where Self: ObjectRepresentation {

    // MARK: ObjectRepresentation

    public func objectID() -> Self.ObjectID {

        return self.cs_id()
    }

    public func asLiveObject(in dataStack: DataStack) -> LiveObject<Self>? {

        let context = dataStack.unsafeContext()
        return .init(objectID: self.cs_id(), context: context)
    }

    public func asEditable(in transaction: BaseDataTransaction) -> Self? {

        let context = transaction.unsafeContext()
        if self.cs_toRaw().managedObjectContext == context {

            return self
        }
        return context.fetchExisting(self.cs_id())
    }

    public func asSnapshot(in dataStack: DataStack) -> ObjectSnapshot<Self>? {

        let context = dataStack.unsafeContext()
        return .init(objectID: self.cs_id(), context: context)
    }

    public func asSnapshot(in transaction: BaseDataTransaction) -> ObjectSnapshot<Self>? {

        let context = transaction.unsafeContext()
        return .init(objectID: self.cs_id(), context: context)
    }

    public func asObjectMonitor(in dataStack: DataStack) -> ObjectMonitor<Self>? {

        let context = dataStack.unsafeContext()
        return .init(objectID: self.cs_id(), context: context)
    }
}
