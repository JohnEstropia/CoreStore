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
//    @dynamicMemberLookup
    public struct Relationship<V: FieldRelationshipType>: RelationshipKeyPathStringConvertible, FieldRelationshipProtocol {

        public typealias DeleteRule = RelationshipContainer<O>.DeleteRule


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
        public typealias DestinationValueType = V.DestinationObjectType


        // MARK: RelationshipKeyPathStringConvertible

        public typealias ReturnValueType = V


        // MARK: PropertyProtocol

        internal let keyPath: KeyPathString


        // MARK: FieldProtocol

        internal static func read(field: FieldProtocol, for rawObject: CoreStoreManagedObject) -> Any? {

            Internals.assert(
                rawObject.isRunningInAllowedQueue() == true,
                "Attempted to access \(Internals.typeName(O.self))'s value outside it's designated queue."
            )
            let field = field as! Self
            let keyPath = field.keyPath
            return V.cs_toReturnType(
                from: rawObject.value(forKey: keyPath) as! V.NativeValueType?
            )
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
            let keyPath = field.keyPath
            return V.cs_valueForSnapshot(
                from: rawObject.value(forKey: keyPath) as! V.NativeValueType?
            )
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
        inverse: @escaping (V.DestinationObjectType) -> FieldContainer<V.DestinationObjectType>.Relationship<D>,
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
            inverseKeyPath: { inverse(V.DestinationObjectType.meta).keyPath },
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
        inverse: @escaping (V.DestinationObjectType) -> FieldContainer<V.DestinationObjectType>.Relationship<D>,
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
            inverseKeyPath: { inverse(V.DestinationObjectType.meta).keyPath },
            versionHashModifier: versionHashModifier,
            renamingIdentifier: previousVersionKeyPath,
            affectedByKeyPaths: affectedByKeyPaths,
            minCount: minCount,
            maxCount: maxCount
        )
    }
}
