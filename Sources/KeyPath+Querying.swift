//
//  KeyPath+Querying.swift
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


// MARK: - KeyPath where Root: NSManagedObject, Value: QueryableAttributeType & Equatable

public func == <O: NSManagedObject, V: QueryableAttributeType & Equatable>(_ keyPath: KeyPath<O, V>, _ value: V) -> Where<O> {
    
    return Where<O>(keyPath._kvcKeyPathString!, isEqualTo: value)
}

public func != <O: NSManagedObject, V: QueryableAttributeType & Equatable>(_ keyPath: KeyPath<O, V>, _ value: V) -> Where<O> {
    
    return !Where<O>(keyPath._kvcKeyPathString!, isEqualTo: value)
}

public func ~= <O: NSManagedObject, V: QueryableAttributeType & Equatable, S: Sequence>(_ sequence: S, _ keyPath: KeyPath<O, V>) -> Where<O> where S.Iterator.Element == V {
    
    return Where<O>(keyPath._kvcKeyPathString!, isMemberOf: sequence)
}


// MARK: - KeyPath where Root: NSManagedObject, Value: Optional<QueryableAttributeType & Equatable>

public func == <O: NSManagedObject, V: QueryableAttributeType & Equatable>(_ keyPath: KeyPath<O, Optional<V>>, _ value: V?) -> Where<O> {
    
    return Where<O>(keyPath._kvcKeyPathString!, isEqualTo: value)
}

public func != <O: NSManagedObject, V: QueryableAttributeType & Equatable>(_ keyPath: KeyPath<O, Optional<V>>, _ value: V?) -> Where<O> {
    
    return !Where<O>(keyPath._kvcKeyPathString!, isEqualTo: value)
}

public func ~= <O: NSManagedObject, V: QueryableAttributeType & Equatable, S: Sequence>(_ sequence: S, _ keyPath: KeyPath<O, Optional<V>>) -> Where<O> where S.Iterator.Element == V {
    
    return Where<O>(keyPath._kvcKeyPathString!, isMemberOf: sequence)
}


// MARK: - KeyPath where Root: NSManagedObject, Value: QueryableAttributeType & Comparable

public func < <O: NSManagedObject, V: QueryableAttributeType & Comparable>(_ keyPath: KeyPath<O, V>, _ value: V) -> Where<O> {
    
    return Where<O>("%K < %@", keyPath._kvcKeyPathString!, value)
}

public func > <O: NSManagedObject, V: QueryableAttributeType & Comparable>(_ keyPath: KeyPath<O, V>, _ value: V) -> Where<O> {
    
    return Where<O>("%K > %@", keyPath._kvcKeyPathString!, value)
}

public func <= <O: NSManagedObject, V: QueryableAttributeType & Comparable>(_ keyPath: KeyPath<O, V>, _ value: V) -> Where<O> {
    
    return Where<O>("%K <= %@", keyPath._kvcKeyPathString!, value)
}

public func >= <O: NSManagedObject, V: QueryableAttributeType & Comparable>(_ keyPath: KeyPath<O, V>, _ value: V) -> Where<O> {
    
    return Where<O>("%K >= %@", keyPath._kvcKeyPathString!, value)
}


// MARK: - KeyPath where Root: NSManagedObject, Value: Optional<QueryableAttributeType & Comparable>

public func < <O: NSManagedObject, V: QueryableAttributeType & Comparable>(_ keyPath: KeyPath<O, Optional<V>>, _ value: V?) -> Where<O> {
    
    if let value = value {
        
        return Where<O>("%K < %@", keyPath._kvcKeyPathString!, value)
    }
    else {
        
        return Where<O>("%K < nil", keyPath._kvcKeyPathString!)
    }
}

public func > <O: NSManagedObject, V: QueryableAttributeType & Comparable>(_ keyPath: KeyPath<O, Optional<V>>, _ value: V?) -> Where<O> {
    
    if let value = value {
        
        return Where<O>("%K > %@", keyPath._kvcKeyPathString!, value)
    }
    else {
        
        return Where<O>("%K > nil", keyPath._kvcKeyPathString!)
    }
}

public func <= <O: NSManagedObject, V: QueryableAttributeType & Comparable>(_ keyPath: KeyPath<O, Optional<V>>, _ value: V?) -> Where<O> {
    
    if let value = value {
        
        return Where<O>("%K <= %@", keyPath._kvcKeyPathString!, value)
    }
    else {
        
        return Where<O>("%K <= nil", keyPath._kvcKeyPathString!)
    }
}

public func >= <O: NSManagedObject, V: QueryableAttributeType & Comparable>(_ keyPath: KeyPath<O, Optional<V>>, _ value: V?) -> Where<O> {
    
    if let value = value {
        
        return Where<O>("%K >= %@", keyPath._kvcKeyPathString!, value)
    }
    else {
        
        return Where<O>("%K >= nil", keyPath._kvcKeyPathString!)
    }
}


