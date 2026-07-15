//
//  DynamicObject.swift
//  CoreStore
//
//  Copyright © 2026 John Rommel Estropia
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


// MARK: - DynamicObjectID

public struct DynamicObjectID<O: DynamicObject>: Hashable, ObjectRepresentation, Sendable {

    /**
     The associated `NSManagedObject` or `CoreStoreObject` entity class
     */
    public let entityClass: O.Type
    
    public init(
        managedObjectID: NSManagedObjectID
    ) {
        
        self.init(
            entityClass: O.self,
            managedObjectID: managedObjectID
        )
    }
    
    public init(
        entityClass: O.Type,
        managedObjectID: NSManagedObjectID
    ) {

        Internals.assert(
            Internals.EntityIdentifier(entityClass) == Internals.EntityIdentifier(managedObjectID.entity),
            "The \(Internals.typeName(managedObjectID)) does not belong to the entity \(Internals.typeName(entityClass))."
        )
        
        self.entityClass = entityClass
        self.managedObjectID = managedObjectID
    }
    
    
    // MARK: Equatable
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        
        return lhs.managedObjectID == rhs.managedObjectID
    }
    
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher) {
        
        hasher.combine(self.managedObjectID)
    }
    
    
    // MARK: AnyObjectRepresentation
    
    @_spi(Internals)
    public func cs_dataStack() -> DataStack? {
        
        return nil
    }
    
    @_spi(Internals)
    public func cs_id() -> NSManagedObjectID {
        
        return self.managedObjectID
    }
    
    
    // MARK: ObjectRepresentation
    
    public typealias ObjectType = O
    
    public func asPublisher(in dataStack: DataStack) -> ObjectPublisher<ObjectType> {
        
        let context = dataStack.unsafeContext()
        return context.objectPublisher(managedObjectID: self.managedObjectID)
    }
    
    public func asReadOnly(in dataStack: DataStack) -> ObjectType? {
        
        let context = dataStack.unsafeContext()
        return context.fetchExisting(self.managedObjectID)
    }
    
    public func asEditable(in transaction: BaseDataTransaction) -> ObjectType? {
        
        let context = transaction.unsafeContext()
        return context.fetchExisting(self.managedObjectID)
    }
    
    public func asSnapshot(in dataStack: DataStack) -> ObjectSnapshot<ObjectType>? {
        
        let context = dataStack.unsafeContext()
        return ObjectSnapshot<ObjectType>(managedObjectID: self.managedObjectID, context: context)
    }
    
    public func asSnapshot(in transaction: BaseDataTransaction) -> ObjectSnapshot<ObjectType>? {
        
        let context = transaction.unsafeContext()
        return ObjectSnapshot<ObjectType>(managedObjectID: self.managedObjectID, context: context)
    }
    
    
    // MARK: Internal
    
    internal let managedObjectID: NSManagedObjectID
    
    internal var entityIdentifier: Internals.EntityIdentifier {
        
        return Internals.EntityIdentifier(self.managedObjectID.entity)
    }
}
