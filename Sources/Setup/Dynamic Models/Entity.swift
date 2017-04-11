//
//  Entity.swift
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
import ObjectiveC


// MARK: - DynamicEntity

public protocol DynamicEntity {
    
    var type: CoreStoreObject.Type { get }
    var entityName: EntityName { get }
}


// MARK: Entity

public struct Entity<O: CoreStoreObject>: DynamicEntity, Hashable {
    
    public init(_ entityName: String) {
        
        self.type = O.self
        self.entityName = entityName
    }
    
    public init(_ type: O.Type, _ entityName: String) {
        
        self.type = type
        self.entityName = entityName
    }
    
    
    // MARK: - VersionHash
    
    public struct VersionHash: ExpressibleByArrayLiteral {
        
        let hash: Data
        
        public init(_ hash: Data) {
            
            self.hash = hash
        }
        
        
        // MARK: ExpressibleByArrayLiteral
        
        public typealias Element = UInt8
        
        public init(arrayLiteral elements: UInt8...) {
            
            self.hash = Data(bytes: elements)
        }
    }
    
    
    // MARK: DynamicEntity
    
    public let type: CoreStoreObject.Type
    public let entityName: EntityName
    
    
    // MARK: Equatable
    
    public static func == (lhs: Entity, rhs: Entity) -> Bool {
        
        return lhs.type == rhs.type
            && lhs.entityName == rhs.entityName
    }
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        return ObjectIdentifier(self.type).hashValue
    }
}
