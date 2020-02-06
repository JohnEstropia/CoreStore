//
//  Field.Virtual.swift
//  CoreStore
//
//  Copyright © 2020 John Rommel Estropia
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


// MARK: - FieldContainer

extension FieldContainer {

    // MARK: - Virtual

    /**
     The containing type for computed property values. Any type that conforms to `FieldStorableType` are supported.
     ```
     class Animal: CoreStoreObject {
         @Field.Stored("species")
         var species = ""

         @Field.Virtual("pluralName", customGetter: Animal.pluralName(_:))
         var pluralName: String = ""

         @Field.PlistCoded("color")
         var color: UIColor?
     }
     ```
     - Important: `Field` properties are required to be used as `@propertyWrapper`s. Any other declaration not using the `@Field.Virtual(...) var` syntax will be ignored.
     */
    @propertyWrapper
    public struct Virtual<V>: AttributeKeyPathStringConvertible, FieldAttributeProtocol {

        /**
         Initializes the metadata for the property.
         ```
         class Person: CoreStoreObject {
             @Field.Stored("title")
             var title: String = "Mr."

             @Field.Stored("name")
             var name: String = ""

             @Field.Virtual("displayName", customGetter: Person.getName(_:))
             var displayName: String = ""

             private static func getName(_ partialObject: PartialObject<Person>) -> String {
                 let cachedDisplayName = partialObject.primitiveValue(for: \.$displayName)
                 if !cachedDisplayName.isEmpty {
                     return cachedDisplayName
                 }
                 let title = partialObject.value(for: \.$title)
                 let name = partialObject.value(for: \.$name)
                 let displayName = "\(title) \(name)"
                 partialObject.setPrimitiveValue(displayName, for: { $0.displayName })
                 return displayName
             }
         }
         ```
         - parameter keyPath: the permanent attribute name for this property.
         - parameter customGetter: use this closure as an "override" for the default property getter. The closure receives a `PartialObject<O>`, which acts as a fast, type-safe KVC interface for `CoreStoreObject`. The reason a `CoreStoreObject` instance is not passed directly is because the Core Data runtime is not aware of `CoreStoreObject` properties' static typing, and so loading those info everytime KVO invokes this accessor method incurs a cumulative performance hit (especially in KVO-heavy operations such as `ListMonitor` observing.) When accessing the property value from `PartialObject<O>`, make sure to use `PartialObject<O>.primitiveValue(for:)` instead of `PartialObject<O>.value(for:)`, which would unintentionally execute the same closure again recursively.
         - parameter customSetter: use this closure as an "override" for the default property setter. The closure receives a `PartialObject<O>`, which acts as a fast, type-safe KVC interface for `CoreStoreObject`. The reason a `CoreStoreObject` instance is not passed directly is because the Core Data runtime is not aware of `CoreStoreObject` properties' static typing, and so loading those info everytime KVO invokes this accessor method incurs a cumulative performance hit (especially in KVO-heavy operations such as `ListMonitor` observing.) When accessing the property value from `PartialObject<O>`, make sure to use `PartialObject<O>.setPrimitiveValue(_:for:)` instead of `PartialObject<O>.setValue(_:for:)`, which would unintentionally execute the same closure again recursively.
         - parameter affectedByKeyPaths: a set of key paths for properties whose values affect the value of the receiver. This is similar to `NSManagedObject.keyPathsForValuesAffectingValue(forKey:)`.
         */
        public init(
            _ keyPath: KeyPathString,
            customGetter: @escaping (_ partialObject: PartialObject<O>) -> V,
            customSetter: ((_ partialObject: PartialObject<O>, _ newValue: V) -> Void)? = nil,
            affectedByKeyPaths: @autoclosure @escaping () -> Set<KeyPathString> = []) {

            self.init(
                keyPath: keyPath,
                isOptional: false,
                customGetter: customGetter,
                customSetter: customSetter,
                affectedByKeyPaths: affectedByKeyPaths
            )
        }

        /**
         Overload for compiler error message only
         */
        @available(*, unavailable, message: "Field.Computed properties are not allowed to have initial values, including `nil`.")
        public init(
            wrappedValue initial: @autoclosure @escaping () -> V,
            _ keyPath: KeyPathString,
            versionHashModifier: @autoclosure @escaping () -> String? = nil,
            customGetter: ((_ partialObject: PartialObject<O>) -> V)? = nil,
            customSetter: ((_ partialObject: PartialObject<O>, _ newValue: V) -> Void)? = nil,
            affectedByKeyPaths: @autoclosure @escaping () -> Set<KeyPathString> = []) {

            fatalError()
        }


        // MARK: @propertyWrapper

        @available(*, unavailable)
        public var wrappedValue: V {

            get { fatalError() }
            set { fatalError() }
        }

