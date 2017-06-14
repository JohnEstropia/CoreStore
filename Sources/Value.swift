//
//  Value.swift
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


// MARK: - DynamicObject

public extension DynamicObject where Self: CoreStoreObject {
    
    /**
     The containing type for value propertiess. `Value` properties support any type that conforms to `ImportableAttributeType`.
     ```
     class Animal: CoreStoreObject {
         let species = Value.Required<String>("species")
         let nickname = Value.Optional<String>("nickname")
         let color = Transformable.Optional<UIColor>("color")
     }
     ```
     - Important: `Value` properties are required to be stored properties. Computed properties will be ignored, including `lazy` and `weak` properties.
     */
    public typealias Value = ValueContainer<Self>
    
    /**
     The containing type for transformable properties. `Transformable` properties support types that conforms to `NSCoding & NSCopying`.
     ```
     class Animal: CoreStoreObject {
         let species = Value.Required<String>("species")
         let nickname = Value.Optional<String>("nickname")
         let color = Transformable.Optional<UIColor>("color")
     }
     ```
     - Important: `Transformable` properties are required to be stored properties. Computed properties will be ignored, including `lazy` and `weak` properties.
     */
    public typealias Transformable = TransformableContainer<Self>
}


// MARK: - ValueContainer

/**
 The containing type for value properties. Use the `DynamicObject.Value` typealias instead for shorter syntax.
 ```
 class Animal: CoreStoreObject {
     let species = Value.Required<String>("species")
     let nickname = Value.Optional<String>("nickname")
     let color = Transformable.Optional<UIColor>("color")
 }
 ```
 */
public enum ValueContainer<O: CoreStoreObject> {
    
    // MARK: - Required
    
    /**
     The containing type for required value properties. Any type that conforms to `ImportableAttributeType` are supported.
     ```
     class Animal: CoreStoreObject {
         let species = Value.Required<String>("species")
         let nickname = Value.Optional<String>("nickname")
         let color = Transformable.Optional<UIColor>("color")
     }
     ```
     - Important: `Value.Required` properties are required to be stored properties. Computed properties will be ignored, including `lazy` and `weak` properties.
     */
    public final class Required<V: ImportableAttributeType>: AttributeProtocol {
        
        /**
         Initializes the metadata for the property.
         ```
         class Person: CoreStoreObject {
             let title = Value.Required<String>("title", default: "Mr.")
             let name = Value.Required<String>(
                 "name",
                 customGetter: { (`self`, getValue) in
                    return "\(self.title.value) \(getValue())"
                 }
             )
         }
         ```
         - parameter keyPath: the permanent attribute name for this property.
         - parameter default: the initial value for the property when the object is first created. For types that implement `EmptyableAttributeType`s, this argument may be omitted and the type's "empty" value will be used instead (e.g. `false` for `Bool`, `0` for `Int`, `""` for `String`, etc.)
         - parameter isIndexed: `true` if the property should be indexed for searching, otherwise `false`. Defaults to `false` if not specified.
         - parameter isTransient: `true` if the property is transient, otherwise `false`. Defaults to `false` if not specified. The transient flag specifies whether or not a property's value is ignored when an object is saved to a persistent store. Transient properties are not saved to the persistent store, but are still managed for undo, redo, validation, and so on.
         - parameter versionHashModifier: used to mark or denote a property as being a different "version" than another even if all of the values which affect persistence are equal. (Such a difference is important in cases where the properties are unchanged but the format or content of its data are changed.)
         - parameter renamingIdentifier: used to resolve naming conflicts between models. When creating an entity mapping between entities in two managed object models, a source entity property and a destination entity property that share the same identifier indicate that a property mapping should be configured to migrate from the source to the destination. If unset, the identifier will be the property's name.
         - parameter customGetter: use this closure to make final transformations to the property's value before returning from the getter.
         - parameter self: the `CoreStoreObject`
         - parameter getValue: the original getter for the property
         - parameter customSetter: use this closure to make final transformations to the new value before assigning to the property.
         - parameter setValue: the original setter for the property
         - parameter finalNewValue: the transformed new value
         - parameter originalNewValue: the original new value
         - parameter affectedByKeyPaths: a set of key paths for properties whose values affect the value of the receiver. This is similar to `NSManagedObject.keyPathsForValuesAffectingValue(forKey:)`.
         */
        public init(
            _ keyPath: KeyPath,
            `default`: @autoclosure @escaping () -> V,
            isIndexed: Bool = false,
            isTransient: Bool = false,
            versionHashModifier: String? = nil,
            renamingIdentifier: String? = nil,
            customGetter: ((_ `self`: O, _ getValue: () -> V) -> V)? = nil,
            customSetter: ((_ `self`: O, _ setValue: (_ finalNewValue: V) -> Void, _ originalNewValue: V) -> Void)? = nil,
            affectedByKeyPaths: @autoclosure @escaping () -> Set<String> = []) {
            
            self.keyPath = keyPath
            self.isIndexed = isIndexed
            self.isTransient = isTransient
            self.defaultValue = { `default`().cs_toImportableNativeType() }
            self.versionHashModifier = versionHashModifier
            self.renamingIdentifier = renamingIdentifier
            self.customGetter = customGetter
            self.customSetter = customSetter
            self.affectedByKeyPaths = affectedByKeyPaths
        }
        
