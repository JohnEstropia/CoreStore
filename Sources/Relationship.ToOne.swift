//
//  Relationship.ToOne.swift
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


// MARK: - RelationshipContainer

extension RelationshipContainer {

    // MARK: - ToOne

    /**
     The containing type for to-one relationships. Any `CoreStoreObject` subclass can be a destination type. Inverse relationships should be declared from the destination type as well, using the `inverse:` argument for the relationship.
     ```
     class Dog: CoreStoreObject {
         let master = Relationship.ToOne<Person>("master")
     }
     class Person: CoreStoreObject {
         let pets = Relationship.ToManyUnordered<Dog>("pets", inverse: { $0.master })
     }
     ```
     - Important: `Relationship.ToOne` properties are required to be stored properties. Computed properties will be ignored, including `lazy` and `weak` properties.
     */
    public final class ToOne<D: CoreStoreObject>: RelationshipKeyPathStringConvertible, RelationshipProtocol {

        /**
         Initializes the metadata for the relationship. All relationships require an "inverse", so updates to to this object's relationship are also reflected on its destination object. Make sure to declare this relationship's inverse relationship on its destination object. Due to Swift's compiler limitation, only one of the relationship and its inverse can declare an `inverse:` argument.
         ```
         class Dog: CoreStoreObject {
             let master = Relationship.ToOne<Person>("master")
         }
         class Person: CoreStoreObject {
             let pets = Relationship.ToManyUnordered<Dog>("pets", inverse: { $0.master })
         }
         ```
         - parameter keyPath: the permanent name for this relationship.
         - parameter deleteRule: defines what happens to relationship when an object is deleted. Valid values are `.nullify`, `.cascade`, and `.delete`. Defaults to `.nullify`.
         - parameter versionHashModifier: used to mark or denote a relationship as being a different "version" than another even if all of the values which affect persistence are equal. (Such a difference is important in cases where the properties are unchanged but the format or content of its data are changed.)
         - parameter renamingIdentifier: used to resolve naming conflicts between models. When creating an entity mapping between entities in two managed object models, a source entity property and a destination entity property that share the same identifier indicate that a property mapping should be configured to migrate from the source to the destination. If unset, the identifier will be the property's name.
         - parameter affectedByKeyPaths: a set of key paths for properties whose values affect the value of the receiver. This is similar to `NSManagedObject.keyPathsForValuesAffectingValue(forKey:)`.
         */
        public convenience init(
            _ keyPath: KeyPathString,
            deleteRule: DeleteRule = .nullify,
            versionHashModifier: @autoclosure @escaping () -> String? = nil,
            renamingIdentifier: @autoclosure @escaping () -> String? = nil,
            affectedByKeyPaths: @autoclosure @escaping () -> Set<String> = []) {

            self.init(
                keyPath: keyPath,
                inverseKeyPath: { nil },
                deleteRule: deleteRule,
                versionHashModifier: versionHashModifier(),
                renamingIdentifier: renamingIdentifier(),
                affectedByKeyPaths: affectedByKeyPaths()
            )
        }

        /**
         Initializes the metadata for the relationship. All relationships require an "inverse", so updates to to this object's relationship are also reflected on its destination object. Make sure to declare this relationship's inverse relationship on its destination object. Due to Swift's compiler limitation, only one of the relationship and its inverse can declare an `inverse:` argument.
         ```
         class Dog: CoreStoreObject {
             let master = Relationship.ToOne<Person>("master")
         }
         class Person: CoreStoreObject {
             let pets = Relationship.ToManyUnordered<Dog>("pets", inverse: { $0.master })
         }
         ```
         - parameter keyPath: the permanent name for this relationship.
         - parameter inverse: the inverse relationship that is declared for the destination object. All relationships require an "inverse", so updates to to this object's relationship are also reflected on its destination object.
         - parameter deleteRule: defines what happens to relationship when an object is deleted. Valid values are `.nullify`, `.cascade`, and `.delete`. Defaults to `.nullify`.
         - parameter versionHashModifier: used to mark or denote a relationship as being a different "version" than another even if all of the values which affect persistence are equal. (Such a difference is important in cases where the properties are unchanged but the format or content of its data are changed.)
         - parameter renamingIdentifier: used to resolve naming conflicts between models. When creating an entity mapping between entities in two managed object models, a source entity property and a destination entity property that share the same identifier indicate that a property mapping should be configured to migrate from the source to the destination. If unset, the identifier will be the property's name.
         - parameter affectedByKeyPaths: a set of key paths for properties whose values affect the value of the receiver. This is similar to `NSManagedObject.keyPathsForValuesAffectingValue(forKey:)`.
         */
        public convenience init(
            _ keyPath: KeyPathString,
            inverse: @escaping (D) -> RelationshipContainer<D>.ToOne<O>,
            deleteRule: DeleteRule = .nullify,
            versionHashModifier: @autoclosure @escaping () -> String? = nil,
            renamingIdentifier: @autoclosure @escaping () -> String? = nil,
            affectedByKeyPaths: @autoclosure @escaping () -> Set<String> = []) {

            self.init(
                keyPath: keyPath,
                inverseKeyPath: { inverse(D.meta).keyPath },
                deleteRule: deleteRule,
                versionHashModifier: versionHashModifier(),
                renamingIdentifier: renamingIdentifier(),
                affectedByKeyPaths: affectedByKeyPaths()
            )
        }