        public var projectedValue: Self {

            return self
        }

        public static subscript(
            _enclosingInstance instance: O,
            wrapped wrappedKeyPath: ReferenceWritableKeyPath<O, V>,
            storage storageKeyPath: ReferenceWritableKeyPath<O, Self>
        ) -> V {

            get {

                Internals.assert(
                    instance.rawObject != nil,
                    "Attempted to access values from a \(Internals.typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return self.read(field: instance[keyPath: storageKeyPath], for: instance.rawObject!) as! V
            }
            set {

                Internals.assert(
                    instance.rawObject != nil,
                    "Attempted to access values from a \(Internals.typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return self.modify(field: instance[keyPath: storageKeyPath], for: instance.rawObject!, newValue: newValue)
            }
        }


        // MARK: AnyKeyPathStringConvertible

        public var cs_keyPathString: String {

            return self.keyPath
        }


        // MARK: KeyPathStringConvertible

        public typealias ObjectType = O
        public typealias DestinationValueType = V


        // MARK: AttributeKeyPathStringConvertible

        public typealias ReturnValueType = DestinationValueType


        // MARK: PropertyProtocol

        internal let keyPath: KeyPathString


        // MARK: FieldProtocol

        internal static func read(field: FieldProtocol, for rawObject: CoreStoreManagedObject) -> Any? {

            Internals.assert(
                rawObject.isRunningInAllowedQueue() == true,
                "Attempted to access \(Internals.typeName(O.self))'s value outside it's designated queue."
            )
            let field = field as! Self
            if let customGetter = field.customGetter {

                return customGetter(PartialObject<O>(rawObject))
            }
            let keyPath = field.keyPath
            switch rawObject.value(forKey: keyPath) {

            case let rawValue as V:
                return rawValue

            default:
                return nil
            }
        }

        internal static func modify(field: FieldProtocol, for rawObject: CoreStoreManagedObject, newValue: Any?) {

            Internals.assert(
                rawObject.isRunningInAllowedQueue() == true,
                "Attempted to access \(Internals.typeName(O.self))'s value outside it's designated queue."
            )
            Internals.assert(
                rawObject.isEditableInContext() == true,
                "Attempted to update a \(Internals.typeName(O.self))'s value from outside a transaction."
            )
            let newValue = newValue as! V
            let field = field as! Self
            let keyPath = field.keyPath
            if let customSetter = field.customSetter {

                return customSetter(PartialObject<O>(rawObject), newValue)
            }
            return rawObject.setValue(newValue, forKey: keyPath)
        }


        // MARK: FieldAttributeProtocol

        internal let entityDescriptionValues: () -> FieldAttributeProtocol.EntityDescriptionValues

        internal var getter: CoreStoreManagedObject.CustomGetter? {

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
                return customGetter(PartialObject<O>(rawObject))
            }
        }

        internal var setter: CoreStoreManagedObject.CustomSetter? {

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
                return customSetter(PartialObject<O>(rawObject), newValue as! V)
            }
        }


        // MARK: FilePrivate

        fileprivate init(
            keyPath: KeyPathString,
            isOptional: Bool,
            customGetter: ((_ partialObject: PartialObject<O>) -> V)?,
            customSetter: ((_ partialObject: PartialObject<O>, _ newValue: V) -> Void)? ,
            affectedByKeyPaths: @escaping () -> Set<KeyPathString>) {

            self.keyPath = keyPath
            self.entityDescriptionValues = {
                (
                    attributeType: .undefinedAttributeType,
                    isOptional: isOptional,
                    isTransient: true,
                    allowsExternalBinaryDataStorage: false,
                    versionHashModifier: nil,
                    renamingIdentifier: nil,
                    valueTransformer: nil,
                    affectedByKeyPaths: affectedByKeyPaths(),
                    defaultValue: nil
                )
            }
            self.customGetter = customGetter
            self.customSetter = customSetter
        }


        // MARK: Private

        private let customGetter: ((_ partialObject: PartialObject<O>) -> V)?
        private let customSetter: ((_ partialObject: PartialObject<O>, _ newValue: V) -> Void)?
    }
}


extension FieldContainer.Virtual where V: FieldOptionalType {

    public init(
        _ keyPath: KeyPathString,
        customGetter: ((_ partialObject: PartialObject<O>) -> V)? = nil,
        customSetter: ((_ partialObject: PartialObject<O>, _ newValue: V) -> Void)? = nil,
        affectedByKeyPaths: @autoclosure @escaping () -> Set<KeyPathString> = []) {

        self.init(
            keyPath: keyPath,
            isOptional: false,
            customGetter: customGetter,
            customSetter: customSetter,
            affectedByKeyPaths: affectedByKeyPaths
        )
    }
}
