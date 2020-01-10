//
//  Relationship.ToManyOrdered.swift
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

    // MARK: - ToManyOrdered

    /**
     The containing type for to-many ordered relationships. Any `CoreStoreObject` subclass can be a destination type. Inverse relationships should be declared from the destination type as well, using the `inverse:` argument for the relationship.
     ```
     class Dog: CoreStoreObject {
         let master = Relationship.ToOne<Person>("master")
     }
     class Person: CoreStoreObject {
         let pets = Relationship.ToManyOrdered<Dog>("pets", inverse: { $0.master })
     }
     ```
     - Important: `Relationship.ToManyOrdered` properties are required to be stored properties. Computed properties will be ignored, including `lazy` and `weak` properties.
     */
    public final class ToManyOrdered<D: CoreStoreObject>: ToManyRelationshipKeyPathStringConvertible, RelationshipProtocol {

        /**
         Initializes the metadata for the relationship. All relationships require an "inverse", so updates to to this object's relationship are also reflected on its destination object. Make sure to declare this relationship's inverse relationship on its destination object. Due to Swift's compiler limitation, only one of the relationship and its inverse can declare an `inverse:` argument.
         ```
         class Dog: CoreStoreObject {
             let master = Relationship.ToOne<Person>("master")
         }
         class Person: CoreStoreObject {
             let pets = Relationship.ToManyOrdered<Dog>("pets", inverse: { $0.master })
         }
         ```
         - parameter keyPath: the permanent name for this relationship.
         - parameter minCount: the minimum number of objects in this relationship UNLESS THE RELATIONSHIP IS EMPTY. This means there might be zero objects in the relationship, which might be less than `minCount`. If the number of objects in the relationship do not satisfy `minCount` and `maxCount`, the transaction's commit (or auto-commit) would fail with a validation error.
         - parameter maxCount: the maximum number of objects in this relationship. If the number of objects in the relationship do not satisfy `minCount` and `maxCount`, the transaction's commit (or auto-commit) would fail with a validation error.
         - parameter deleteRule: defines what happens to relationship when an object is deleted. Valid values are `.nullify`, `.cascade`, and `.delete`. Defaults to `.nullify`.
         - parameter versionHashModifier: used to mark or denote a relationship as being a different "version" than another even if all of the values which affect persistence are equal. (Such a difference is important in cases where the properties are unchanged but the format or content of its data are changed.)
         - parameter renamingIdentifier: used to resolve naming conflicts between models. When creating an entity mapping between entities in two managed object models, a source entity property and a destination entity property that share the same identifier indicate that a property mapping should be configured to migrate from the source to the destination. If unset, the identifier will be the property's name.
         - parameter affectedByKeyPaths: a set of key paths for properties whose values affect the value of the receiver. This is similar to `NSManagedObject.keyPathsForValuesAffectingValue(forKey:)`.
         */
        public convenience init(
            _ keyPath: KeyPathString,
            minCount: Int = 0,
            maxCount: Int = 0,
            deleteRule: DeleteRule = .nullify,
            versionHashModifier: @autoclosure @escaping () -> String? = nil,
            renamingIdentifier: @autoclosure @escaping () -> String? = nil,
            affectedByKeyPaths: @autoclosure @escaping () -> Set<String> = []) {

            self.init(
                keyPath: keyPath,
                minCount: minCount,
                maxCount: maxCount,
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
             let pets = Relationship.ToManyOrdered<Dog>("pets", inverse: { $0.master })
         }
         ```
         - parameter keyPath: the permanent name for this relationship.
         - parameter minCount: the minimum number of objects in this relationship UNLESS THE RELATIONSHIP IS EMPTY. This means there might be zero objects in the relationship, which might be less than `minCount`. If the number of objects in the relationship do not satisfy `minCount` and `maxCount`, the transaction's commit (or auto-commit) would fail with a validation error.
         - parameter maxCount: the maximum number of objects in this relationship. If the number of objects in the relationship do not satisfy `minCount` and `maxCount`, the transaction's commit (or auto-commit) would fail with a validation error.
         - parameter inverse: the inverse relationship that is declared for the destination object. All relationships require an "inverse", so updates to to this object's relationship are also reflected on its destination object.
         - parameter deleteRule: defines what happens to relationship when an object is deleted. Valid values are `.nullify`, `.cascade`, and `.delete`. Defaults to `.nullify`.
         - parameter versionHashModifier: used to mark or denote a relationship as being a different "version" than another even if all of the values which affect persistence are equal. (Such a difference is important in cases where the properties are unchanged but the format or content of its data are changed.)
         - parameter renamingIdentifier: used to resolve naming conflicts between models. When creating an entity mapping between entities in two managed object models, a source entity property and a destination entity property that share the same identifier indicate that a property mapping should be configured to migrate from the source to the destination. If unset, the identifier will be the property's name.
         - parameter affectedByKeyPaths: a set of key paths for properties whose values affect the value of the receiver. This is similar to `NSManagedObject.keyPathsForValuesAffectingValue(forKey:)`.
         */
        public convenience init(
            _ keyPath: KeyPathString,
            minCount: Int = 0,
            maxCount: Int = 0,
            inverse: @escaping (D) -> RelationshipContainer<D>.ToOne<O>,
            deleteRule: DeleteRule = .nullify,
            versionHashModifier: @autoclosure @escaping () -> String? = nil,
            renamingIdentifier: @autoclosure @escaping () -> String? = nil,
            affectedByKeyPaths: @autoclosure @escaping () -> Set<String> = []) {

            self.init(
                keyPath: keyPath,
                minCount: minCount,
                maxCount: maxCount,
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
             let pets = Relationship.ToManyOrdered<Dog>("pets", inverse: { $0.master })
         }
         ```
         - parameter keyPath: the permanent name for this relationship.
         - parameter minCount: the minimum number of objects in this relationship UNLESS THE RELATIONSHIP IS EMPTY. This means there might be zero objects in the relationship, which might be less than `minCount`. If the number of objects in the relationship do not satisfy `minCount` and `maxCount`, the transaction's commit (or auto-commit) would fail with a validation error.
         - parameter maxCount: the maximum number of objects in this relationship. If the number of objects in the relationship do not satisfy `minCount` and `maxCount`, the transaction's commit (or auto-commit) would fail with a validation error.
         - parameter inverse: the inverse relationship that is declared for the destination object. All relationships require an "inverse", so updates to to this object's relationship are also reflected on its destination object.
         - parameter deleteRule: defines what happens to relationship when an object is deleted. Valid values are `.nullify`, `.cascade`, and `.delete`. Defaults to `.nullify`.
         - parameter versionHashModifier: used to mark or denote a relationship as being a different "version" than another even if all of the values which affect persistence are equal. (Such a difference is important in cases where the properties are unchanged but the format or content of its data are changed.)
         - parameter renamingIdentifier: used to resolve naming conflicts between models. When creating an entity mapping between entities in two managed object models, a source entity property and a destination entity property that share the same identifier indicate that a property mapping should be configured to migrate from the source to the destination. If unset, the identifier will be the property's name.
         - parameter affectedByKeyPaths: a set of key paths for properties whose values affect the value of the receiver. This is similar to `NSManagedObject.keyPathsForValuesAffectingValue(forKey:)`.
         */
        public convenience init(
            _ keyPath: KeyPathString,
            minCount: Int = 0,
            maxCount: Int = 0,
            inverse: @escaping (D) -> RelationshipContainer<D>.ToManyOrdered<O>,
            deleteRule: DeleteRule = .nullify,
            versionHashModifier: @autoclosure @escaping () -> String? = nil,
            renamingIdentifier: @autoclosure @escaping () -> String? = nil,
            affectedByKeyPaths: @autoclosure @escaping () -> Set<String> = []) {

            self.init(
                keyPath: keyPath,
                minCount: minCount,
                maxCount: maxCount,
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
             let pets = Relationship.ToManyOrdered<Dog>("pets", inverse: { $0.master })
         }
         ```
         - parameter keyPath: the permanent name for this relationship.
         - parameter minCount: the minimum number of objects in this relationship UNLESS THE RELATIONSHIP IS EMPTY. This means there might be zero objects in the relationship, which might be less than `minCount`. If the number of objects in the relationship do not satisfy `minCount` and `maxCount`, the transaction's commit (or auto-commit) would fail with a validation error.
         - parameter maxCount: the maximum number of objects in this relationship. If the number of objects in the relationship do not satisfy `minCount` and `maxCount`, the transaction's commit (or auto-commit) would fail with a validation error.
         - parameter inverse: the inverse relationship that is declared for the destination object. All relationships require an "inverse", so updates to to this object's relationship are also reflected on its destination object.
         - parameter deleteRule: defines what happens to relationship when an object is deleted. Valid values are `.nullify`, `.cascade`, and `.delete`. Defaults to `.nullify`.
         - parameter versionHashModifier: used to mark or denote a relationship as being a different "version" than another even if all of the values which affect persistence are equal. (Such a difference is important in cases where the properties are unchanged but the format or content of its data are changed.)
         - parameter renamingIdentifier: used to resolve naming conflicts between models. When creating an entity mapping between entities in two managed object models, a source entity property and a destination entity property that share the same identifier indicate that a property mapping should be configured to migrate from the source to the destination. If unset, the identifier will be the property's name.
         - parameter affectedByKeyPaths: a set of key paths for properties whose values affect the value of the receiver. This is similar to `NSManagedObject.keyPathsForValuesAffectingValue(forKey:)`.
         */
        public convenience init(
            _ keyPath: KeyPathString,
            minCount: Int = 0,
            maxCount: Int = 0,
            inverse: @escaping (D) -> RelationshipContainer<D>.ToManyUnordered<O>,
            deleteRule: DeleteRule = .nullify,
            versionHashModifier: @autoclosure @escaping () -> String? = nil,
            renamingIdentifier: @autoclosure @escaping () -> String? = nil,
            affectedByKeyPaths: @autoclosure @escaping () -> Set<String> = []) {

            self.init(
                keyPath: keyPath,
                minCount: minCount,
                maxCount: maxCount,
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

                return self.nativeValue.map({ D.cs_fromRaw(object: $0 as! NSManagedObject) })
            }
            set {

                self.nativeValue = NSOrderedSet(array: newValue.map({ $0.rawObject! }))
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

        public typealias ReturnValueType = [DestinationValueType]


        // MARK: PropertyProtocol

        internal let keyPath: KeyPathString


        // MARK: RelationshipProtocol

        internal let entityDescriptionValues: () -> RelationshipProtocol.EntityDescriptionValues
        internal var rawObject: CoreStoreManagedObject?

        internal var nativeValue: NSOrderedSet {

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
                        didGetValue: { ($0 as! NSOrderedSet?) ?? [] }
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

            return self.value.map({ $0.objectID() })
        }


        // MARK: Private

        private init(keyPath: String, minCount: Int, maxCount: Int, inverseKeyPath: @escaping () -> String?, deleteRule: DeleteRule, versionHashModifier: @autoclosure @escaping () -> String?, renamingIdentifier: @autoclosure @escaping () -> String?, affectedByKeyPaths: @autoclosure @escaping () -> Set<String>) {

            self.keyPath = keyPath
            self.entityDescriptionValues = {
                let range = (Swift.max(0, minCount) ... maxCount)
                return (
                    isToMany: true,
                    isOrdered: true,
                    deleteRule: deleteRule.nativeValue,
                    inverse: (type: D.self, keyPath: inverseKeyPath()),
                    versionHashModifier: versionHashModifier(),
                    renamingIdentifier: renamingIdentifier(),
                    affectedByKeyPaths: affectedByKeyPaths(),
                    minCount: range.lowerBound,
                    maxCount: range.upperBound
                )
            }
        }
    }
}


// MARK: - Convenience

extension RelationshipContainer.ToManyOrdered: RandomAccessCollection {

    // MARK: Sequence

    public typealias Iterator = AnyIterator<D>

    public func makeIterator() -> Iterator {

        var iterator = self.nativeValue.makeIterator()
        return AnyIterator({ iterator.next().flatMap({ D.cs_fromRaw(object: $0 as! NSManagedObject) }) })
    }


    // MARK: Collection

    public typealias Index = Int

    public var startIndex: Index {

        return 0
    }

    public var endIndex: Index {

        return self.nativeValue.count
    }

    public subscript(position: Index) -> Iterator.Element {

        return D.cs_fromRaw(object: self.nativeValue[position] as! NSManagedObject)
    }

    public func index(after i: Index) -> Index {

        return i + 1
    }
}


// MARK: - Operations

infix operator .= : AssignmentPrecedence
infix operator .== : ComparisonPrecedence

extension RelationshipContainer.ToManyOrdered {

    /**
     Assigns a sequence of objects to the relationship. The operation
     ```
     person.pets .= [dog, cat]
     ```
     is equivalent to
     ```
     person.pets.value = [dog, cat]
     ```
     */
    public static func .= <S: Sequence>(_ relationship: RelationshipContainer<O>.ToManyOrdered<D>, _ newValue: S) where S.Iterator.Element == D {

        relationship.nativeValue = NSOrderedSet(array: newValue.map({ $0.rawObject! }))
    }

    /**
     Assigns a sequence of objects to the relationship. The operation
     ```
     person.pets .= anotherPerson.pets
     ```
     is equivalent to
     ```
     person.pets.value = anotherPerson.pets.value
     ```
     */
    public static func .= <O2>(_ relationship: RelationshipContainer<O>.ToManyOrdered<D>, _ relationship2: RelationshipContainer<O2>.ToManyOrdered<D>) {

        relationship.nativeValue = relationship2.nativeValue
    }

    /**
     Compares equality between a relationship's objects and a collection of objects
     ```
     if person.pets .== [dog, cat] { ... }
     ```
     is equivalent to
     ```
     if person.pets.value == [dog, cat] { ... }
     ```
     */
    public static func .== <C: Collection>(_ relationship: RelationshipContainer<O>.ToManyOrdered<D>, _ collection: C) -> Bool where C.Iterator.Element == D {

        return relationship.nativeValue.elementsEqual(
            collection.lazy.map({ $0.rawObject! }),
            by: { ($0 as! NSManagedObject) == $1 }
        )
    }

    /**
     Compares equality between a collection of objects and a relationship's objects
     ```
     if [dog, cat] .== person.pets { ... }
     ```
     is equivalent to
     ```
     if [dog, cat] == person.pets.value { ... }
     ```
     */
    public static func .== <C: Collection>(_ collection: C, _ relationship: RelationshipContainer<O>.ToManyOrdered<D>) -> Bool where C.Iterator.Element == D {

        return relationship.nativeValue.elementsEqual(
            collection.lazy.map({ $0.rawObject! }),
            by: { ($0 as! NSManagedObject) == $1 }
        )
    }

    /**
     Compares equality between a relationship's objects and a collection of objects
     ```
     if person.pets .== anotherPerson.pets { ... }
     ```
     is equivalent to
     ```
     if person.pets.value == anotherPerson.pets.value { ... }
     ```
     */
    public static func .== <O2>(_ relationship: RelationshipContainer<O>.ToManyOrdered<D>, _ relationship2: RelationshipContainer<O2>.ToManyOrdered<D>) -> Bool {

        return relationship.nativeValue == relationship2.nativeValue
    }
}