// MARK: - KeyPath where Root: NSManagedObject, Value: NSManagedObject

public func == <O: NSManagedObject, D: NSManagedObject>(_ keyPath: KeyPath<O, D>, _ object: D) -> Where<O> {
    
    return Where<O>(keyPath._kvcKeyPathString!, isEqualTo: object)
}

public func != <O: NSManagedObject, D: NSManagedObject>(_ keyPath: KeyPath<O, D>, _ object: D) -> Where<O> {
    
    return !Where<O>(keyPath._kvcKeyPathString!, isEqualTo: object)
}

public func ~= <O: NSManagedObject, D: NSManagedObject, S: Sequence>(_ sequence: S, _ keyPath: KeyPath<O, D>) -> Where<O> where S.Iterator.Element == D {
    
    return Where<O>(keyPath._kvcKeyPathString!, isMemberOf: sequence)
}

public func == <O: NSManagedObject, D: NSManagedObject>(_ keyPath: KeyPath<O, D>, _ objectID: NSManagedObjectID?) -> Where<O> {
    
    return Where<O>(keyPath._kvcKeyPathString!, isEqualTo: objectID)
}

public func != <O: NSManagedObject, D: NSManagedObject>(_ keyPath: KeyPath<O, D>, _ objectID: NSManagedObjectID?) -> Where<O> {
    
    return !Where<O>(keyPath._kvcKeyPathString!, isEqualTo: objectID)
}

public func ~= <O: NSManagedObject, D: NSManagedObject, S: Sequence>(_ sequence: S, _ keyPath: KeyPath<O, D>) -> Where<O> where S.Iterator.Element == NSManagedObjectID {
    
    return Where<O>(keyPath._kvcKeyPathString!, isMemberOf: sequence)
}


// MARK: - KeyPath where Root: NSManagedObject, Value: Optional<NSManagedObject>

public func == <O: NSManagedObject, D: NSManagedObject>(_ keyPath: KeyPath<O, Optional<D>>, _ object: D?) -> Where<O> {
    
    return Where<O>(keyPath._kvcKeyPathString!, isEqualTo: object)
}

public func != <O: NSManagedObject, D: NSManagedObject>(_ keyPath: KeyPath<O, Optional<D>>, _ object: D?) -> Where<O> {
    
    return !Where<O>(keyPath._kvcKeyPathString!, isEqualTo: object)
}

public func ~= <O: NSManagedObject, D: NSManagedObject, S: Sequence>(_ sequence: S, _ keyPath: KeyPath<O, Optional<D>>) -> Where<O> where S.Iterator.Element == D {
    
    return Where<O>(keyPath._kvcKeyPathString!, isMemberOf: sequence)
}

public func == <O: NSManagedObject, D: NSManagedObject>(_ keyPath: KeyPath<O, Optional<D>>, _ objectID: NSManagedObjectID?) -> Where<O> {
    
    return Where<O>(keyPath._kvcKeyPathString!, isEqualTo: objectID)
}

public func != <O: NSManagedObject, D: NSManagedObject>(_ keyPath: KeyPath<O, Optional<D>>, _ objectID: NSManagedObjectID?) -> Where<O> {
    
    return !Where<O>(keyPath._kvcKeyPathString!, isEqualTo: objectID)
}

public func ~= <O: NSManagedObject, D: NSManagedObject, S: Sequence>(_ sequence: S, _ keyPath: KeyPath<O, Optional<D>>) -> Where<O> where S.Iterator.Element == NSManagedObjectID {
    
    return Where<O>(keyPath._kvcKeyPathString!, isMemberOf: sequence)
}


// MARK: - KeyPath where Root: CoreStoreObject, Value: ValueContainer<Root>.Required<QueryableAttributeType & Equatable>

public func == <O, V>(_ keyPath: KeyPath<O, ValueContainer<O>.Required<V>>, _ value: V) -> Where<O> {

    return Where<O>(O.meta[keyPath: keyPath].keyPath, isEqualTo: value)
}

public func != <O, V>(_ keyPath: KeyPath<O, ValueContainer<O>.Required<V>>, _ value: V) -> Where<O> {
    
    return !Where<O>(O.meta[keyPath: keyPath].keyPath, isEqualTo: value)
}

public func ~= <O, V, S: Sequence>(_ sequence: S, _ keyPath: KeyPath<O, ValueContainer<O>.Required<V>>) -> Where<O> where S.Iterator.Element == V {
    
    return Where<O>(O.meta[keyPath: keyPath].keyPath, isMemberOf: sequence)
}


// MARK: - KeyPath where Root: CoreStoreObject, Value: ValueContainer<Root>.Optional<QueryableAttributeType & Equatable>

public func == <O, V>(_ keyPath: KeyPath<O, ValueContainer<O>.Optional<V>>, _ value: V?) -> Where<O> {
    
    return Where<O>(O.meta[keyPath: keyPath].keyPath, isEqualTo: value)
}

