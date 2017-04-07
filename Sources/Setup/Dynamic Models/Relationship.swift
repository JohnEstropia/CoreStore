//
//  Relationship.swift
//  CoreStore
//
//  Copyright © 2017 John Rommel Estropia
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
import Foundation


// MARK: Operators

infix operator .= : AssignmentPrecedence


// MARK: - DynamicObject

public extension DynamicObject where Self: CoreStoreObject {
    
    public typealias Relationship = RelationshipContainer<Self>
}


// MARK: - RelationshipContainer

public enum RelationshipContainer<O: CoreStoreObject> {
    
    // MARK: - ToOne
    
    public final class ToOne<D: CoreStoreObject>: RelationshipProtocol {
        
        // MARK: -
        
        public static func .= (_ relationship: RelationshipContainer<O>.ToOne<D>, _ value: D?) {
            
            relationship.value = value
        }
        
        public static func .=<O2: CoreStoreObject> (_ relationship: RelationshipContainer<O>.ToOne<D>, _ relationship2: RelationshipContainer<O2>.ToOne<D>) {
            
            relationship.value = relationship2.value
        }
        
        public convenience init(_ keyPath: KeyPath, deleteRule: DeleteRule = .nullify) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { nil }, deleteRule: deleteRule)
        }
        
        public convenience init(_ keyPath: KeyPath, inverse: @escaping (D) -> RelationshipContainer<D>.ToOne<O>, deleteRule: DeleteRule = .nullify) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { inverse(D.meta).keyPath }, deleteRule: deleteRule)
        }
        
        public convenience init(_ keyPath: KeyPath, inverse: @escaping (D) -> RelationshipContainer<D>.ToManyOrdered<O>, deleteRule: DeleteRule = .nullify) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { inverse(D.meta).keyPath }, deleteRule: deleteRule)
        }
        
        public convenience init(_ keyPath: KeyPath, inverse: @escaping (D) -> RelationshipContainer<D>.ToManyUnordered<O>, deleteRule: DeleteRule = .nullify) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { inverse(D.meta).keyPath }, deleteRule: deleteRule)
        }
        
        public var value: D? {
            
            get {
                
                return self.accessRawObject()
                    .getValue(
                        forKvcKey: self.keyPath,
                        didGetValue: { $0.flatMap({ D.cs_fromRaw(object: $0 as! NSManagedObject) }) }
                    )
            }
            set {
                
                self.accessRawObject()
                    .setValue(
                        newValue,
                        forKvcKey: self.keyPath,
                        willSetValue: { $0?.rawObject }
                    )
            }
        }
        
        
        // MARK: RelationshipProtocol
        
        public let keyPath: KeyPath
        
        internal let isToMany = false
        internal let isOrdered = false
        internal let deleteRule: NSDeleteRule
        internal let inverse: (type: CoreStoreObject.Type, keyPath: () -> KeyPath?)
        
        internal var accessRawObject: () -> NSManagedObject = {
            
            CoreStore.abort("Attempted to access values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types.")
        }
        
        
        // MARK: Private
        
        private init(keyPath: KeyPath, inverseKeyPath: @escaping () -> KeyPath?, deleteRule: DeleteRule) {
            
            self.keyPath = keyPath
            self.deleteRule = deleteRule.nativeValue
            self.inverse = (D.self, inverseKeyPath)
        }
    }
    
    
    // MARK: - ToManyOrdered
    
    public final class ToManyOrdered<D: CoreStoreObject>: RelationshipProtocol {
        
        // MARK: -
        
        public static func .= (_ relationship: RelationshipContainer<O>.ToManyOrdered<D>, _ value: [D]) {
            
            relationship.value = value
        }
        
        public static func .=<C: Collection> (_ relationship: RelationshipContainer<O>.ToManyOrdered<D>, _ value: C) where C.Iterator.Element == D {
            
            relationship.value = Array(value)
        }
        
        public static func .=<O2: CoreStoreObject> (_ relationship: RelationshipContainer<O>.ToManyOrdered<D>, _ relationship2: RelationshipContainer<O2>.ToManyOrdered<D>) {
            
            relationship.value = relationship2.value
        }
        
        public convenience init(_ keyPath: KeyPath, deleteRule: DeleteRule = .nullify) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { nil }, deleteRule: deleteRule)
        }
        
        public convenience init(_ keyPath: KeyPath, inverse: @escaping (D) -> RelationshipContainer<D>.ToOne<O>, deleteRule: DeleteRule = .nullify) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { inverse(D.meta).keyPath }, deleteRule: deleteRule)
        }
        
        public convenience init(_ keyPath: KeyPath, inverse: @escaping (D) -> RelationshipContainer<D>.ToManyOrdered<O>, deleteRule: DeleteRule = .nullify) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { inverse(D.meta).keyPath }, deleteRule: deleteRule)
        }
        
        public convenience init(_ keyPath: KeyPath, inverse: @escaping (D) -> RelationshipContainer<D>.ToManyUnordered<O>, deleteRule: DeleteRule = .nullify) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { inverse(D.meta).keyPath }, deleteRule: deleteRule)
        }
        
        // TODO: add subscripts, indexed operations for more performant single updates
        
        public var value: [D] {
            
            get {
                
                return self.accessRawObject()
                    .getValue(
                        forKvcKey: self.keyPath,
                        didGetValue: {
                            
                            guard let orderedSet = $0 as! NSOrderedSet? else {
                                
                                return []
                            }
                            return orderedSet.map({ D.cs_fromRaw(object: $0 as! NSManagedObject) })
                        }
                    )
            }
            set {
                
                self.accessRawObject()
                    .setValue(
                        newValue,
                        forKvcKey: self.keyPath,
                        willSetValue: { NSOrderedSet(array: $0.map({ $0.rawObject! })) }
                    )
            }
        }
        
        
        // MARK: RelationshipProtocol
        
        public let keyPath: KeyPath
        
        internal let isToMany = true
        internal let isOptional = true
        internal let isOrdered = true
        internal let deleteRule: NSDeleteRule
        internal let inverse: (type: CoreStoreObject.Type, keyPath: () -> KeyPath?)
        
        internal var accessRawObject: () -> NSManagedObject = {
            
            CoreStore.abort("Attempted to access values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types.")
        }
        
        
        // MARK: Private
        
        private init(keyPath: String, inverseKeyPath: @escaping () -> String?, deleteRule: DeleteRule) {
            
            self.keyPath = keyPath
            self.deleteRule = deleteRule.nativeValue
            self.inverse = (D.self, inverseKeyPath)
        }
    }
    
    
    // MARK: - ToManyUnordered
    
    public final class ToManyUnordered<D: CoreStoreObject>: RelationshipProtocol {
        
        // MARK: -
        
        public static func .= (_ relationship: RelationshipContainer<O>.ToManyUnordered<D>, _ value: Set<D>) {
            
            relationship.value = value
        }
        
        public static func .=<C: Collection> (_ relationship: RelationshipContainer<O>.ToManyUnordered<D>, _ value: C) where C.Iterator.Element == D {
            
            relationship.value = Set(value)
        }
        
        public static func .=<O2: CoreStoreObject> (_ relationship: RelationshipContainer<O>.ToManyUnordered<D>, _ relationship2: RelationshipContainer<O2>.ToManyUnordered<D>) {
            
            relationship.value = relationship2.value
        }
        
        public static func .=<O2: CoreStoreObject> (_ relationship: RelationshipContainer<O>.ToManyUnordered<D>, _ relationship2: RelationshipContainer<O2>.ToManyOrdered<D>) {
            
            relationship.value = Set(relationship2.value)
        }
        
        public convenience init(_ keyPath: KeyPath, deleteRule: DeleteRule = .nullify) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { nil }, deleteRule: deleteRule)
        }
        
        public convenience init(_ keyPath: KeyPath, inverse: @escaping (D) -> RelationshipContainer<D>.ToOne<O>, deleteRule: DeleteRule = .nullify) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { inverse(D.meta).keyPath }, deleteRule: deleteRule)
        }
        
        public convenience init(_ keyPath: KeyPath, inverse: @escaping (D) -> RelationshipContainer<D>.ToManyOrdered<O>, deleteRule: DeleteRule = .nullify) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { inverse(D.meta).keyPath }, deleteRule: deleteRule)
        }
        
        public convenience init(_ keyPath: KeyPath, inverse: @escaping (D) -> RelationshipContainer<D>.ToManyUnordered<O>, deleteRule: DeleteRule = .nullify) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { inverse(D.meta).keyPath }, deleteRule: deleteRule)
        }
        
        // TODO: add subscripts, indexed operations for more performant single updates
        
        public var value: Set<D> {
            
            get {
                
                return self.accessRawObject()
                    .getValue(
                        forKvcKey: self.keyPath,
                        didGetValue: {
                            
                            guard let set = $0 as! NSSet? else {
                                
                                return []
                            }
                            return Set(set.map({ D.cs_fromRaw(object: $0 as! NSManagedObject) }))
                        }
                    )
            }
            set {
                
                self.accessRawObject()
                    .setValue(
                        newValue,
                        forKvcKey: self.keyPath,
                        willSetValue: { NSSet(array: $0.map({ $0.rawObject! })) }
                    )
            }
        }
        
        
        // MARK: RelationshipProtocol
        
        public let keyPath: KeyPath
        
        internal let isToMany = true
        internal let isOptional = true
        internal let isOrdered = true
        internal let deleteRule: NSDeleteRule
        internal let inverse: (type: CoreStoreObject.Type, keyPath: () -> KeyPath?)
        
        internal var accessRawObject: () -> NSManagedObject = {
            
            CoreStore.abort("Attempted to access values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types.")
        }
        
        
        // MARK: Private
        
        private init(keyPath: KeyPath, inverseKeyPath: @escaping () -> KeyPath?, deleteRule: DeleteRule) {
            
            self.keyPath = keyPath
            self.deleteRule = deleteRule.nativeValue
            self.inverse = (D.self, inverseKeyPath)
        }
    }
    
    
    // MARK: - DeleteRule
    
    public enum DeleteRule {
        
        case nullify
        case cascade
        case deny
        
        fileprivate var nativeValue: NSDeleteRule {
            
            switch self {
                
            case .nullify:  return .nullifyDeleteRule
            case .cascade:  return .cascadeDeleteRule
            case .deny:     return .denyDeleteRule
            }
        }
    }
}


// MARK: - RelationshipProtocol

internal protocol RelationshipProtocol: class {
    
    var keyPath: KeyPath { get }
    var isToMany: Bool { get }
    var isOrdered: Bool { get }
    var deleteRule: NSDeleteRule { get }
    var inverse: (type: CoreStoreObject.Type, keyPath: () -> KeyPath?) { get }
    var accessRawObject: () -> NSManagedObject { get set }
}