        /**
         The property value.
         */
        public var value: V {
            
            get {
                
                CoreStore.assert(
                    self.parentObject != nil,
                    "Attempted to access values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return withExtendedLifetime(self.parentObject! as! O) { (object: O) in
                    
                    CoreStore.assert(
                        object.rawObject!.isRunningInAllowedQueue() == true,
                        "Attempted to access \(cs_typeName(O.self))'s value outside it's designated queue."
                    )
                    let customGetter = (self.customGetter ?? { $1() })
                    return customGetter(
                        object,
                        { () -> V in
                            
                            return V.cs_fromImportableNativeType(
                                object.rawObject!.value(forKey: self.keyPath)! as! V.ImportableNativeType
                            )!
                        }
                    )
                }
            }
            set {
                
                CoreStore.assert(
                    self.parentObject != nil,
                    "Attempted to access values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return withExtendedLifetime(self.parentObject! as! O) { (object: O) in
                    
                    CoreStore.assert(
                        object.rawObject!.isRunningInAllowedQueue() == true,
                        "Attempted to access \(cs_typeName(O.self))'s value outside it's designated queue."
                    )
                    CoreStore.assert(
                        object.rawObject!.isEditableInContext() == true,
                        "Attempted to update a \(cs_typeName(O.self))'s value from outside a transaction."
                    )
                    let customSetter = (self.customSetter ?? { $1($2) })
                    customSetter(
                        object,
                        { (newValue: V) -> Void in
                            
                            object.rawObject!.setValue(
                                newValue.cs_toImportableNativeType(),
                                forKey: self.keyPath
                            )
                        },
                        newValue
                    )
                }
            }
        }
        
        /**
         The primitive value. Compared to `value`, `primitiveValue` bypasses all notification mechanisms. This is typically only used for setting values for transient properties.
         */
        public var primitiveValue: V {
            
            get {
                
                CoreStore.assert(
                    self.parentObject != nil,
                    "Attempted to access primitive values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return withExtendedLifetime(self.parentObject! as! O) { (object: O) in
                    
                    CoreStore.assert(
                        object.rawObject!.isRunningInAllowedQueue() == true,
                        "Attempted to access \(cs_typeName(O.self))'s primitive value outside it's designated queue."
                    )
                    return V.cs_fromImportableNativeType(
                        object.rawObject!.primitiveValue(forKey: self.keyPath)! as! V.ImportableNativeType
                    )!
                }
            }
            set {
                
                CoreStore.assert(
                    self.parentObject != nil,
                    "Attempted to access primitive values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return withExtendedLifetime(self.parentObject! as! O) { (object: O) in
                    
                    CoreStore.assert(
                        object.rawObject!.isRunningInAllowedQueue() == true,
                        "Attempted to access \(cs_typeName(O.self))'s primitive value outside it's designated queue."
                    )
                    CoreStore.assert(
                        self.isTransient || object.rawObject!.isEditableInContext() == true,
                        "Attempted to update a \(cs_typeName(O.self))'s primitive value from outside a transaction."
                    )
                    object.rawObject!.setPrimitiveValue(
                        newValue.cs_toImportableNativeType(),
                        forKey: self.keyPath
                    )
                }
            }
        }
        
        
        // MARK: AttributeProtocol
        
        internal static var attributeType: NSAttributeType {
            
            return V.cs_rawAttributeType
        }
        
        public let keyPath: KeyPath
        
        internal let isOptional = false
        internal let isIndexed: Bool
        internal let isTransient: Bool
        internal let versionHashModifier: String?
        internal let renamingIdentifier: String?
        internal let defaultValue: () -> Any?
        internal let affectedByKeyPaths: () -> Set<String>
        internal weak var parentObject: CoreStoreObject?
        
        internal private(set) lazy var getter: CoreStoreManagedObject.CustomGetter? = cs_lazy { [unowned self] in
            
            guard let customGetter = self.customGetter else {
                
                return nil
            }
            let keyPath = self.keyPath
            return { (_ id: Any) -> Any? in
                
                let rawObject = id as! CoreStoreManagedObject
                let value = customGetter(
                    O.cs_fromRaw(object: rawObject),
                    {
                        rawObject.getValue(
                            forKvcKey: keyPath,
                            didGetValue: { V.cs_fromImportableNativeType($0 as! V.ImportableNativeType!)! }
                        )
                    }
                )
                return value.cs_toImportableNativeType()
            }
        }
        
        internal private(set) lazy var setter: CoreStoreManagedObject.CustomSetter? = cs_lazy { [unowned self] in
            
            guard let customSetter = self.customSetter else {
                
                return nil
            }
            let keyPath = self.keyPath
            return { (_ id: Any, _ newValue: Any?) -> Void in
                
                let rawObject = id as! CoreStoreManagedObject
                customSetter(
                    O.cs_fromRaw(object: rawObject),
                    { (userValue: V) -> Void in
                        
                        rawObject.setValue(
                            userValue,
                            forKvcKey: keyPath,
                            willSetValue: { $0.cs_toImportableNativeType() }
                        )
                    },
                    V.cs_fromImportableNativeType(newValue as! V.ImportableNativeType)!
                )
            }
        }
        
        
        // MARK: Private
        
        private let customGetter: ((_ `self`: O, _ getValue: () -> V) -> V)?
        private let customSetter: ((_ `self`: O, _ setValue: (V) -> Void, _ newValue: V) -> Void)?
    }
    
    
    // MARK: - Optional
    
    /**
     The containing type for optional value properties. Any type that conforms to `ImportableAttributeType` are supported.
     ```
     class Animal: CoreStoreObject {
         let species = Value.Required<String>("species")
         let nickname = Value.Optional<String>("nickname")
         let color = Transformable.Optional<UIColor>("color")
     }
     ```
     - Important: `Value.Optional` properties are required to be stored properties. Computed properties will be ignored, including `lazy` and `weak` properties.
     */
    public final class Optional<V: ImportableAttributeType>: AttributeProtocol {
        