        /**
         Initializes the metadata for the relationship. All relationships require an "inverse", so updates to to this object's relationship are also reflected on its destination object. Make sure to declare this relationship's inverse relationship on its destination object. Due to Swift's compiler limitation, only one of the relationship and its inverse can declare an `inverse:` argument.
         ```
         class Dog: CoreStoreObject {
             let master = Relationship.ToOne<Person>("master")
         }
         class Person: CoreStoreObject {
             let pets = Relationship.ToManyUnordered<Dog>("pets", inverse: { $0.master })
         }
         ```
         - parameter keyPath: the permanent name for this relationship.
         - parameter inverse: the inverse relationship that is declared for the destination object. All relationships require an "inverse", so updates to to this object's relationship are also reflected on its destination object.
         - parameter deleteRule: defines what happens to relationship when an object is deleted. Valid values are `.nullify`, `.cascade`, and `.delete`. Defaults to `.nullify`.
         - parameter versionHashModifier: used to mark or denote a relationship as being a different "version" than another even if all of the values which affect persistence are equal. (Such a difference is important in cases where the properties are unchanged but the format or content of its data are changed.)
         - parameter renamingIdentifier: used to resolve naming conflicts between models. When creating an entity mapping between entities in two managed object models, a source entity property and a destination entity property that share the same identifier indicate that a property mapping should be configured to migrate from the source to the destination. If unset, the identifier will be the property's name.
         - parameter affectedByKeyPaths: a set of key paths for properties whose values affect the value of the receiver. This is similar to `NSManagedObject.keyPathsForValuesAffectingValue(forKey:)`.
         */
        public convenience init(
            _ keyPath: KeyPathString,
            inverse: @escaping (D) -> RelationshipContainer<D>.ToManyOrdered<O>,
            deleteRule: DeleteRule = .nullify,
            versionHashModifier: @autoclosure @escaping () -> String? = nil,
            renamingIdentifier: @autoclosure @escaping () -> String? = nil,
            affectedByKeyPaths: @autoclosure @escaping () -> Set<String> = []) {

            self.init(
                keyPath: keyPath,
                inverseKeyPath: { inverse(D.meta).keyPath },
                deleteRule: deleteRule,
                versionHashModifier: versionHashModifier(),
                renamingIdentifier: renamingIdentifier(),
                affectedByKeyPaths: affectedByKeyPaths()
            )
        }

        /**
         Initializes the metadata for the relationship. All relationships require an "inverse", so updates to to this object's relationship are also reflected on its destination object. Make sure to declare this relationship's inverse relationship on its destination object. Due to Swift's compiler limitation, only one of the relationship and its inverse can declare an `inverse:` argument.
         ```
         class Dog: CoreStoreObject {
             let master = Relationship.ToOne<Person>("master")
         }
         class Person: CoreStoreObject {
             let pets = Relationship.ToManyUnordered<Dog>("pets", inverse: { $0.master })
         }
         ```
         - parameter keyPath: the permanent name for this relationship.
         - parameter inverse: the inverse relationship that is declared for the destination object. All relationships require an "inverse", so updates to to this object's relationship are also reflected on its destination object.
         - parameter deleteRule: defines what happens to relationship when an object is deleted. Valid values are `.nullify`, `.cascade`, and `.delete`. Defaults to `.nullify`.
         - parameter versionHashModifier: used to mark or denote a relationship as being a different "version" than another even if all of the values which affect persistence are equal. (Such a difference is important in cases where the properties are unchanged but the format or content of its data are changed.)
         - parameter renamingIdentifier: used to resolve naming conflicts between models. When creating an entity mapping between entities in two managed object models, a source entity property and a destination entity property that share the same identifier indicate that a property mapping should be configured to migrate from the source to the destination. If unset, the identifier will be the property's name.
         - parameter affectedByKeyPaths: a set of key paths for properties whose values affect the value of the receiver. This is similar to `NSManagedObject.keyPathsForValuesAffectingValue(forKey:)`.
         */
        public convenience init(
            _ keyPath: KeyPathString,
            inverse: @escaping (D) -> RelationshipContainer<D>.ToManyUnordered<O>,
            deleteRule: DeleteRule = .nullify,
            versionHashModifier: @autoclosure @escaping () -> String? = nil,
            renamingIdentifier: @autoclosure @escaping () -> String? = nil,
            affectedByKeyPaths: @autoclosure @escaping () -> Set<String> = []) {

            self.init(
                keyPath: keyPath,
                inverseKeyPath: { inverse(D.meta).keyPath },
                deleteRule: deleteRule,
                versionHashModifier: versionHashModifier(),
                renamingIdentifier: renamingIdentifier(),
                affectedByKeyPaths: affectedByKeyPaths()
            )
        }

