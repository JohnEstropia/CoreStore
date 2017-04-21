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
    var isAbstract: Bool { get }
    var versionHashModifier: String? { get }
}


// MARK: Entity

public struct Entity<O: CoreStoreObject>: DynamicEntity, Hashable {
    
    public init(_ entityName: String, isAbstract: Bool = false, versionHashModifier: String? = nil) {
        
        self.init(O.self, entityName, isAbstract: isAbstract, versionHashModifier: versionHashModifier)
    }
    
    public init(_ type: O.Type, _ entityName: String, isAbstract: Bool = false, versionHashModifier: String? = nil) {
        
        self.type = type
        self.entityName = entityName
        self.isAbstract = isAbstract
        self.versionHashModifier = versionHashModifier
    }
    
    
    // MARK: DynamicEntity
    
    public let type: CoreStoreObject.Type
    public let entityName: EntityName
    public let isAbstract: Bool
    public let versionHashModifier: String?
    
    
    // MARK: Equatable
    
    public static func == (lhs: Entity, rhs: Entity) -> Bool {
        
        return lhs.type == rhs.type
            && lhs.entityName == rhs.entityName
            && lhs.isAbstract == rhs.isAbstract
            && lhs.versionHashModifier == rhs.versionHashModifier
    }
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        return ObjectIdentifier(self.type).hashValue
            ^ self.entityName.hashValue
            ^ self.isAbstract.hashValue
            ^ (self.versionHashModifier ?? "").hashValue
    }
}