        /**
         Initializes the metadata for the property.
         ```
         class Person: CoreStoreObject {
             let title = Value.Required<String>("title", default: "Mr.")
             let name = Value.Required<String>(
                 "name",
                 customGetter: { (`self`, getValue) in
                     return "\(self.title.value) \(getValue())"
                 }
             )
         }
         ```
         - parameter keyPath: the permanent attribute name for this property.
         - parameter default: the initial value for the property when the object is first created. Defaults to `nil` if not specified.
         - parameter isIndexed: `true` if the property should be indexed for searching, otherwise `false`. Defaults to `false` if not specified.
         - parameter isTransient: `true` if the property is transient, otherwise `false`. Defaults to `false` if not specified. The transient flag specifies whether or not a property's value is ignored when an object is saved to a persistent store. Transient properties are not saved to the persistent store, but are still managed for undo, redo, validation, and so on.
         - parameter versionHashModifier: used to mark or denote a property as being a different "version" than another even if all of the values which affect persistence are equal. (Such a difference is important in cases where the properties are unchanged but the format or content of its data are changed.)
         - parameter renamingIdentifier: used to resolve naming conflicts between models. When creating an entity mapping between entities in two managed object models, a source entity property and a destination entity property that share the same identifier indicate that a property mapping should be configured to migrate from the source to the destination. If unset, the identifier will be the property's name.
         - parameter customGetter: use this closure to make final transformations to the property's value before returning from the getter.
         - parameter self: the `CoreStoreObject`
         - parameter getValue: the original getter for the property
         - parameter customSetter: use this closure to make final transformations to the new value before assigning to the property.
         - parameter setValue: the original setter for the property
         - parameter finalNewValue: the transformed new value
         - parameter originalNewValue: the original new value
         - parameter affectedByKeyPaths: a set of key paths for properties whose values affect the value of the receiver. This is similar to `NSManagedObject.keyPathsForValuesAffectingValue(forKey:)`.
         */
        public init(
            _ keyPath: KeyPath,
            `default`: @autoclosure @escaping () -> V? = nil,
            isIndexed: Bool = false,
            isTransient: Bool = false,
            versionHashModifier: String? = nil,
            renamingIdentifier: String? = nil,
            customGetter: ((_ `self`: O, _ getValue: () -> V?) -> V?)? = nil,
            customSetter: ((_ `self`: O, _ setValue: (_ finalNewValue: V?) -> Void, _ originalNewValue: V?) -> Void)? = nil,
            affectedByKeyPaths: @autoclosure @escaping () -> Set<String> = []) {
            
            self.keyPath = keyPath
            self.isIndexed = isIndexed
            self.isTransient = isTransient
            self.defaultValue = { `default`()?.cs_toImportableNativeType() }
            self.versionHashModifier = versionHashModifier
            self.renamingIdentifier = renamingIdentifier
            self.customGetter = customGetter
            self.customSetter = customSetter
            self.affectedByKeyPaths = affectedByKeyPaths
        }
        
        /**
         The property value.
         */
        public var value: V? {
            
            get {
                
                CoreStore.assert(
                    self.parentObject != nil,
                    "Attempted to access values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return withExtendedLifetime(self.parentObject! as! O) { (object: O) in
                    
                    CoreStore.assert(
                        object.rawObject!.isRunningInAllowedQueue() == true,
                        "Attempted to access \(cs_typeName(O.self))'s value outside it's designated queue."
                    )
                    let customGetter = (self.customGetter ?? { $1() })
                    return customGetter(
                        object,
                        { () -> V? in
                            
                            return (object.rawObject!.value(forKey: self.keyPath) as! V.ImportableNativeType?)
                                .flatMap(V.cs_fromImportableNativeType)
                        }
                    )
                }
            }
            set {
                
                CoreStore.assert(
                    self.parentObject != nil,
                    "Attempted to access values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return withExtendedLifetime(self.parentObject! as! O) { (object: O) in
                    
                    CoreStore.assert(
                        object.rawObject!.isRunningInAllowedQueue() == true,
                        "Attempted to access \(cs_typeName(O.self))'s value outside it's designated queue."
                    )
                    CoreStore.assert(
                        object.rawObject!.isEditableInContext() == true,
                        "Attempted to update a \(cs_typeName(O.self))'s value from outside a transaction."
                    )
                    let customSetter = (self.customSetter ?? { $1($2) })
                    customSetter(
                        object,
                        { (newValue: V?) -> Void in
                            
                            object.rawObject!.setValue(
                                newValue?.cs_toImportableNativeType(),
                                forKey: self.keyPath
                            )
                        },
                        newValue
                    )
                }
            }
        }
        
        /**
         The primitive value. Compared to `value`, `primitiveValue` bypasses all notification mechanisms. This is typically only used for setting values for transient properties.
         */
        public var primitiveValue: V? {
            
            get {
                
                CoreStore.assert(
                    self.parentObject != nil,
                    "Attempted to access primitive values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return withExtendedLifetime(self.parentObject! as! O) { (object: O) in
                    
                    CoreStore.assert(
                        object.rawObject!.isRunningInAllowedQueue() == true,
                        "Attempted to access \(cs_typeName(O.self))'s primitive value outside it's designated queue."
                    )
                    return (object.rawObject!.primitiveValue(forKey: self.keyPath) as! V.ImportableNativeType?)
                        .flatMap(V.cs_fromImportableNativeType)
                }
            }
            set {
                
                CoreStore.assert(
                    self.parentObject != nil,
                    "Attempted to access primitive values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return withExtendedLifetime(self.parentObject! as! O) { (object: O) in
                    
                    CoreStore.assert(
                        object.rawObject!.isRunningInAllowedQueue() == true,
                        "Attempted to access \(cs_typeName(O.self))'s primitive value outside it's designated queue."
                    )
                    CoreStore.assert(
                        self.isTransient || object.rawObject!.isEditableInContext() == true,
                        "Attempted to update a \(cs_typeName(O.self))'s primitive value from outside a transaction."
                    )
                    object.rawObject!.setPrimitiveValue(
                        newValue?.cs_toImportableNativeType(),
                        forKey: self.keyPath
                    )
                }
            }
        }
        
        
        // MARK: AttributeProtocol
        
        internal static var attributeType: NSAttributeType {
            
            return V.cs_rawAttributeType
        }
        
        public let keyPath: KeyPath
        internal let isOptional = true
        internal let isIndexed: Bool
        internal let isTransient: Bool
        internal let versionHashModifier: String?
        internal let renamingIdentifier: String?
        internal let defaultValue: () -> Any?
        internal let affectedByKeyPaths: () -> Set<String>
        internal weak var parentObject: CoreStoreObject?
        
