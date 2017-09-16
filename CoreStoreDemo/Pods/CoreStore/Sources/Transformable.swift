//
//  Transformable.swift
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
             let species = Value.Required<String>("species")
             let color = Transformable.Required<UIColor>(
                 "color",
                 initial: UIColor.clear,
                 isTransient: true,
                 customGetter: Animal.getColor(_:)
             )
         }

         private static func getColor(_ partialObject: PartialObject<Animal>) -> UIColor {
             let cachedColor = partialObject.primitiveValue(for: { $0.color })
             if cachedColor != UIColor.clear {

                 return cachedColor
             }
             let color: UIColor
             switch partialObject.value(for: { $0.species }) {

             case "Swift": color = UIColor.orange
             case "Bulbasaur": color = UIColor.green
             default: color = UIColor.black
             }
             partialObject.setPrimitiveValue(color, for: { $0.color })
             return color
         }
         ```
         - parameter keyPath: the permanent attribute name for this property.
         - parameter initial: the initial value for the property when the object is first created. Defaults to the `ImportableAttributeType`'s empty value if not specified.
         - parameter isIndexed: `true` if the property should be indexed for searching, otherwise `false`. Defaults to `false` if not specified.
         - parameter isTransient: `true` if the property is transient, otherwise `false`. Defaults to `false` if not specified. The transient flag specifies whether or not a property's value is ignored when an object is saved to a persistent store. Transient properties are not saved to the persistent store, but are still managed for undo, redo, validation, and so on.
         - parameter versionHashModifier: used to mark or denote a property as being a different "version" than another even if all of the values which affect persistence are equal. (Such a difference is important in cases where the properties are unchanged but the format or content of its data are changed.)
         - parameter renamingIdentifier: used to resolve naming conflicts between models. When creating an entity mapping between entities in two managed object models, a source entity property and a destination entity property that share the same identifier indicate that a property mapping should be configured to migrate from the source to the destination. If unset, the identifier will be the property's name.
         - parameter customGetter: use this closure as an "override" for the default property getter. The closure receives a `PartialObject<O>`, which acts as a fast, type-safe KVC interface for `CoreStoreObject`. The reason a `CoreStoreObject` instance is not passed directly is because the Core Data runtime is not aware of `CoreStoreObject` properties' static typing, and so loading those info everytime KVO invokes this accessor method incurs a cumulative performance hit (especially in KVO-heavy operations such as `ListMonitor` observing.) When accessing the property value from `PartialObject<O>`, make sure to use `PartialObject<O>.primitiveValue(for:)` instead of `PartialObject<O>.value(for:)`, which would unintentionally execute the same closure again recursively.
         - parameter customSetter: use this closure as an "override" for the default property setter. The closure receives a `PartialObject<O>`, which acts as a fast, type-safe KVC interface for `CoreStoreObject`. The reason a `CoreStoreObject` instance is not passed directly is because the Core Data runtime is not aware of `CoreStoreObject` properties' static typing, and so loading those info everytime KVO invokes this accessor method incurs a cumulative performance hit (especially in KVO-heavy operations such as `ListMonitor` observing.) When accessing the property value from `PartialObject<O>`, make sure to use `PartialObject<O>.setPrimitiveValue(_:for:)` instead of `PartialObject<O>.setValue(_:for:)`, which would unintentionally execute the same closure again recursively.
         - parameter affectedByKeyPaths: a set of key paths for properties whose values affect the value of the receiver. This is similar to `NSManagedObject.keyPathsForValuesAffectingValue(forKey:)`.
         */
        public init(
            _ keyPath: KeyPath,
            initial: @autoclosure @escaping () -> V,
            isIndexed: Bool = false,
            isTransient: Bool = false,
            versionHashModifier: @autoclosure @escaping () -> String? = nil,
            renamingIdentifier: @autoclosure @escaping () -> String? = nil,
            customGetter: ((_ partialObject: PartialObject<O>) -> V)? = nil,
            customSetter: ((_ partialObject: PartialObject<O>, _ newValue: V) -> Void)? = nil,
            affectedByKeyPaths: @autoclosure @escaping () -> Set<String> = []) {

            self.keyPath = keyPath
            self.defaultValue = initial
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
                    if let customGetter = self.customGetter {

                        return customGetter(PartialObject<O>(object.rawObject!))
                    }
                    return object.rawObject!.value(forKey: self.keyPath)! as! V
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
                    if let customSetter = self.customSetter {

                        return customSetter(PartialObject<O>(object.rawObject!), newValue)
                    }
                    object.rawObject!.setValue(
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
        internal let versionHashModifier: () -> String?
        internal let renamingIdentifier: () -> String?
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
                rawObject.willAccessValue(forKey: keyPath)
                defer {

                    rawObject.didAccessValue(forKey: keyPath)
                }
                let value = customGetter(PartialObject<O>(rawObject))
                return value
            }
        }

        internal private(set) lazy var setter: CoreStoreManagedObject.CustomSetter? = cs_lazy { [unowned self] in

            guard let customSetter = self.customSetter else {

                return nil
            }
            let keyPath = self.keyPath
            return { (_ id: Any, _ newValue: Any?) -> Void in

                let rawObject = id as! CoreStoreManagedObject
                rawObject.willChangeValue(forKey: keyPath)
                defer {

                    rawObject.didChangeValue(forKey: keyPath)
                }
                customSetter(
                    PartialObject<O>(rawObject),
                    newValue as! V
                )
            }
        }


        // MARK: Private

        private let customGetter: ((_ partialObject: PartialObject<O>) -> V)?
        private let customSetter: ((_ partialObject: PartialObject<O>, _ newValue: V) -> Void)?


        // MARK: Deprecated

        @available(*, deprecated: 3.1, renamed: "init(_:initial:isIndexed:isTransient:versionHashModifier:renamingIdentifier:customGetter:customSetter:affectedByKeyPaths:)")
        public convenience init(
            _ keyPath: KeyPath,
            `default`: @autoclosure @escaping () -> V,
            isIndexed: Bool = false,
            isTransient: Bool = false,
            versionHashModifier: @autoclosure @escaping () -> String? = nil,
            renamingIdentifier: @autoclosure @escaping () -> String? = nil,
            customGetter: ((_ partialObject: PartialObject<O>) -> V)? = nil,
            customSetter: ((_ partialObject: PartialObject<O>, _ newValue: V) -> Void)? = nil,
            affectedByKeyPaths: @autoclosure @escaping () -> Set<String> = []) {

            self.init(
                keyPath,
                initial: `default`,
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
             let species = Value.Required<String>("species")
             let color = Transformable.Optional<UIColor>(
                 "color",
                 isTransient: true,
                 customGetter: Animal.getColor(_:)
             )
         }

         private static func getColor(_ partialObject: PartialObject<Animal>) -> UIColor? {
             if let cachedColor = partialObject.primitiveValue(for: { $0.color }) {
                 return cachedColor
             }
             let color: UIColor?
             switch partialObject.value(for: { $0.species }) {

             case "Swift": color = UIColor.orange
             case "Bulbasaur": color = UIColor.green
             default: return nil
             }
             partialObject.setPrimitiveValue(color, for: { $0.color })
             return color
         }
         ```
         - parameter keyPath: the permanent attribute name for this property.
         - parameter initial: the initial value for the property when the object is first created. Defaults to the `ImportableAttributeType`'s empty value if not specified.
         - parameter isIndexed: `true` if the property should be indexed for searching, otherwise `false`. Defaults to `false` if not specified.
         - parameter isTransient: `true` if the property is transient, otherwise `false`. Defaults to `false` if not specified. The transient flag specifies whether or not a property's value is ignored when an object is saved to a persistent store. Transient properties are not saved to the persistent store, but are still managed for undo, redo, validation, and so on.
         - parameter versionHashModifier: used to mark or denote a property as being a different "version" than another even if all of the values which affect persistence are equal. (Such a difference is important in cases where the properties are unchanged but the format or content of its data are changed.)
         - parameter renamingIdentifier: used to resolve naming conflicts between models. When creating an entity mapping between entities in two managed object models, a source entity property and a destination entity property that share the same identifier indicate that a property mapping should be configured to migrate from the source to the destination. If unset, the identifier will be the property's name.
         - parameter customGetter: use this closure as an "override" for the default property getter. The closure receives a `PartialObject<O>`, which acts as a fast, type-safe KVC interface for `CoreStoreObject`. The reason a `CoreStoreObject` instance is not passed directly is because the Core Data runtime is not aware of `CoreStoreObject` properties' static typing, and so loading those info everytime KVO invokes this accessor method incurs a cumulative performance hit (especially in KVO-heavy operations such as `ListMonitor` observing.) When accessing the property value from `PartialObject<O>`, make sure to use `PartialObject<O>.primitiveValue(for:)` instead of `PartialObject<O>.value(for:)`, which would unintentionally execute the same closure again recursively.
         - parameter customSetter: use this closure as an "override" for the default property setter. The closure receives a `PartialObject<O>`, which acts as a fast, type-safe KVC interface for `CoreStoreObject`. The reason a `CoreStoreObject` instance is not passed directly is because the Core Data runtime is not aware of `CoreStoreObject` properties' static typing, and so loading those info everytime KVO invokes this accessor method incurs a cumulative performance hit (especially in KVO-heavy operations such as `ListMonitor` observing.) When accessing the property value from `PartialObject<O>`, make sure to use `PartialObject<O>.setPrimitiveValue(_:for:)` instead of `PartialObject<O>.setValue(_:for:)`, which would unintentionally execute the same closure again recursively.
         - parameter affectedByKeyPaths: a set of key paths for properties whose values affect the value of the receiver. This is similar to `NSManagedObject.keyPathsForValuesAffectingValue(forKey:)`.
         */
        public init(
            _ keyPath: KeyPath,
            initial: @autoclosure @escaping () -> V? = nil,
            isIndexed: Bool = false,
            isTransient: Bool = false,
            versionHashModifier: @autoclosure @escaping () -> String? = nil,
            renamingIdentifier: @autoclosure @escaping () -> String? = nil,
            customGetter: ((_ partialObject: PartialObject<O>) -> V?)? = nil,
            customSetter: ((_ partialObject: PartialObject<O>, _ newValue: V?) -> Void)? = nil,
            affectedByKeyPaths: @autoclosure @escaping () -> Set<String> = []) {

            self.keyPath = keyPath
            self.defaultValue = initial
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
                    if let customGetter = self.customGetter {

                        return customGetter(PartialObject<O>(object.rawObject!))
                    }
                    return object.rawObject!.value(forKey: self.keyPath) as! V?
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
                    if let customSetter = self.customSetter {

                        return customSetter(PartialObject<O>(object.rawObject!), newValue)
                    }
                    object.rawObject!.setValue(
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
        internal let versionHashModifier: () -> String?
        internal let renamingIdentifier: () -> String?
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
                rawObject.willAccessValue(forKey: keyPath)
                defer {

                    rawObject.didAccessValue(forKey: keyPath)
                }
                let value = customGetter(PartialObject<O>(rawObject))
                return value
            }
        }

        internal private(set) lazy var setter: CoreStoreManagedObject.CustomSetter? = cs_lazy { [unowned self] in

            guard let customSetter = self.customSetter else {

                return nil
            }
            let keyPath = self.keyPath
            return { (_ id: Any, _ newValue: Any?) -> Void in

                let rawObject = id as! CoreStoreManagedObject
                rawObject.willChangeValue(forKey: keyPath)
                defer {

                    rawObject.didChangeValue(forKey: keyPath)
                }
                customSetter(
                    PartialObject<O>(rawObject),
                    newValue as! V?
                )
            }
        }


        // MARK: Private

        private let customGetter: ((_ partialObject: PartialObject<O>) -> V?)?
        private let customSetter: ((_ partialObject: PartialObject<O>, _ newValue: V?) -> Void)?


        // MARK: Deprecated

        @available(*, deprecated: 3.1, renamed: "init(_:initial:isIndexed:isTransient:versionHashModifier:renamingIdentifier:customGetter:customSetter:affectedByKeyPaths:)")
        public convenience init(
            _ keyPath: KeyPath,
            `default`: @autoclosure @escaping () -> V?,
            isIndexed: Bool = false,
            isTransient: Bool = false,
            versionHashModifier: @autoclosure @escaping () -> String? = nil,
            renamingIdentifier: @autoclosure @escaping () -> String? = nil,
            customGetter: ((_ partialObject: PartialObject<O>) -> V?)? = nil,
            customSetter: ((_ partialObject: PartialObject<O>, _ newValue: V?) -> Void)? = nil,
            affectedByKeyPaths: @autoclosure @escaping () -> Set<String> = []) {

            self.init(
                keyPath,
                initial: `default`,
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
}


// MARK: - Operations

infix operator .= : AssignmentPrecedence
infix operator .== : ComparisonPrecedence

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
    public static func .= <O2>(_ property: TransformableContainer<O>.Required<V>, _ property2: TransformableContainer<O2>.Required<V>) {
        
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
    public static func .= <O2>(_ property: TransformableContainer<O>.Optional<V>, _ property2: TransformableContainer<O2>.Optional<V>) {
        
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
    public static func .= <O2>(_ property: TransformableContainer<O>.Optional<V>, _ property2: TransformableContainer<O2>.Required<V>) {
        
        property.value = property2.value
    }
}
