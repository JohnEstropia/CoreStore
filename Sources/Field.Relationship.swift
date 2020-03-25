//
//  Field.ToOne.swift
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

    // MARK: - Relationship

    @propertyWrapper
    public struct Relationship<V: FieldRelationshipType>: RelationshipKeyPathStringConvertible, FieldRelationshipProtocol {

        /**
         Overload for compiler error message only
         */
        @available(*, unavailable, message: "Field.Relationship properties are not allowed to have initial values, including `nil`.")
        public init(
            wrappedValue initial: @autoclosure @escaping () -> V,
            _ keyPath: KeyPathString,
            minCount: Int = 0,
            maxCount: Int = 0,
            deleteRule: DeleteRule = .nullify,
            versionHashModifier: @autoclosure @escaping () -> String? = nil,
            previousVersionKeyPath: @autoclosure @escaping () -> String? = nil
        ) {

            fatalError()
        }

        /**
         Overload for compiler error message only
         */
        @available(*, unavailable, message: "Field.Relationship properties are not allowed to have initial values, including `nil`.")
        public init<D>(
            wrappedValue initial: @autoclosure @escaping () -> V,
            _ keyPath: KeyPathString,
            minCount: Int = 0,
            maxCount: Int = 0,
            inverse: KeyPath<V.DestinationObjectType, FieldContainer<V.DestinationObjectType>.Relationship<D>>,
            deleteRule: DeleteRule = .nullify,
            versionHashModifier: @autoclosure @escaping () -> String? = nil,
            previousVersionKeyPath: @autoclosure @escaping () -> String? = nil
        ) {

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
                Internals.assert(
                    instance.rawObject?.isRunningInAllowedQueue() == true,
                    "Attempted to access \(Internals.typeName(O.self))'s value outside it's designated queue."
                )
                return self.read(field: instance[keyPath: storageKeyPath], for: instance.rawObject!) as! V
            }
            set {

                Internals.assert(
                    instance.rawObject != nil,
                    "Attempted to access values from a \(Internals.typeName(O.self)) meta object. Meta objects are only used for querying keyPaths and infering types."
                )
                Internals.assert(
                    instance.rawObject?.isRunningInAllowedQueue() == true,
                    "Attempted to access \(Internals.typeName(O.self))'s value outside it's designated queue."
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
        public typealias DestinationValueType = V.DestinationObjectType


        // MARK: RelationshipKeyPathStringConvertible

        public typealias ReturnValueType = V


        // MARK: PropertyProtocol

        internal let keyPath: KeyPathString


        // MARK: FieldProtocol

        internal static var dynamicObjectType: CoreStoreObject.Type {

            return ObjectType.self
        }

        internal static func read(field: FieldProtocol, for rawObject: CoreStoreManagedObject) -> Any? {

            let field = field as! Self
            let keyPath = field.keyPath
            return V.cs_toReturnType(
                from: rawObject.value(forKey: keyPath) as! V.NativeValueType?
            )
        }

        internal static func modify(field: FieldProtocol, for rawObject: CoreStoreManagedObject, newValue: Any?) {
            
            Internals.assert(
                rawObject.isEditableInContext() == true,
                "Attempted to update a \(Internals.typeName(O.self))'s value from outside a transaction."
            )
            let newValue = newValue as! V
            let field = field as! Self
            let keyPath = field.keyPath
            return rawObject.setValue(
                V.cs_toNativeType(from: newValue),
                forKey: keyPath
            )
        }


        // MARK: FieldRelationshipProtocol

        internal let entityDescriptionValues: () -> FieldRelationshipProtocol.EntityDescriptionValues

        internal static func valueForSnapshot(field: FieldProtocol, for rawObject: CoreStoreManagedObject) -> Any? {

            Internals.assert(
                rawObject.isRunningInAllowedQueue() == true,
                "Attempted to access \(Internals.typeName(O.self))'s value outside it's designated queue."
            )
            let field = field as! Self
            return V.cs_valueForSnapshot(from: rawObject.objectIDs(forRelationshipNamed: field.keyPath))
        }


        // MARK: FilePrivate

        fileprivate init(
            keyPath: KeyPathString,
            isToMany: Bool,
            isOrdered: Bool,
            deleteRule: DeleteRule,
            inverseKeyPath: @escaping () -> KeyPathString?,
            versionHashModifier: @escaping () -> String?,
            renamingIdentifier: @escaping () -> String?,
            affectedByKeyPaths: @escaping () -> Set<KeyPathString>,
            minCount: Int,
            maxCount: Int
        ) {

            self.keyPath = keyPath
            self.entityDescriptionValues = {

                let range = (Swift.max(0, minCount) ... maxCount)
                return (
                    isToMany: isToMany,
                    isOrdered: isOrdered,
                    deleteRule: deleteRule.nativeValue,
                    inverse: (type: V.DestinationObjectType.self, keyPath: inverseKeyPath()),
                    versionHashModifier: versionHashModifier(),
                    renamingIdentifier: renamingIdentifier(),
                    affectedByKeyPaths: affectedByKeyPaths(),
                    minCount: range.lowerBound,
                    maxCount: range.upperBound
                )
            }
        }


        // MARK: - DeleteRule

        /**
         These constants define what happens to relationships when an object is deleted.
         */
        public enum DeleteRule {

            // MARK: Public

            /**
             If the object is deleted, back pointers from the objects to which it is related are nullified.
             */
            case nullify

            /**
             If the object is deleted, the destination object or objects of this relationship are also deleted.
             */
            case cascade

            /**
             If the destination of this relationship is not nil, the delete creates a validation error.
             */
            case deny


            // MARK: Internal

            internal var nativeValue: NSDeleteRule {

                switch self {

                case .nullify:  return .nullifyDeleteRule
                case .cascade:  return .cascadeDeleteRule
                case .deny:     return .denyDeleteRule
                }
            }
        }
    }
}

extension FieldContainer.Relationship where V: FieldRelationshipToOneType {

    public init(
        _ keyPath: KeyPathString,
        deleteRule: DeleteRule = .nullify,
        versionHashModifier: @autoclosure @escaping () -> String? = nil,
        previousVersionKeyPath: @autoclosure @escaping () -> String? = nil,
        affectedByKeyPaths: @autoclosure @escaping () -> Set<KeyPathString> = []
    ) {

        self.init(
            keyPath: keyPath,
            isToMany: false,
            isOrdered: false,
            deleteRule: deleteRule,
            inverseKeyPath: { nil },
            versionHashModifier: versionHashModifier,
            renamingIdentifier: previousVersionKeyPath,
            affectedByKeyPaths: affectedByKeyPaths,
            minCount: 0,
            maxCount: 1
        )
    }

    public init<D>(
        _ keyPath: KeyPathString,
        inverse: KeyPath<V.DestinationObjectType, FieldContainer<V.DestinationObjectType>.Relationship<D>>,
        deleteRule: DeleteRule = .nullify,
        versionHashModifier: @autoclosure @escaping () -> String? = nil,
        previousVersionKeyPath: @autoclosure @escaping () -> String? = nil,
        affectedByKeyPaths: @autoclosure @escaping () -> Set<KeyPathString> = []
    ) where D: FieldRelationshipType {

        self.init(
            keyPath: keyPath,
            isToMany: false,
            isOrdered: false,
            deleteRule: deleteRule,
            inverseKeyPath: { V.DestinationObjectType.meta[keyPath: inverse].keyPath },
            versionHashModifier: versionHashModifier,
            renamingIdentifier: previousVersionKeyPath,
            affectedByKeyPaths: affectedByKeyPaths,
            minCount: 0,
            maxCount: 1
        )
    }
}

extension FieldContainer.Relationship: ToManyRelationshipKeyPathStringConvertible where V: FieldRelationshipToManyType {}

extension FieldContainer.Relationship where V: FieldRelationshipToManyOrderedType {

    public init(
        _ keyPath: KeyPathString,
        minCount: Int = 0,
        maxCount: Int = 0,
        deleteRule: DeleteRule = .nullify,
        versionHashModifier: @autoclosure @escaping () -> String? = nil,
        previousVersionKeyPath: @autoclosure @escaping () -> String? = nil,
        affectedByKeyPaths: @autoclosure @escaping () -> Set<KeyPathString> = []
    ) {

        self.init(
            keyPath: keyPath,
            isToMany: true,
            isOrdered: true,
            deleteRule: deleteRule,
            inverseKeyPath: { nil },
            versionHashModifier: versionHashModifier,
            renamingIdentifier: previousVersionKeyPath,
            affectedByKeyPaths: affectedByKeyPaths,
            minCount: minCount,
            maxCount: maxCount
        )
    }

    public init<D>(
        _ keyPath: KeyPathString,
        minCount: Int = 0,
        maxCount: Int = 0,
        inverse: KeyPath<V.DestinationObjectType, FieldContainer<V.DestinationObjectType>.Relationship<D>>,
        deleteRule: DeleteRule = .nullify,
        versionHashModifier: @autoclosure @escaping () -> String? = nil,
        previousVersionKeyPath: @autoclosure @escaping () -> String? = nil,
        affectedByKeyPaths: @autoclosure @escaping () -> Set<KeyPathString> = []
    ) where D: FieldRelationshipType {

        self.init(
            keyPath: keyPath,
            isToMany: true,
            isOrdered: true,
            deleteRule: deleteRule,
            inverseKeyPath: { V.DestinationObjectType.meta[keyPath: inverse].keyPath },
            versionHashModifier: versionHashModifier,
            renamingIdentifier: previousVersionKeyPath,
            affectedByKeyPaths: affectedByKeyPaths,
            minCount: minCount,
            maxCount: maxCount
        )
    }
}

extension FieldContainer.Relationship where V: FieldRelationshipToManyUnorderedType {

    public init(
        _ keyPath: KeyPathString,
        minCount: Int = 0,
        maxCount: Int = 0,
        deleteRule: DeleteRule = .nullify,
        versionHashModifier: @autoclosure @escaping () -> String? = nil,
        previousVersionKeyPath: @autoclosure @escaping () -> String? = nil,
        affectedByKeyPaths: @autoclosure @escaping () -> Set<KeyPathString> = []
    ) {

        self.init(
            keyPath: keyPath,
            isToMany: true,
            isOrdered: false,
            deleteRule: deleteRule,
            inverseKeyPath: { nil },
            versionHashModifier: versionHashModifier,
            renamingIdentifier: previousVersionKeyPath,
            affectedByKeyPaths: affectedByKeyPaths,
            minCount: minCount,
            maxCount: maxCount
        )
    }

    public init<D>(
        _ keyPath: KeyPathString,
        minCount: Int = 0,
        maxCount: Int = 0,
        inverse: KeyPath<V.DestinationObjectType, FieldContainer<V.DestinationObjectType>.Relationship<D>>,
        deleteRule: DeleteRule = .nullify,
        versionHashModifier: @autoclosure @escaping () -> String? = nil,
        previousVersionKeyPath: @autoclosure @escaping () -> String? = nil,
        affectedByKeyPaths: @autoclosure @escaping () -> Set<KeyPathString> = []
    ) where D: FieldRelationshipType {

        self.init(
            keyPath: keyPath,
            isToMany: true,
            isOrdered: false,
            deleteRule: deleteRule,
            inverseKeyPath: { V.DestinationObjectType.meta[keyPath: inverse].keyPath },
            versionHashModifier: versionHashModifier,
            renamingIdentifier: previousVersionKeyPath,
            affectedByKeyPaths: affectedByKeyPaths,
            minCount: minCount,
            maxCount: maxCount
        )
    }
}