        internal private(set) lazy var getter: CoreStoreManagedObject.CustomGetter? = cs_lazy { [unowned self] in
            
            guard let customGetter = self.customGetter else {
                
                return nil
            }
            let keyPath = self.keyPath
            return { (_ id: Any) -> Any? in
                
                let rawObject = id as! CoreStoreManagedObject
                let value = customGetter(
                    O.cs_fromRaw(object: rawObject),
                    {
                        rawObject.getValue(
                            forKvcKey: keyPath,
                            didGetValue: { ($0 as! V.ImportableNativeType?).flatMap(V.cs_fromImportableNativeType) }
                        )
                    }
                )
                return value?.cs_toImportableNativeType()
            }
        }
        
        internal private(set) lazy var setter: CoreStoreManagedObject.CustomSetter? = cs_lazy { [unowned self] in
            
            guard let customSetter = self.customSetter else {
                
                return nil
            }
            let keyPath = self.keyPath
            return { (_ id: Any, _ newValue: Any?) -> Void in
                
                let rawObject = id as! CoreStoreManagedObject
                customSetter(
                    O.cs_fromRaw(object: rawObject),
                    { (userValue: V?) -> Void in
                        
                        rawObject.setValue(
                            userValue,
                            forKvcKey: keyPath,
                            willSetValue: { $0?.cs_toImportableNativeType() }
                        )
                    },
                    (newValue as! V.ImportableNativeType?).flatMap(V.cs_fromImportableNativeType)
                )
            }
        }
        
        
        // MARK: Private
        
        private let customGetter: ((_ `self`: O, _ getValue: () -> V?) -> V?)?
        private let customSetter: ((_ `self`: O, _ setValue: (V?) -> Void, _ newValue: V?) -> Void)?
    }
}

public extension ValueContainer.Required where V: EmptyableAttributeType {
    
    /**
     Initializes the metadata for the property. This convenience initializer uses the `EmptyableAttributeType`'s "empty" value as the initial value for the property when the object is first created (e.g. `false` for `Bool`, `0` for `Int`, `""` for `String`, etc.)
     ```
     class Person: CoreStoreObject {
         let title = Value.Required<String>("title") // initial value defaults to empty string
     }
     ```
     - parameter keyPath: the permanent attribute name for this property.
     - parameter isIndexed: `true` if the property should be indexed for searching, otherwise `false`. Defaults to `false` if not specified.
     - parameter isTransient: `true` if the property is transient, otherwise `false`. Defaults to `false` if not specified. The transient flag specifies whether or not a property's value is ignored when an object is saved to a persistent store. Transient properties are not saved to the persistent store, but are still managed for undo, redo, validation, and so on.
     - parameter versionHashModifier: used to mark or denote a property as being a different "version" than another even if all of the values which affect persistence are equal. (Such a difference is important in cases where the properties are unchanged but the format or content of its data are changed.)
     - parameter renamingIdentifier: used to resolve naming conflicts between models. When creating an entity mapping between entities in two managed object models, a source entity property and a destination entity property that share the same identifier indicate that a property mapping should be configured to migrate from the source to the destination. If unset, the identifier will be the property's name.
     - parameter customGetter: use this closure to make final transformations to the property's value before returning from the getter.
     - parameter self: the `CoreStoreObject`
     - parameter getValue: the original getter for the property
     - parameter customSetter: use this closure to make final transformations to the new value before assigning to the property.
     - parameter setValue: the original setter for the property
     - parameter finalNewValue: the transformed new value
     - parameter originalNewValue: the original new value
     - parameter affectedByKeyPaths: a set of key paths for properties whose values affect the value of the receiver. This is similar to `NSManagedObject.keyPathsForValuesAffectingValue(forKey:)`.
     */
    public convenience init(
        _ keyPath: KeyPath,
        isIndexed: Bool = false,
        isTransient: Bool = false,
        versionHashModifier: String? = nil,
        renamingIdentifier: String? = nil,
        customGetter: ((_ `self`: O, _ getValue: () -> V) -> V)? = nil,
        customSetter: ((_ `self`: O, _ setValue: (_ finalNewValue: V) -> Void, _ originalNewValue: V) -> Void)? = nil,
        affectedByKeyPaths: @autoclosure @escaping () -> Set<String> = []) {
        
        self.init(
            keyPath,
            default: V.cs_emptyValue(),
            isIndexed: isIndexed,
            isTransient: isTransient,
            versionHashModifier: versionHashModifier,
            renamingIdentifier: renamingIdentifier,
            customGetter: customGetter,
            customSetter: customSetter,
            affectedByKeyPaths: affectedByKeyPaths
        )
    }
}


// MARK: - TransformableContainer

/**
 The containing type for transformable properties. Use the `DynamicObject.Transformable` typealias instead for shorter syntax.
 ```
 class Animal: CoreStoreObject {
     let species = Value.Required<String>("species")
     let nickname = Value.Optional<String>("nickname")
     let color = Transformable.Optional<UIColor>("color")
 }
 ```
 */
public enum TransformableContainer<O: CoreStoreObject> {
    
    // MARK: - Required
    
    /**
     The containing type for transformable properties. Any type that conforms to `NSCoding & NSCopying` are supported.
     ```
     class Animal: CoreStoreObject {
         let species = Value.Required<String>("species")
         let nickname = Value.Optional<String>("nickname")
         let color = Transformable.Optional<UIColor>("color")
     }
     ```
     - Important: `Transformable.Required` properties are required to be stored properties. Computed properties will be ignored, including `lazy` and `weak` properties.
     */
    public final class Required<V: NSCoding & NSCopying>: AttributeProtocol {
        
