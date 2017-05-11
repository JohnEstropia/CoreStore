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
        
        public convenience init(_ keyPath: KeyPath, deleteRule: DeleteRule = .nullify, versionHashModifier: String? = nil, renamingIdentifier: String? = nil) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { nil }, deleteRule: deleteRule, versionHashModifier: versionHashModifier, renamingIdentifier: renamingIdentifier)
        }
        
        public convenience init(_ keyPath: KeyPath, inverse: @escaping (D) -> RelationshipContainer<D>.ToOne<O>, deleteRule: DeleteRule = .nullify, versionHashModifier: String? = nil, renamingIdentifier: String? = nil) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { inverse(D.meta).keyPath }, deleteRule: deleteRule, versionHashModifier: versionHashModifier, renamingIdentifier: renamingIdentifier)
        }
        
        public convenience init(_ keyPath: KeyPath, inverse: @escaping (D) -> RelationshipContainer<D>.ToManyOrdered<O>, deleteRule: DeleteRule = .nullify, versionHashModifier: String? = nil, renamingIdentifier: String? = nil) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { inverse(D.meta).keyPath }, deleteRule: deleteRule, versionHashModifier: versionHashModifier, renamingIdentifier: renamingIdentifier)
        }
        
        public convenience init(_ keyPath: KeyPath, inverse: @escaping (D) -> RelationshipContainer<D>.ToManyUnordered<O>, deleteRule: DeleteRule = .nullify, versionHashModifier: String? = nil, renamingIdentifier: String? = nil) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { inverse(D.meta).keyPath }, deleteRule: deleteRule, versionHashModifier: versionHashModifier, renamingIdentifier: renamingIdentifier)
        }
        
        public var value: D? {
            
            get {
                
                let object = self.parentObject() as! O
                CoreStore.assert(
                    object.rawObject!.isRunningInAllowedQueue() == true,
                    "Attempted to access \(cs_typeName(O.self))'s value outside it's designated queue."
                )
                return object.rawObject!.getValue(
                    forKvcKey: self.keyPath,
                    didGetValue: { $0.flatMap({ D.cs_fromRaw(object: $0 as! NSManagedObject) }) }
                )
            }
            set {
                
                let object = self.parentObject() as! O
                CoreStore.assert(
                    object.rawObject!.isRunningInAllowedQueue() == true,
                    "Attempted to access \(cs_typeName(O.self))'s value outside it's designated queue."
                )
                CoreStore.assert(
                    object.rawObject!.isEditableInContext() == true,
                    "Attempted to update a \(cs_typeName(O.self))'s value from outside a transaction."
                )
                object.rawObject!.setValue(
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
        internal let minCount: Int = 0
        internal let maxCount: Int = 1
        internal let inverse: (type: CoreStoreObject.Type, keyPath: () -> KeyPath?)
        internal let versionHashModifier: String?
        internal let renamingIdentifier: String?
        
        internal var parentObject: () -> CoreStoreObject = {
            
            CoreStore.abort("Attempted to access values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types.")
        }
        
        
        // MARK: Private
        
        private init(keyPath: KeyPath, inverseKeyPath: @escaping () -> KeyPath?, deleteRule: DeleteRule, versionHashModifier: String?, renamingIdentifier: String?) {
            
            self.keyPath = keyPath
            self.deleteRule = deleteRule.nativeValue
            self.inverse = (D.self, inverseKeyPath)
            self.versionHashModifier = versionHashModifier
            self.renamingIdentifier = renamingIdentifier
        }
    }
    
    
    // MARK: - ToManyOrdered
    
    public final class ToManyOrdered<D: CoreStoreObject>: RelationshipProtocol {
        
        public static func .= (_ relationship: RelationshipContainer<O>.ToManyOrdered<D>, _ value: [D]) {
            
            relationship.value = value
        }
        
        public static func .=<C: Collection> (_ relationship: RelationshipContainer<O>.ToManyOrdered<D>, _ value: C) where C.Iterator.Element == D {
            
            relationship.value = Array(value)
        }
        
        public static func .=<O2: CoreStoreObject> (_ relationship: RelationshipContainer<O>.ToManyOrdered<D>, _ relationship2: RelationshipContainer<O2>.ToManyOrdered<D>) {
            
            relationship.value = relationship2.value
        }
        
        public convenience init(_ keyPath: KeyPath, deleteRule: DeleteRule = .nullify, minCount: Int = 0, maxCount: Int = 0, versionHashModifier: String? = nil, renamingIdentifier: String? = nil) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { nil }, deleteRule: deleteRule, minCount: minCount, maxCount: maxCount, versionHashModifier: versionHashModifier, renamingIdentifier: renamingIdentifier)
        }
        
        public convenience init(_ keyPath: KeyPath, inverse: @escaping (D) -> RelationshipContainer<D>.ToOne<O>, deleteRule: DeleteRule = .nullify, minCount: Int = 0, maxCount: Int = 0, versionHashModifier: String? = nil, renamingIdentifier: String? = nil) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { inverse(D.meta).keyPath }, deleteRule: deleteRule, minCount: minCount, maxCount: maxCount, versionHashModifier: versionHashModifier, renamingIdentifier: renamingIdentifier)
        }
        
        public convenience init(_ keyPath: KeyPath, inverse: @escaping (D) -> RelationshipContainer<D>.ToManyOrdered<O>, deleteRule: DeleteRule = .nullify, minCount: Int = 0, maxCount: Int = 0, versionHashModifier: String? = nil, renamingIdentifier: String? = nil) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { inverse(D.meta).keyPath }, deleteRule: deleteRule, minCount: minCount, maxCount: maxCount, versionHashModifier: versionHashModifier, renamingIdentifier: renamingIdentifier)
        }
        
        public convenience init(_ keyPath: KeyPath, inverse: @escaping (D) -> RelationshipContainer<D>.ToManyUnordered<O>, deleteRule: DeleteRule = .nullify, minCount: Int = 0, maxCount: Int = 0, versionHashModifier: String? = nil, renamingIdentifier: String? = nil) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { inverse(D.meta).keyPath }, deleteRule: deleteRule, minCount: minCount, maxCount: maxCount, versionHashModifier: versionHashModifier, renamingIdentifier: renamingIdentifier)
        }
        
        public var value: [D] {
            
            get {
                
                return self.nativeValue.map({ D.cs_fromRaw(object: $0 as! NSManagedObject) })
            }
            set {
                
                self.nativeValue = NSOrderedSet(array: newValue.map({ $0.rawObject! }))
            }
        }
        
        
        // MARK: RelationshipProtocol
        
        public let keyPath: KeyPath
        
        internal let isToMany = true
        internal let isOptional = true
        internal let isOrdered = true
        internal let deleteRule: NSDeleteRule
        internal let minCount: Int
        internal let maxCount: Int
        internal let inverse: (type: CoreStoreObject.Type, keyPath: () -> KeyPath?)
        internal let versionHashModifier: String?
        internal let renamingIdentifier: String?
        
        internal var parentObject: () -> CoreStoreObject = {
            
            CoreStore.abort("Attempted to access values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types.")
        }
        
        internal var nativeValue: NSOrderedSet {
            
            get {
                
                let object = self.parentObject() as! O
                CoreStore.assert(
                    object.rawObject!.isRunningInAllowedQueue() == true,
                    "Attempted to access \(cs_typeName(O.self))'s value outside it's designated queue."
                )
                return object.rawObject!.getValue(
                    forKvcKey: self.keyPath,
                    didGetValue: { ($0 as! NSOrderedSet?) ?? [] }
                )
            }
            set {
                
                let object = self.parentObject() as! O
                CoreStore.assert(
                    object.rawObject!.isRunningInAllowedQueue() == true,
                    "Attempted to access \(cs_typeName(O.self))'s value outside it's designated queue."
                )
                CoreStore.assert(
                    object.rawObject!.isEditableInContext() == true,
                    "Attempted to update a \(cs_typeName(O.self))'s value from outside a transaction."
                )
                object.rawObject!.setValue(
                    newValue,
                    forKvcKey: self.keyPath
                )
            }
        }
        
        
        // MARK: Private
        
        private init(keyPath: String, inverseKeyPath: @escaping () -> String?, deleteRule: DeleteRule, minCount: Int, maxCount: Int, versionHashModifier: String?, renamingIdentifier: String?) {
            
            self.keyPath = keyPath
            self.deleteRule = deleteRule.nativeValue
            self.inverse = (D.self, inverseKeyPath)
            self.versionHashModifier = versionHashModifier
            self.renamingIdentifier = renamingIdentifier
            
            let range = (Swift.max(0, minCount) ... maxCount)
            self.minCount = range.lowerBound
            self.maxCount = range.upperBound
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
        
        public convenience init(_ keyPath: KeyPath, deleteRule: DeleteRule = .nullify, minCount: Int = 0, maxCount: Int = 0, versionHashModifier: String? = nil, renamingIdentifier: String? = nil) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { nil }, deleteRule: deleteRule, minCount: minCount, maxCount: maxCount, versionHashModifier: versionHashModifier, renamingIdentifier: renamingIdentifier)
        }
        
        public convenience init(_ keyPath: KeyPath, inverse: @escaping (D) -> RelationshipContainer<D>.ToOne<O>, deleteRule: DeleteRule = .nullify, minCount: Int = 0, maxCount: Int = 0, versionHashModifier: String? = nil, renamingIdentifier: String? = nil) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { inverse(D.meta).keyPath }, deleteRule: deleteRule, minCount: minCount, maxCount: maxCount, versionHashModifier: versionHashModifier, renamingIdentifier: renamingIdentifier)
        }
        
        public convenience init(_ keyPath: KeyPath, inverse: @escaping (D) -> RelationshipContainer<D>.ToManyOrdered<O>, deleteRule: DeleteRule = .nullify, minCount: Int = 0, maxCount: Int = 0, versionHashModifier: String? = nil, renamingIdentifier: String? = nil) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { inverse(D.meta).keyPath }, deleteRule: deleteRule, minCount: minCount, maxCount: maxCount, versionHashModifier: versionHashModifier, renamingIdentifier: renamingIdentifier)
        }
        
        public convenience init(_ keyPath: KeyPath, inverse: @escaping (D) -> RelationshipContainer<D>.ToManyUnordered<O>, deleteRule: DeleteRule = .nullify, minCount: Int = 0, maxCount: Int = 0, versionHashModifier: String? = nil, renamingIdentifier: String? = nil) {
            
            self.init(keyPath: keyPath, inverseKeyPath: { inverse(D.meta).keyPath }, deleteRule: deleteRule, minCount: minCount, maxCount: maxCount, versionHashModifier: versionHashModifier, renamingIdentifier: renamingIdentifier)
        }
        
        public var value: Set<D> {
            
            get {
                
                return Set(self.nativeValue.map({ D.cs_fromRaw(object: $0 as! NSManagedObject) }))
            }
            set {
                
                self.nativeValue = NSSet(array: newValue.map({ $0.rawObject! }))
            }
        }
        
        
        // MARK: RelationshipProtocol
        
        public let keyPath: KeyPath
        
        internal let isToMany = true
        internal let isOptional = true
        internal let isOrdered = false
        internal let deleteRule: NSDeleteRule
        internal let minCount: Int
        internal let maxCount: Int
        internal let inverse: (type: CoreStoreObject.Type, keyPath: () -> KeyPath?)
        internal let versionHashModifier: String?
        internal let renamingIdentifier: String?
        
        internal var parentObject: () -> CoreStoreObject = {
            
            CoreStore.abort("Attempted to access values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types.")
        }
        
        internal var nativeValue: NSSet {
            
            get {
                
                let object = self.parentObject() as! O
                CoreStore.assert(
                    object.rawObject!.isRunningInAllowedQueue() == true,
                    "Attempted to access \(cs_typeName(O.self))'s value outside it's designated queue."
                )
                return object.rawObject!.getValue(
                    forKvcKey: self.keyPath,
                    didGetValue: { ($0 as! NSSet?) ?? [] }
                )
            }
            set {
                
                let object = self.parentObject() as! O
                CoreStore.assert(
                    object.rawObject!.isRunningInAllowedQueue() == true,
                    "Attempted to access \(cs_typeName(O.self))'s value outside it's designated queue."
                )
                CoreStore.assert(
                    object.rawObject!.isEditableInContext() == true,
                    "Attempted to update a \(cs_typeName(O.self))'s value from outside a transaction."
                )
                object.rawObject!.setValue(
                    newValue,
                    forKvcKey: self.keyPath
                )
            }
        }
        
        
        // MARK: Private
        
        private init(keyPath: KeyPath, inverseKeyPath: @escaping () -> KeyPath?, deleteRule: DeleteRule, minCount: Int, maxCount: Int, versionHashModifier: String?, renamingIdentifier: String?) {
            
            self.keyPath = keyPath
            self.deleteRule = deleteRule.nativeValue
            self.inverse = (D.self, inverseKeyPath)
            self.versionHashModifier = versionHashModifier
            self.renamingIdentifier = renamingIdentifier
            
            let range = (Swift.max(0, minCount) ... maxCount)
            self.minCount = range.lowerBound
            self.maxCount = range.upperBound
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


// MARK: RelationshipContainer.ToManyOrdered: RandomAccessCollection

extension RelationshipContainer.ToManyOrdered: RandomAccessCollection {
    
    // MARK: Sequence
    
    public typealias Iterator = AnyIterator<D>
    
    public func makeIterator() -> Iterator {
        
        let iterator = self.nativeValue.makeIterator()
        return AnyIterator({ D.cs_fromRaw(object: iterator.next() as! NSManagedObject) })
    }
    
    
    // MARK: Collection
    
    public typealias Index = Int
    
    public var startIndex: Index {
        
        return 0
    }
    
    public var endIndex: Index {
        
        return self.nativeValue.count
    }
    
    public subscript(position: Index) -> Iterator.Element {
        
        return D.cs_fromRaw(object: self.nativeValue[position] as! NSManagedObject)
    }
    
    public func index(after i: Index) -> Index {
        
        return i + 1
    }
}


// MARK: RelationshipContainer.ToManyUnordered: Sequence

extension RelationshipContainer.ToManyUnordered: Sequence {
    
    public var count: Int {
        
        return self.nativeValue.count
    }
    
    public var isEmpty: Bool {
    
        return self.nativeValue.count == 0
    }
    
    
    // MARK: Sequence
    
    public typealias Iterator = AnyIterator<D>
    
    public func makeIterator() -> Iterator {
        
        let iterator = self.nativeValue.makeIterator()
        return AnyIterator({ D.cs_fromRaw(object: iterator.next() as! NSManagedObject) })
    }
}


// MARK: - RelationshipProtocol

internal protocol RelationshipProtocol: class {
    
    var keyPath: KeyPath { get }
    var isToMany: Bool { get }
    var isOrdered: Bool { get }
    var deleteRule: NSDeleteRule { get }
    var inverse: (type: CoreStoreObject.Type, keyPath: () -> KeyPath?) { get }
    var parentObject: () -> CoreStoreObject { get set }
    var versionHashModifier: String? { get }
    var renamingIdentifier: String? { get }
    var minCount: Int { get }
    var maxCount: Int { get }
}
