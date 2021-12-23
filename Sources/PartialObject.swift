//
//  PartialObject.swift
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
import Foundation


// MARK: - PartialObject

/**
 A `PartialObject` is only used when overriding getters and setters for `CoreStoreObject` properties. Custom getters and setters are implemented as a closure that "overrides" the default property getter/setter. The closure receives a `PartialObject<O>`, which acts as a fast, type-safe KVC interface for `CoreStoreObject`. The reason a `CoreStoreObject` instance is not passed directly is because the Core Data runtime is not aware of `CoreStoreObject` properties' static typing, and so loading those info everytime KVO invokes this accessor method incurs a heavy performance hit (especially in KVO-heavy operations such as `ListMonitor` observing.) When accessing the property value from `PartialObject<O>`, make sure to use `PartialObject<O>.persistentValue(for:)` instead of `PartialObject<O>.value(for:)`, which would unintentionally execute the same closure again recursively.
 */
public struct PartialObject<O: CoreStoreObject> {
    
    /**
     Returns a the actual `CoreStoreObject` instance for the receiver.
     */
    public func completeObject() -> O {
        
        return O.cs_fromRaw(object: self.rawObject)
    }


    // MARK: Field.Stored accessors/mutators



    
    
    // MARK: Value.Required accessors/mutators
    
    /**
     Returns the value for the property identified by a given key.
     */
    public func value<V>(for property: (O) -> ValueContainer<O>.Required<V>) -> V {
        
        return V.cs_fromQueryableNativeType(
            self.rawObject.value(forKey: property(O.meta).keyPath)! as! V.QueryableNativeType
        )!
    }
    
    /**
     Sets the property of the receiver specified by a given key to a given value.
     */
    public func setValue<V>(_ value: V, for property: (O) -> ValueContainer<O>.Required<V>) {
        
        self.rawObject.setValue(
            value.cs_toQueryableNativeType(),
            forKey: property(O.meta).keyPath
        )
    }
    
    /**
     Returns the value for the specified property from the managed object’s private internal storage.

     This method does not invoke the access notification methods (`willAccessValue(forKey:)` and `didAccessValue(forKey:)`). This method is used primarily by subclasses that implement custom accessor methods that need direct access to the receiver’s private storage.
     */
    public func primitiveValue<V>(for property: (O) -> ValueContainer<O>.Required<V>) -> V {
        
        return V.cs_fromQueryableNativeType(
            self.rawObject.primitiveValue(forKey: property(O.meta).keyPath)! as! V.QueryableNativeType
        )!
    }
    
    /**
     Sets in the object's private internal storage the value of a given property.
     
     Sets in the receiver’s private internal storage the value of the property specified by key to value.
     */
    public func setPrimitiveValue<V>(_ value: V, for property: (O) -> ValueContainer<O>.Required<V>) {
        
        self.rawObject.setPrimitiveValue(
            value.cs_toQueryableNativeType(),
            forKey: property(O.meta).keyPath
        )
    }
    
    
    // MARK: Value.Optional utilities
    
    /**
     Returns the value for the property identified by a given key.
     */
    public func value<V>(for property: (O) -> ValueContainer<O>.Optional<V>) -> V? {
        
        return (self.rawObject.value(forKey: property(O.meta).keyPath) as! V.QueryableNativeType?)
            .flatMap(V.cs_fromQueryableNativeType)
    }
    
    /**
     Sets the property of the receiver specified by a given key to a given value.
     */
    public func setValue<V>(_ value: V?, for property: (O) -> ValueContainer<O>.Optional<V>) {
        
        self.rawObject.setValue(
            value?.cs_toQueryableNativeType(),
            forKey: property(O.meta).keyPath
        )
    }
    
    /**
     Returns the value for the specified property from the managed object’s private internal storage.
     
     This method does not invoke the access notification methods (`willAccessValue(forKey:)` and `didAccessValue(forKey:)`). This method is used primarily by subclasses that implement custom accessor methods that need direct access to the receiver’s private storage.
     */
    public func primitiveValue<V>(for property: (O) -> ValueContainer<O>.Optional<V>) -> V? {
        
        return (self.rawObject.primitiveValue(forKey: property(O.meta).keyPath) as! V.QueryableNativeType?)
            .flatMap(V.cs_fromQueryableNativeType)
    }
    
    /**
     Sets in the object's private internal storage the value of a given property.
     
     Sets in the receiver’s private internal storage the value of the property specified by key to value.
     */
    public func setPrimitiveValue<V>(_ value: V?, for property: (O) -> ValueContainer<O>.Optional<V>) {
        
        self.rawObject.setPrimitiveValue(
            value?.cs_toQueryableNativeType(),
            forKey: property(O.meta).keyPath
        )
    }
    
    
    // MARK: Transformable.Required utilities
    
    /**
     Returns the value for the property identified by a given key.
     */
    public func value<V>(for property: (O) -> TransformableContainer<O>.Required<V>) -> V {
        
        return self.rawObject.value(forKey: property(O.meta).keyPath)! as! V
    }
    
    /**
     Sets the property of the receiver specified by a given key to a given value.
     */
    public func setValue<V>(_ value: V, for property: (O) -> TransformableContainer<O>.Required<V>) {
        
        self.rawObject.setValue(
            value,
            forKey: property(O.meta).keyPath
        )
    }
    
    /**
     Returns the value for the specified property from the managed object’s private internal storage.
     
     This method does not invoke the access notification methods (`willAccessValue(forKey:)` and `didAccessValue(forKey:)`). This method is used primarily by subclasses that implement custom accessor methods that need direct access to the receiver’s private storage.
     */
    public func primitiveValue<V>(for property: (O) -> TransformableContainer<O>.Required<V>) -> V {
        
        return self.rawObject.primitiveValue(forKey: property(O.meta).keyPath)! as! V
    }
    
    /**
     Sets in the object's private internal storage the value of a given property.
     
     Sets in the receiver’s private internal storage the value of the property specified by key to value.
     */
    public func setPrimitiveValue<V>(_ value: V, for property: (O) -> TransformableContainer<O>.Required<V>) {
        
        self.rawObject.setPrimitiveValue(
            value,
            forKey: property(O.meta).keyPath
        )
    }
    
    
    // MARK: Transformable.Optional utilities
    
    /**
     Returns the value for the property identified by a given key.
     */
    public func value<V>(for property: (O) -> TransformableContainer<O>.Optional<V>) -> V? {
        
        return self.rawObject.value(forKey: property(O.meta).keyPath) as! V?
    }
    
    /**
     Sets the property of the receiver specified by a given key to a given value.
     */
    public func setValue<V>(_ value: V?, for property: (O) -> TransformableContainer<O>.Optional<V>) {
        
        self.rawObject.setValue(
            value,
            forKey: property(O.meta).keyPath
        )
    }
    
    /**
     Returns the value for the specified property from the managed object’s private internal storage.
     
     This method does not invoke the access notification methods (`willAccessValue(forKey:)` and `didAccessValue(forKey:)`). This method is used primarily by subclasses that implement custom accessor methods that need direct access to the receiver’s private storage.
     */
    public func primitiveValue<V>(for property: (O) -> TransformableContainer<O>.Optional<V>) -> V? {
        
        return self.rawObject.primitiveValue(forKey: property(O.meta).keyPath) as! V?
    }
    
    /**
     Sets in the object's private internal storage the value of a given property.
     
     Sets in the receiver’s private internal storage the value of the property specified by key to value.
     */
    public func setPrimitiveValue<V>(_ value: V?, for property: (O) -> TransformableContainer<O>.Optional<V>) {
        
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