        /**
         Initializes the metadata for the property.
         ```
         class Animal: CoreStoreObject {
             let color = Transformable.Optional<UIColor>("color")
         }
         ```
         - parameter keyPath: the permanent attribute name for this property.
         - parameter default: the initial value for the property when the object is first created. Defaults to the `ImportableAttributeType`'s empty value if not specified.
         - parameter isIndexed: `true` if the property should be indexed for searching, otherwise `false`. Defaults to `false` if not specified.
         - parameter isTransient: `true` if the property is transient, otherwise `false`. Defaults to `false` if not specified. The transient flag specifies whether or not a property's value is ignored when an object is saved to a persistent store. Transient properties are not saved to the persistent store, but are still managed for undo, redo, validation, and so on.
         - parameter versionHashModifier: used to mark or denote a property as being a different "version" than another even if all of the values which affect persistence are equal. (Such a difference is important in cases where the properties are unchanged but the format or content of its data are changed.)
         - parameter renamingIdentifier: used to resolve naming conflicts between models. When creating an entity mapping between entities in two managed object models, a source entity property and a destination entity property that share the same identifier indicate that a property mapping should be configured to migrate from the source to the destination. If unset, the identifier will be the property's name.
         - parameter customGetter: use this closure to make final transformations to the property's value before returning from the getter.
         - parameter self: the `CoreStoreObject`
         - parameter getValue: the original getter for the property
         - parameter customSetter: use this closure to make final transformations to the new value before assigning to the property.
         - parameter setValue: the original setter for the property
         - parameter finalNewValue: the transformed new value
         - parameter originalNewValue: the original new value
         - parameter affectedByKeyPaths: a set of key paths for properties whose values affect the value of the receiver. This is similar to `NSManagedObject.keyPathsForValuesAffectingValue(forKey:)`.
         */
        public init(
            _ keyPath: KeyPath,
            `default`: @autoclosure @escaping () -> V,
            isIndexed: Bool = false,
            isTransient: Bool = false,
            versionHashModifier: String? = nil,
            renamingIdentifier: String? = nil,
            customGetter: ((_ `self`: O, _ getValue: () -> V) -> V)? = nil,
            customSetter: ((_ `self`: O, _ setValue: (_ finalNewValue: V) -> Void, _ originalNewValue: V) -> Void)? = nil,
            affectedByKeyPaths: @autoclosure @escaping () -> Set<String> = []) {
            
            self.keyPath = keyPath
            self.defaultValue = `default`
            self.isIndexed = isIndexed
            self.isTransient = isTransient
            self.versionHashModifier = versionHashModifier
            self.renamingIdentifier = renamingIdentifier
            self.customGetter = customGetter
            self.customSetter = customSetter
            self.affectedByKeyPaths = affectedByKeyPaths
        }
        
        /**
         The property value.
         */
        public var value: V {
            
            get {
                
                CoreStore.assert(
                    self.parentObject != nil,
                    "Attempted to access values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return withExtendedLifetime(self.parentObject! as! O) { (object: O) in
                    
                    CoreStore.assert(
                        object.rawObject!.isRunningInAllowedQueue() == true,
                        "Attempted to access \(cs_typeName(O.self))'s value outside it's designated queue."
                    )
                    let customGetter = (self.customGetter ?? { $1() })
                    return customGetter(
                        object,
                        { () -> V in
                            
                            return object.rawObject!.value(forKey: self.keyPath)! as! V
                        }
                    )
                }
            }
            set {
                
                CoreStore.assert(
                    self.parentObject != nil,
                    "Attempted to access values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return withExtendedLifetime(self.parentObject! as! O) { (object: O) in
                    
                    CoreStore.assert(
                        object.rawObject!.isRunningInAllowedQueue() == true,
                        "Attempted to access \(cs_typeName(O.self))'s value outside it's designated queue."
                    )
                    CoreStore.assert(
                        object.rawObject!.isEditableInContext() == true,
                        "Attempted to update a \(cs_typeName(O.self))'s value from outside a transaction."
                    )
                    let customSetter = (self.customSetter ?? { $1($2) })
                    customSetter(
                        object,
                        { (newValue: V) -> Void in
                            
                            object.rawObject!.setValue(
                                newValue,
                                forKey: self.keyPath
                            )
                        },
                        newValue
                    )
                }
            }
        }
        
        /**
         The primitive value. Compared to `value`, `primitiveValue` bypasses all notification mechanisms. This is typically only used for setting values for transient properties.
         */
        public var primitiveValue: V {
            
            get {
                
                CoreStore.assert(
                    self.parentObject != nil,
                    "Attempted to access primitive values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return withExtendedLifetime(self.parentObject! as! O) { (object: O) in
                    
                    CoreStore.assert(
                        object.rawObject!.isRunningInAllowedQueue() == true,
                        "Attempted to access \(cs_typeName(O.self))'s primitive value outside it's designated queue."
                    )
                    return object.rawObject!.primitiveValue(forKey: self.keyPath)! as! V
                }
            }
            set {
                
                CoreStore.assert(
                    self.parentObject != nil,
                    "Attempted to access primitive values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return withExtendedLifetime(self.parentObject! as! O) { (object: O) in
                    
                    CoreStore.assert(
                        object.rawObject!.isRunningInAllowedQueue() == true,
                        "Attempted to access \(cs_typeName(O.self))'s primitive value outside it's designated queue."
                    )
                    CoreStore.assert(
                        self.isTransient || object.rawObject!.isEditableInContext() == true,
                        "Attempted to update a \(cs_typeName(O.self))'s primitive value from outside a transaction."
                    )
                    object.rawObject!.setPrimitiveValue(
                        newValue,
                        forKey: self.keyPath
                    )
                }
            }
        }
        
        
        // MARK: AttributeProtocol
        
        internal static var attributeType: NSAttributeType {
            
            return .transformableAttributeType
        }
        
        public let keyPath: KeyPath
        
        internal let isOptional = false
        internal let isIndexed: Bool
        internal let isTransient: Bool
        internal let versionHashModifier: String?
        internal let renamingIdentifier: String?
        internal let defaultValue: () -> Any?
        internal let affectedByKeyPaths: () -> Set<String>
        internal weak var parentObject: CoreStoreObject?
        
