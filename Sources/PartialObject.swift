//
//  PartialObject.swift
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


// MARK: - PartialObject

public struct PartialObject<O: CoreStoreObject> {
    
    public func completeObject() -> O {
        
        return O.cs_fromRaw(object: self.rawObject)
    }
    
    public func value<V: ImportableAttributeType>(for property: (O) -> ValueContainer<O>.Required<V>) -> V {
        
        return V.cs_fromImportableNativeType(
            self.rawObject.value(forKey: property(O.meta).keyPath)! as! V.ImportableNativeType
        )!
    }
    
    public func value<V: ImportableAttributeType>(for property: (O) -> ValueContainer<O>.Optional<V>) -> V? {
        
        return (self.rawObject.value(forKey: property(O.meta).keyPath) as! V.ImportableNativeType?)
            .flatMap(V.cs_fromImportableNativeType)
    }
    
    public func value<V: NSCoding & NSCopying>(for property: (O) -> TransformableContainer<O>.Required<V>) -> V {
        
        return self.rawObject.value(forKey: property(O.meta).keyPath)! as! V
    }
    
    public func value<V: NSCoding & NSCopying>(for property: (O) -> TransformableContainer<O>.Optional<V>) -> V? {
        
        return self.rawObject.value(forKey: property(O.meta).keyPath) as! V?
    }
    
    public func setValue<V: ImportableAttributeType>(_ value: V, for property: (O) -> ValueContainer<O>.Required<V>) {
        
        self.rawObject.setValue(
            value.cs_toImportableNativeType(),
            forKey: property(O.meta).keyPath
        )
    }
    
    public func setValue<V: ImportableAttributeType>(_ value: V?, for property: (O) -> ValueContainer<O>.Optional<V>) {
        
        self.rawObject.setValue(
            value?.cs_toImportableNativeType(),
            forKey: property(O.meta).keyPath
        )
    }
    
    public func setValue<V: NSCoding & NSCopying>(_ value: V, for property: (O) -> TransformableContainer<O>.Required<V>) {
        
        self.rawObject.setValue(
            value,
            forKey: property(O.meta).keyPath
        )
    }
    
    public func setValue<V: NSCoding & NSCopying>(_ value: V?, for property: (O) -> TransformableContainer<O>.Optional<V>) {
        
        self.rawObject.setValue(
            value,
            forKey: property(O.meta).keyPath
        )
    }
    
    public func setPrimitiveValue<V: ImportableAttributeType>(_ value: V, for property: (O) -> ValueContainer<O>.Required<V>) {
        
        self.rawObject.setPrimitiveValue(
            value.cs_toImportableNativeType(),
            forKey: property(O.meta).keyPath
        )
    }
    
    public func setPrimitiveValue<V: ImportableAttributeType>(_ value: V?, for property: (O) -> ValueContainer<O>.Optional<V>) {
        
        self.rawObject.setPrimitiveValue(
            value?.cs_toImportableNativeType(),
            forKey: property(O.meta).keyPath
        )
    }
    
    public func setPrimitiveValue<V: NSCoding & NSCopying>(_ value: V, for property: (O) -> TransformableContainer<O>.Required<V>) {
        
        self.rawObject.setPrimitiveValue(
            value,
            forKey: property(O.meta).keyPath
        )
    }
    
    public func setPrimitiveValue<V: NSCoding & NSCopying>(_ value: V?, for property: (O) -> TransformableContainer<O>.Optional<V>) {
        
        self.rawObject.setPrimitiveValue(
            value,
            forKey: property(O.meta).keyPath
        )
    }
    
    
    // MARK: Internal
    
    internal let rawObject: NSManagedObject
    
    internal init(_ rawObject: NSManagedObject) {
        
        self.rawObject = rawObject
    }
}
