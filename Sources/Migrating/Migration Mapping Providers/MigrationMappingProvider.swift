//
//  MigrationMappingProvider.swift
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


// MARK: - MigrationMappingProvider

public protocol MigrationMappingProvider {
    
    associatedtype SourceSchema: DynamicSchema
    associatedtype DestinationSchema: DynamicSchema
    
    var sourceSchema: SourceSchema { get }
    var destinationSchema: DestinationSchema { get }
    
    init(source: SourceSchema, destination: DestinationSchema)
    
//    func migrate(
//        from oldObject: SourceType,
//        to newObject: DestinationType,
//        transaction: UnsafeDataTransaction
//    )
//    
//    func forEachPropertyMapping(
//        from oldObject: SourceType,
//        to newObject: DestinationType,
//        removed: (_ keyPath: KeyPath) -> Void,
//        added: (_ keyPath: KeyPath) -> Void,
//        transformed: (_ keyPath: KeyPath) -> Void,
//        copied: (_ keyPath: KeyPath) -> Void
//    )
}

public extension MigrationMappingProvider {
    
//    func migrate(from oldObject: SourceType, to newObject: DestinationType, transaction: UnsafeDataTransaction) {
//        
//        
//    }
//    
//    func forEachPropertyMapping(from oldObject: SourceType, to newObject: DestinationType, removed: (_ keyPath: KeyPath) -> Void, added: (_ keyPath: KeyPath) -> Void, transformed: (_ keyPath: KeyPath) -> Void) {
//        
//        let oldAttributes = oldObject.cs_toRaw().entity.attributesByName
//        let newAttributes = newObject.cs_toRaw().entity.attributesByName
//        let oldAttributeKeys = Set(oldAttributes.keys)
//        let newAttributeKeys = Set(newAttributes.keys)
//        for keyPath in
//    }
}

public extension MigrationMappingProvider {
    
}


// MARK: - UnsafeMigrationProxyObject

public final class UnsafeMigrationProxyObject {
    
    public subscript(kvcKey: KeyPath) -> Any? {
        
        get {
            
            return self.rawObject.cs_accessValueForKVCKey(kvcKey)
        }
        set {
            
            self.rawObject.cs_setValue(newValue, forKVCKey: kvcKey)
        }
    }
    
    
    // MARK: Internal
    
    internal init(_ rawObject: NSManagedObject) {
        
        self.rawObject = rawObject
    }
    
    
    // MARK: Private
    
    private let rawObject: NSManagedObject
}