        internal private(set) lazy var getter: CoreStoreManagedObject.CustomGetter? = cs_lazy { [unowned self] in
            
            guard let customGetter = self.customGetter else {
                
                return nil
            }
            let keyPath = self.keyPath
            return { (_ id: Any) -> Any? in
                
                let rawObject = id as! CoreStoreManagedObject
                return customGetter(
                    O.cs_fromRaw(object: rawObject),
                    { rawObject.getValue(forKvcKey: keyPath) as! V }
                )
            }
        }
        
        internal private(set) lazy var setter: CoreStoreManagedObject.CustomSetter? = cs_lazy { [unowned self] in
            
            guard let customSetter = self.customSetter else {
                
                return nil
            }
            let keyPath = self.keyPath
            return { (_ id: Any, _ newValue: Any?) -> Void in
                
                let rawObject = id as! CoreStoreManagedObject
                customSetter(
                    O.cs_fromRaw(object: rawObject),
                    { (userValue: V) -> Void in
                        
                        rawObject.setValue(userValue, forKvcKey: keyPath)
                    },
                    newValue as! V
                )
            }
        }
        
        
        // MARK: Private
        
        private let customGetter: ((_ `self`: O, _ getValue: () -> V) -> V)?
        private let customSetter: ((_ `self`: O, _ setValue: (V) -> Void, _ newValue: V) -> Void)?
    }
    
    
    // MARK: - Optional
    
    /**
     The containing type for optional transformable properties. Any type that conforms to `NSCoding & NSCopying` are supported.
     ```
     class Animal: CoreStoreObject {
         let species = Value.Required<String>("species")
         let nickname = Value.Optional<String>("nickname")
         let color = Transformable.Optional<UIColor>("color")
     }
     ```
     - Important: `Transformable.Optional` properties are required to be stored properties. Computed properties will be ignored, including `lazy` and `weak` properties.
     */
    public final class Optional<V: NSCoding & NSCopying>: AttributeProtocol {
        
        /**
         Initializes the metadata for the property.
         ```
         class Animal: CoreStoreObject {
            let color = Transformable.Optional<UIColor>("color")
         }
         ```
         - parameter keyPath: the permanent attribute name for this property.
         - parameter default: the initial value for the property when the object is first created. Defaults to the `ImportableAttributeType`'s empty value if not specified.
         - parameter isIndexed: `true` if the property should be indexed for searching, otherwise `false`. Defaults to `false` if not specified.
         - parameter isTransient: `true` if the property is transient, otherwise `false`. Defaults to `false` if not specified. The transient flag specifies whether or not a property's value is ignored when an object is saved to a persistent store. Transient properties are not saved to the persistent store, but are still managed for undo, redo, validation, and so on.
         - parameter versionHashModifier: used to mark or denote a property as being a different "version" than another even if all of the values which affect persistence are equal. (Such a difference is important in cases where the properties are unchanged but the format or content of its data are changed.)
         - parameter renamingIdentifier: used to resolve naming conflicts between models. When creating an entity mapping between entities in two managed object models, a source entity property and a destination entity property that share the same identifier indicate that a property mapping should be configured to migrate from the source to the destination. If unset, the identifier will be the property's name.
         - parameter customGetter: use this closure to make final transformations to the property's value before returning from the getter.
         - parameter self: the `CoreStoreObject`
         - parameter getValue: the original getter for the property
         - parameter customSetter: use this closure to make final transformations to the new value before assigning to the property.
         - parameter setValue: the original setter for the property
         - parameter finalNewValue: the transformed new value
         - parameter originalNewValue: the original new value
         - parameter affectedByKeyPaths: a set of key paths for properties whose values affect the value of the receiver. This is similar to `NSManagedObject.keyPathsForValuesAffectingValue(forKey:)`.
         */
        public init(
            _ keyPath: KeyPath,
            `default`: @autoclosure @escaping () -> V? = nil,
            isIndexed: Bool = false,
            isTransient: Bool = false,
            versionHashModifier: String? = nil,
            renamingIdentifier: String? = nil,
            customGetter: ((_ `self`: O, _ getValue: () -> V?) -> V?)? = nil,
            customSetter: ((_ `self`: O, _ setValue: (_ finalNewValue: V?) -> Void, _ originalNewValue: V?) -> Void)? = nil,
            affectedByKeyPaths: @autoclosure @escaping () -> Set<String> = []) {
            
            self.keyPath = keyPath
            self.defaultValue = `default`
            self.isIndexed = isIndexed
            self.isTransient = isTransient
            self.versionHashModifier = versionHashModifier
            self.renamingIdentifier = renamingIdentifier
            self.customGetter = customGetter
            self.customSetter = customSetter
            self.affectedByKeyPaths = affectedByKeyPaths
        }
        
        /**
         The property value.
         */
        public var value: V? {
            
            get {
                
                CoreStore.assert(
                    self.parentObject != nil,
                    "Attempted to access values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return withExtendedLifetime(self.parentObject! as! O) { (object: O) in
                    
                    CoreStore.assert(
                        object.rawObject!.isRunningInAllowedQueue() == true,
                        "Attempted to access \(cs_typeName(O.self))'s value outside it's designated queue."
                    )
                    let customGetter = (self.customGetter ?? { $1() })
                    return customGetter(
                        object,
                        { () -> V? in
                            
                            object.rawObject!.value(forKey: self.keyPath) as! V?
                        }
                    )
                }
            }
            set {
                
                CoreStore.assert(
                    self.parentObject != nil,
                    "Attempted to access values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return withExtendedLifetime(self.parentObject! as! O) { (object: O) in
                    
                    CoreStore.assert(
                        object.rawObject!.isRunningInAllowedQueue() == true,
                        "Attempted to access \(cs_typeName(O.self))'s value outside it's designated queue."
                    )
                    CoreStore.assert(
                        object.rawObject!.isEditableInContext() == true,
                        "Attempted to update a \(cs_typeName(O.self))'s value from outside a transaction."
                    )
                    let customSetter = (self.customSetter ?? { $1($2) })
                    customSetter(
                        object,
                        { (newValue: V?) -> Void in
                            
                            object.rawObject!.setValue(
                                newValue,
                                forKey: self.keyPath
                            )
                        },
                        newValue
                    )
                }
            }
        }
        