public func != <O, V>(_ keyPath: KeyPath<O, ValueContainer<O>.Optional<V>>, _ value: V?) -> Where<O> {
    
    return !Where<O>(O.meta[keyPath: keyPath].keyPath, isEqualTo: value)
}

public func ~= <O, V, S: Sequence>(_ sequence: S, _ keyPath: KeyPath<O, ValueContainer<O>.Optional<V>>) -> Where<O> where S.Iterator.Element == V {
    
    return Where<O>(O.meta[keyPath: keyPath].keyPath, isMemberOf: sequence)
}


// MARK: - KeyPath where Root: CoreStoreObject, Value: ValueContainer<Root>.Required<QueryableAttributeType & Comparable>

public func < <O, V: Comparable>(_ keyPath: KeyPath<O, ValueContainer<O>.Required<V>>, _ value: V) -> Where<O> {
    
    return Where<O>("%K < %@", O.meta[keyPath: keyPath].keyPath, value)
}

public func > <O, V: Comparable>(_ keyPath: KeyPath<O, ValueContainer<O>.Required<V>>, _ value: V) -> Where<O> {
    
    return Where<O>("%K > %@", O.meta[keyPath: keyPath].keyPath, value)
}

public func <= <O, V: Comparable>(_ keyPath: KeyPath<O, ValueContainer<O>.Required<V>>, _ value: V) -> Where<O> {
    
    return Where<O>("%K <= %@", O.meta[keyPath: keyPath].keyPath, value)
}

public func >= <O, V: Comparable>(_ keyPath: KeyPath<O, ValueContainer<O>.Required<V>>, _ value: V) -> Where<O> {
    
    return Where<O>("%K >= %@", O.meta[keyPath: keyPath].keyPath, value)
}


// MARK: - KeyPath where Root: CoreStoreObject, Value: ValueContainer<Root>.Optional<QueryableAttributeType & Comparable>

public func < <O, V>(_ keyPath: KeyPath<O, ValueContainer<O>.Optional<V>>, _ value: V?) -> Where<O> {
    
    if let value = value {

        return Where<O>("%K < %@", O.meta[keyPath: keyPath].keyPath, value)
    }
    else {

        return Where<O>("%K < nil", O.meta[keyPath: keyPath].keyPath)
    }
}

public func > <O, V>(_ keyPath: KeyPath<O, ValueContainer<O>.Optional<V>>, _ value: V?) -> Where<O> {
    
    if let value = value {
        
        return Where<O>("%K > %@", O.meta[keyPath: keyPath].keyPath, value)
    }
    else {
        
        return Where<O>("%K > nil", O.meta[keyPath: keyPath].keyPath)
    }
}

public func <= <O, V>(_ keyPath: KeyPath<O, ValueContainer<O>.Optional<V>>, _ value: V?) -> Where<O> {
    
    if let value = value {
        
        return Where<O>("%K <= %@", O.meta[keyPath: keyPath].keyPath, value)
    }
    else {
        
        return Where<O>("%K <= nil", O.meta[keyPath: keyPath].keyPath)
    }
}

public func >= <O, V>(_ keyPath: KeyPath<O, ValueContainer<O>.Optional<V>>, _ value: V?) -> Where<O> {
    
    if let value = value {
        
        return Where<O>("%K >= %@", O.meta[keyPath: keyPath].keyPath, value)
    }
    else {
        
        return Where<O>("%K >= nil", O.meta[keyPath: keyPath].keyPath)
    }
}


// MARK: - KeyPath where Root: CoreStoreObject, Value: RelationshipContainer<Root>.ToOne<CoreStoreObject>

public func == <O, D>(_ keyPath: KeyPath<O, RelationshipContainer<O>.ToOne<D>>, _ object: D) -> Where<O> {
    
    return Where<O>(O.meta[keyPath: keyPath].keyPath, isEqualTo: object)
}

public func == <O, D>(_ keyPath: KeyPath<O, RelationshipContainer<O>.ToOne<D>>, _ object: D?) -> Where<O> {
    
    return Where<O>(O.meta[keyPath: keyPath].keyPath, isEqualTo: object)
}

public func != <O, D>(_ keyPath: KeyPath<O, RelationshipContainer<O>.ToOne<D>>, _ object: D) -> Where<O> {
    
    return !Where<O>(O.meta[keyPath: keyPath].keyPath, isEqualTo: object)
}

public func != <O, D>(_ keyPath: KeyPath<O, RelationshipContainer<O>.ToOne<D>>, _ object: D?) -> Where<O> {
    
    return !Where<O>(O.meta[keyPath: keyPath].keyPath, isEqualTo: object)
}

public func ~= <O, D, S: Sequence>(_ sequence: S, _ keyPath: KeyPath<O, RelationshipContainer<O>.ToOne<D>>) -> Where<O> where S.Iterator.Element == D {
    
    return Where<O>(O.meta[keyPath: keyPath].keyPath, isMemberOf: sequence)
}