        /**
         The relationship value
         */
        public var value: ReturnValueType {

            get {

                return self.nativeValue.flatMap(D.cs_fromRaw)
            }
            set {

                self.nativeValue = newValue?.rawObject
            }
        }


        // MARK: AnyKeyPathStringConvertible

        public var cs_keyPathString: String {

            return self.keyPath
        }


        // MARK: KeyPathStringConvertible

        public typealias ObjectType = O
        public typealias DestinationValueType = D


        // MARK: RelationshipKeyPathStringConvertible

        public typealias ReturnValueType = DestinationValueType?


        // MARK: PropertyProtocol

        internal let keyPath: KeyPathString


        // MARK: RelationshipProtocol

        internal let entityDescriptionValues: () -> RelationshipProtocol.EntityDescriptionValues
        internal var rawObject: CoreStoreManagedObject?

        internal var nativeValue: NSManagedObject? {

            get {

                Internals.assert(
                    self.rawObject != nil,
                    "Attempted to access values from a \(Internals.typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return withExtendedLifetime(self.rawObject!) { (object) in

                    Internals.assert(
                        object.isRunningInAllowedQueue() == true,
                        "Attempted to access \(Internals.typeName(O.self))'s value outside it's designated queue."
                    )
                    return object.getValue(
                        forKvcKey: self.keyPath,
                        didGetValue: { $0 as! NSManagedObject? }
                    )
                }
            }
            set {

                Internals.assert(
                    self.rawObject != nil,
                    "Attempted to access values from a \(Internals.typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                return withExtendedLifetime(self.rawObject!) { (object) in

                    Internals.assert(
                        object.isRunningInAllowedQueue() == true,
                        "Attempted to access \(Internals.typeName(O.self))'s value outside it's designated queue."
                    )
                    Internals.assert(
                        object.isEditableInContext() == true,
                        "Attempted to update a \(Internals.typeName(O.self))'s value from outside a transaction."
                    )
                    object.setValue(
                        newValue,
                        forKvcKey: self.keyPath
                    )
                }
            }
        }

        internal var valueForSnapshot: Any? {

            return self.value?.objectID()
        }


        // MARK: Private

        private init(keyPath: KeyPathString, inverseKeyPath: @escaping () -> KeyPathString?, deleteRule: RelationshipContainer.DeleteRule, versionHashModifier: @autoclosure @escaping () -> String?, renamingIdentifier: @autoclosure @escaping () -> String?, affectedByKeyPaths: @autoclosure @escaping () -> Set<String>) {

            self.keyPath = keyPath
            self.entityDescriptionValues = {
                (
                    isToMany: false,
                    isOrdered: false,
                    deleteRule: deleteRule.nativeValue,
                    inverse: (type: D.self, keyPath: inverseKeyPath()),
                    versionHashModifier: versionHashModifier(),
                    renamingIdentifier: renamingIdentifier(),
                    affectedByKeyPaths: affectedByKeyPaths(),
                    minCount: 0,
                    maxCount: 1
                )
            }
        }
    }
}


// MARK: - Operations

infix operator .= : AssignmentPrecedence
infix operator .== : ComparisonPrecedence

extension RelationshipContainer.ToOne {

    /**
     Assigns an object to the relationship. The operation
     ```
     dog.master .= person
     ```
     is equivalent to
     ```
     dog.master.value = person
     ```
     */
    public static func .= (_ relationship: RelationshipContainer<O>.ToOne<D>, _ newObject: D?) {

        relationship.nativeValue = newObject?.cs_toRaw()
    }

    /**
     Assigns an object from another relationship. The operation
     ```
     dog.master .= anotherDog.master
     ```
     is equivalent to
     ```
     dog.master.value = anotherDog.master.value
     ```
     */
    public static func .= <O2>(_ relationship: RelationshipContainer<O>.ToOne<D>, _ relationship2: RelationshipContainer<O2>.ToOne<D>) {

        relationship.nativeValue = relationship2.nativeValue
    }

    /**
     Compares equality between a relationship's object and another object
     ```
     if dog.master .== person { ... }
     ```
     is equivalent to
     ```
     if dog.master.value == person { ... }
     ```
     */
    public static func .== (_ relationship: RelationshipContainer<O>.ToOne<D>, _ object: D?) -> Bool {

        return relationship.nativeValue == object?.cs_toRaw()
    }

    /**
     Compares equality between an object and a relationship's object
     ```
     if dog.master .== person { ... }
     ```
     is equivalent to
     ```
     if dog.master.value == person { ... }
     ```
     */
    public static func .== (_ object: D?, _ relationship: RelationshipContainer<O>.ToOne<D>) -> Bool {

        return object?.cs_toRaw() == relationship.nativeValue
    }

    /**
     Compares equality between a relationship's object and another relationship's object
     ```
     if dog.master .== person { ... }
     ```
     is equivalent to
     ```
     if dog.master.value == person { ... }
     ```
     */
    public static func .== <O2>(_ relationship: RelationshipContainer<O>.ToOne<D>, _ relationship2: RelationshipContainer<O2>.ToOne<D>) -> Bool {

        return relationship.nativeValue == relationship2.nativeValue
    }
}