        /**
         The primitive value. Compared to `value`, `primitiveValue` bypasses all notification mechanisms. This is typically only used for setting values for transient properties.
         */
        public var primitiveValue: V? {
            
            get {
                
                CoreStore.assert(
                    self.parentObject != nil,
                    "Attempted to access primitive values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return withExtendedLifetime(self.parentObject! as! O) { (object: O) in
                    
                    CoreStore.assert(
                        object.rawObject!.isRunningInAllowedQueue() == true,
                        "Attempted to access \(cs_typeName(O.self))'s primitive value outside it's designated queue."
                    )
                    return object.rawObject!.primitiveValue(forKey: self.keyPath) as! V?
                }
            }
            set {
                
                CoreStore.assert(
                    self.parentObject != nil,
                    "Attempted to access primitive values from a \(cs_typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return withExtendedLifetime(self.parentObject! as! O) { (object: O) in
                    
                    CoreStore.assert(
                        object.rawObject!.isRunningInAllowedQueue() == true,
                        "Attempted to access \(cs_typeName(O.self))'s primitive value outside it's designated queue."
                    )
                    CoreStore.assert(
                        self.isTransient || object.rawObject!.isEditableInContext() == true,
                        "Attempted to update a \(cs_typeName(O.self))'s primitive value from outside a transaction."
                    )
                    object.rawObject!.setPrimitiveValue(
                        newValue,
                        forKey: self.keyPath
                    )
                }
            }
        }
        
        
        // MARK: AttributeProtocol
        
        internal static var attributeType: NSAttributeType {
            
            return .transformableAttributeType
        }
        
        public let keyPath: KeyPath
        
        internal let isOptional = true
        internal let isIndexed: Bool
        internal let isTransient: Bool
        internal let versionHashModifier: String?
        internal let renamingIdentifier: String?
        internal let defaultValue: () -> Any?
        internal let affectedByKeyPaths: () -> Set<String>
        internal weak var parentObject: CoreStoreObject?
        
        internal private(set) lazy var getter: CoreStoreManagedObject.CustomGetter? = cs_lazy { [unowned self] in
            
            guard let customGetter = self.customGetter else {
                
                return nil
            }
            let keyPath = self.keyPath
            return { (_ id: Any) -> Any? in
                
                let rawObject = id as! CoreStoreManagedObject
                return customGetter(
                    O.cs_fromRaw(object: rawObject),
                    { rawObject.getValue(forKvcKey: keyPath) as! V? }
                )
            }
        }
        
        internal private(set) lazy var setter: CoreStoreManagedObject.CustomSetter? = cs_lazy { [unowned self] in
            
            let keyPath = self.keyPath
            guard let customSetter = self.customSetter else {
                
                guard let _ = self.customGetter else {
                    
                    return nil
                }
                return { (_ id: Any, _ newValue: Any?) -> Void in
                    
                    let rawObject = id as! CoreStoreManagedObject
                    rawObject.setValue(newValue, forKvcKey: keyPath)
                }
            }
            return { (_ id: Any, _ newValue: Any?) -> Void in
                
                let rawObject = id as! CoreStoreManagedObject
                customSetter(
                    O.cs_fromRaw(object: rawObject),
                    { (userValue: V?) -> Void in
                        
                        rawObject.setValue(userValue, forKvcKey: keyPath)
                    },
                    newValue as! V?
                )
            }
        }
        
        
        // MARK: Private
        
        private let customGetter: ((_ `self`: O, _ getValue: () -> V?) -> V?)?
        private let customSetter: ((_ `self`: O, _ setValue: (V?) -> Void, _ newValue: V?) -> Void)?
    }
}


// MARK: - Operations

infix operator .= : AssignmentPrecedence
infix operator .== : ComparisonPrecedence

extension ValueContainer.Required {
    
    /**
     Assigns a value to the property. The operation
     ```
     animal.species .= "Swift"
     ```
     is equivalent to
     ```
     animal.species.value = "Swift"
     ```
     */
    public static func .= (_ property: ValueContainer<O>.Required<V>, _ newValue: V) {
        
        property.value = newValue
    }
    
    /**
     Assigns a value from another property. The operation
     ```
     animal.species .= anotherAnimal.species
     ```
     is equivalent to
     ```
     animal.species.value = anotherAnimal.species.value
     ```
     */
    public static func .= <O2: CoreStoreObject>(_ property: ValueContainer<O>.Required<V>, _ property2: ValueContainer<O2>.Required<V>) {
        
        property.value = property2.value
    }
    
    /**
     Compares equality between a property's value and another value
     ```
     if animal.species .== "Swift" { ... }
     ```
     is equivalent to
     ```
     if animal.species.value == "Swift" { ... }
     ```
     */
    public static func .== (_ property: ValueContainer<O>.Required<V>, _ value: V?) -> Bool {
        
        return property.value == value
    }
    
    /**
     Compares equality between a value and a property's value
     ```
     if "Swift" .== animal.species { ... }
     ```
     is equivalent to
     ```
     if "Swift" == animal.species.value { ... }
     ```
     */
    public static func .== (_ value: V?, _ property: ValueContainer<O>.Required<V>) -> Bool {
        
        return value == property.value
    }
    
    /**
     Compares equality between a property's value and another property's value
     ```
     if animal.species .== anotherAnimal.species { ... }
     ```
     is equivalent to
     ```
     if animal.species.value == anotherAnimal.species.value { ... }
     ```
     */
    public static func .== (_ property: ValueContainer<O>.Required<V>, _ property2: ValueContainer<O>.Required<V>) -> Bool {
        
        return property.value == property2.value
    }
    
