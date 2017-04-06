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


// MARK: - ManagedObjectProtocol

public extension ManagedObjectProtocol where Self: ManagedObject {
    
    public typealias Relationship = RelationshipContainer<Self>
}


// MARK: - RelationshipContainer

public enum RelationshipContainer<O: ManagedObject> {
    
    // MARK: - ToOne
    
    public final class ToOne<D: ManagedObject>: RelationshipProtocol {
        
        // MARK: -
        
        public static func .= (_ relationship: RelationshipContainer<O>.ToOne<D>, _ value: D?) {
            
            relationship.value = value
        }

        public static postfix func * (_ relationship: RelationshipContainer<O>.ToOne<D>) -> D? {
            
            return relationship.value
        }
        
        public init(_ keyPath: String, deleteRule: DeleteRule = .nullify) {
            
            self.keyPath = keyPath
            self.deleteRule = deleteRule.nativeValue
            self.inverse = (D.self, nil)
        }
        
        public init(_ keyPath: String, inverse: (D) -> RelationshipContainer<D>.ToOne<O>, deleteRule: DeleteRule = .nullify) {
            
            self.keyPath = keyPath
            self.deleteRule = deleteRule.nativeValue
            
            let inverseRelationship = inverse(D.meta)
            self.inverse = (D.self, inverseRelationship.keyPath)
        }
        
        public var value: D? {
            
            get {
                
                let object = self.accessRawObject()
                let key = self.keyPath
                return object.value(forKey: key)
                    .flatMap({ D.cs_from(object: $0 as! NSManagedObject) })
            }
            set {
                
                let object = self.accessRawObject()
                let key = self.keyPath
                object.setValue(newValue?.rawObject, forKey: key)
            }
        }
        
        
        // MARK: RelationshipProtocol
        
        public let keyPath: String
        
        internal let isToMany = false
        internal let isOrdered = false
        internal let deleteRule: NSDeleteRule
        internal let inverse: (type: ManagedObject.Type, keyPath: String?)
        
        internal var accessRawObject: () -> NSManagedObject = {
            
            fatalError("\(O.self) relationship values should not be accessed")
        }
    }
    
    
    // MARK: - ToManyOrdered
    
    public final class ToManyOrdered<D: ManagedObject>: RelationshipProtocol {
        
        // MARK: -
        
        public static func .= (_ relationship: RelationshipContainer<O>.ToManyOrdered<D>, _ value: [D]) {
            
            relationship.value = value
        }
        
        public static postfix func * (_ relationship: RelationshipContainer<O>.ToManyOrdered<D>) -> [D] {
            
            return relationship.value
        }
        
        public init(_ keyPath: String, deleteRule: DeleteRule = .nullify) {
            
            self.keyPath = keyPath
            self.deleteRule = deleteRule.nativeValue
            self.inverse = (D.self, nil)
        }
        
        public var value: [D] {
            
            get {
                
                let object = self.accessRawObject()
                let key = self.keyPath
                guard let orderedSet = object.value(forKey: key) as! NSOrderedSet? else {
                    
                    return []
                }
                return orderedSet.array as! [D]
            }
            set {
                
                let object = self.accessRawObject()
                let key = self.keyPath
                object.setValue(NSOrderedSet(array: newValue), forKey: key)
            }
        }
        
        
        // MARK: RelationshipProtocol
        
        public let keyPath: String
        
        internal let isToMany = true
        internal let isOptional = true
        internal let isOrdered = true
        internal let deleteRule: NSDeleteRule
        internal let inverse: (type: ManagedObject.Type, keyPath: String?)
        
        internal var accessRawObject: () -> NSManagedObject = {
            
            fatalError("\(O.self) relationship values should not be accessed")
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
    
    var keyPath: String { get }
    var isToMany: Bool { get }
    var isOrdered: Bool { get }
    var deleteRule: NSDeleteRule { get }
    var inverse: (type: ManagedObject.Type, keyPath: String?) { get }
    var accessRawObject: () -> NSManagedObject { get set }
}