    /**
     Compares equality between a property's value and another property's value
     ```
     if animal.species .== anotherAnimal.species { ... }
     ```
     is equivalent to
     ```
     if animal.species.value == anotherAnimal.species.value { ... }
     ```
     */
    public static func .== (_ property: ValueContainer<O>.Required<V>, _ property2: ValueContainer<O>.Optional<V>) -> Bool {
        
        return property.value == property2.value
    }
}

extension ValueContainer.Optional {
    
    /**
     Assigns an optional value to the property. The operation
     ```
     animal.nickname .= "Taylor"
     ```
     is equivalent to
     ```
     animal.nickname.value = "Taylor"
     ```
     */
    public static func .= (_ property: ValueContainer<O>.Optional<V>, _ newValue: V?) {
        
        property.value = newValue
    }
    
    /**
     Assigns an optional value from another property. The operation
     ```
     animal.nickname .= anotherAnimal.nickname
     ```
     is equivalent to
     ```
     animal.nickname.value = anotherAnimal.nickname.value
     ```
     */
    public static func .= <O2: CoreStoreObject>(_ property: ValueContainer<O>.Optional<V>, _ property2: ValueContainer<O2>.Optional<V>) {
        
        property.value = property2.value
    }
    
    /**
     Assigns a value from another property. The operation
     ```
     animal.nickname .= anotherAnimal.species
     ```
     is equivalent to
     ```
     animal.nickname.value = anotherAnimal.species.value
     ```
     */
    public static func .= <O2: CoreStoreObject>(_ property: ValueContainer<O>.Optional<V>, _ property2: ValueContainer<O2>.Required<V>) {
        
        property.value = property2.value
    }
    
    /**
     Compares equality between a property's value and another value
     ```
     if animal.species .== "Swift" { ... }
     ```
     is equivalent to
     ```
     if animal.species.value == "Swift" { ... }
     ```
     */
    public static func .== (_ property: ValueContainer<O>.Optional<V>, _ value: V?) -> Bool {
        
        return property.value == value
    }
    
    /**
     Compares equality between a property's value and another property's value
     ```
     if "Swift" .== animal.species { ... }
     ```
     is equivalent to
     ```
     if "Swift" == animal.species.value { ... }
     ```
     */
    public static func .== (_ value: V?, _ property: ValueContainer<O>.Optional<V>) -> Bool {
        
        return value == property.value
    }
    
    /**
     Compares equality between a property's value and another property's value
     ```
     if animal.species .== anotherAnimal.species { ... }
     ```
     is equivalent to
     ```
     if animal.species.value == anotherAnimal.species.value { ... }
     ```
     */
    public static func .== (_ property: ValueContainer<O>.Optional<V>, _ property2: ValueContainer<O>.Optional<V>) -> Bool {
        
        return property.value == property2.value
    }
    
    /**
     Compares equality between a property's value and another property's value
     ```
     if animal.species .== anotherAnimal.species { ... }
     ```
     is equivalent to
     ```
     if animal.species.value == anotherAnimal.species.value { ... }
     ```
     */
    public static func .== (_ property: ValueContainer<O>.Optional<V>, _ property2: ValueContainer<O>.Required<V>) -> Bool {
        
        return property.value == property2.value
    }
}

extension TransformableContainer.Required {
    
    /**
     Assigns a transformable value to the property. The operation
     ```
     animal.color .= UIColor.red
     ```
     is equivalent to
     ```
     animal.color.value = UIColor.red
     ```
     */
    public static func .= (_ property: TransformableContainer<O>.Required<V>, _ newValue: V) {
        
        property.value = newValue
    }
    
    /**
     Assigns a transformable value from another property. The operation
     ```
     animal.nickname .= anotherAnimal.species
     ```
     is equivalent to
     ```
     animal.nickname.value = anotherAnimal.species.value
     ```
     */
    public static func .= <O2: CoreStoreObject>(_ property: TransformableContainer<O>.Required<V>, _ property2: TransformableContainer<O2>.Required<V>) {
        
        property.value = property2.value
    }
}

extension TransformableContainer.Optional {
    
    /**
     Assigns an optional transformable value to the property. The operation
     ```
     animal.color .= UIColor.red
     ```
     is equivalent to
     ```
     animal.color.value = UIColor.red
     ```
     */
    public static func .= (_ property: TransformableContainer<O>.Optional<V>, _ newValue: V?) {
        
        property.value = newValue
    }
    
    /**
     Assigns an optional transformable value from another property. The operation
     ```
     animal.color .= anotherAnimal.color
     ```
     is equivalent to
     ```
     animal.color.value = anotherAnimal.color.value
     ```
     */
    public static func .= <O2: CoreStoreObject>(_ property: TransformableContainer<O>.Optional<V>, _ property2: TransformableContainer<O2>.Optional<V>) {
        
        property.value = property2.value
    }
    
    /**
     Assigns a transformable value from another property. The operation
     ```
     animal.color .= anotherAnimal.color
     ```
     is equivalent to
     ```
     animal.color.value = anotherAnimal.color.value
     ```
     */
    public static func .= <O2: CoreStoreObject>(_ property: TransformableContainer<O>.Optional<V>, _ property2: TransformableContainer<O2>.Required<V>) {
        
        property.value = property2.value
    }
}


// MARK: - AttributeProtocol

internal protocol AttributeProtocol: class {
    
    static var attributeType: NSAttributeType { get }
    
    var keyPath: KeyPath { get }
    var isOptional: Bool { get }
    var isIndexed: Bool { get }
    var isTransient: Bool { get }
    var versionHashModifier: String? { get }
    var renamingIdentifier: String? { get }
    var defaultValue: () -> Any? { get }
    var affectedByKeyPaths: () -> Set<String> { get }
    weak var parentObject: CoreStoreObject? { get set }
    var getter: CoreStoreManagedObject.CustomGetter? { get }
    var setter: CoreStoreManagedObject.CustomSetter? { get }
}
