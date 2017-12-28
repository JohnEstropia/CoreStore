//
//  CoreStoreSchema.swift
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


// MARK: - CoreStoreSchema

/**
 The `CoreStoreSchema` describes models written for `CoreStoreObject` Swift class declarations for a particular model version. `CoreStoreObject` entities for a model version should be added to `CoreStoreSchema` instance.
 ```
 class Animal: CoreStoreObject {
     let species = Value.Required<String>("species", initial: "")
     let nickname = Value.Optional<String>("nickname")
     let master = Relationship.ToOne<Person>("master")
 }
 
 class Person: CoreStoreObject {
     let name = Value.Required<String>("name", initial: "")
     let pet = Relationship.ToOne<Animal>("pet", inverse: { $0.master })
 }
 
 CoreStore.defaultStack = DataStack(
     CoreStoreSchema(
         modelVersion: "V1",
         entities: [
             Entity<Animal>("Animal"),
             Entity<Person>("Person")
         ],
         versionLock: [
             "Animal": [0x2698c812ebbc3b97, 0x751e3fa3f04cf9, 0x51fd460d3babc82, 0x92b4ba735b5a3053],
             "Person": [0xae4060a59f990ef0, 0x8ac83a6e1411c130, 0xa29fea58e2e38ab6, 0x2071bb7e33d77887]
         ]
     )
 )
 ```
 - SeeAlso: CoreStoreObject
 - SeeAlso: Entity
 */
public final class CoreStoreSchema: DynamicSchema {
    
    /**
     Initializes a `CoreStoreSchema`. Using this initializer only if the entities don't need to be assigned to particular "Configurations". To use multiple configurations (for example, to separate entities in different `StorageInterface`s), use the `init(modelVersion:entitiesByConfiguration:versionLock:)` initializer.
     ```
     class Animal: CoreStoreObject {
         let species = Value.Required<String>("species", initial: "")
         let nickname = Value.Optional<String>("nickname")
         let master = Relationship.ToOne<Person>("master")
     }
     
     class Person: CoreStoreObject {
         let name = Value.Required<String>("name", initial: "")
         let pet = Relationship.ToOne<Animal>("pet", inverse: { $0.master })
     }
     
     CoreStore.defaultStack = DataStack(
         CoreStoreSchema(
             modelVersion: "V1",
             entities: [
                 Entity<Animal>("Animal"),
                 Entity<Person>("Person")
             ],
             versionLock: [
                 "Animal": [0x2698c812ebbc3b97, 0x751e3fa3f04cf9, 0x51fd460d3babc82, 0x92b4ba735b5a3053],
                 "Person": [0xae4060a59f990ef0, 0x8ac83a6e1411c130, 0xa29fea58e2e38ab6, 0x2071bb7e33d77887]
             ]
         )
     )
     ```
     - parameter modelVersion: the model version for the schema. This string should be unique from other `DynamicSchema`'s model versions.
     - parameter entities: an array of `Entity<T>` pertaining to all `CoreStoreObject` subclasses to be added to the schema version.
     - parameter versionLock: an optional list of `VersionLock` hashes for each entity name in the `entities` array. If any `DynamicEntity` doesn't match its version lock hash, an assertion will be raised.
     */
    public convenience init(modelVersion: ModelVersion, entities: [DynamicEntity], versionLock: VersionLock? = nil) {
        
        var entityConfigurations: [DynamicEntity: Set<String>] = [:]
        for entity in entities {
            
            entityConfigurations[entity] = []
        }
        self.init(
            modelVersion: modelVersion,
            entityConfigurations: entityConfigurations,
            versionLock: versionLock
        )
    }
    
    /**
     Initializes a `CoreStoreSchema`. Using this initializer if multiple "Configurations" (for example, to separate entities in different `StorageInterface`s) are needed. To add an entity only to the default configuration, assign an empty set to its configurations list. Note that regardless of the set configurations, all entities will be added to the default configuration.
     ```
     class Animal: CoreStoreObject {
         let species = Value.Required<String>("species", initial: "")
         let nickname = Value.Optional<String>("nickname")
     }
     
     class Person: CoreStoreObject {
         let name = Value.Required<String>("name", initial: "")
     }
     
     CoreStore.defaultStack = DataStack(
         CoreStoreSchema(
             modelVersion: "V1",
             entityConfigurations: [
                 Entity<Animal>("Animal"): [],
                 Entity<Person>("Person"): ["People"]
             ],
             versionLock: [
                 "Animal": [0x2698c812ebbc3b97, 0x751e3fa3f04cf9, 0x51fd460d3babc82, 0x92b4ba735b5a3053],
                 "Person": [0xae4060a59f990ef0, 0x8ac83a6e1411c130, 0xa29fea58e2e38ab6, 0x2071bb7e33d77887]
             ]
         )
     )
     ```
     - parameter modelVersion: the model version for the schema. This string should be unique from other `DynamicSchema`'s model versions.
     - parameter entityConfigurations: a dictionary with `Entity<T>` pertaining to all `CoreStoreObject` subclasses  and the corresponding list of "Configurations" they should be added to. To add an entity only to the default configuration, assign an empty set to its configurations list. Note that regardless of the set configurations, all entities will be added to the default configuration.
     - parameter versionLock: an optional list of `VersionLock` hashes for each entity name in the `entities` array. If any `DynamicEntity` doesn't match its version lock hash, an assertion will be raised.
     */
    public required init(modelVersion: ModelVersion, entityConfigurations: [DynamicEntity: Set<String>], versionLock: VersionLock? = nil) {
        
        var actualEntitiesByConfiguration: [String: Set<DynamicEntity>] = [:]
        for (entity, configurations) in entityConfigurations {
            
            for configuration in configurations {
                
                var entities: Set<DynamicEntity>
                if let existingEntities = actualEntitiesByConfiguration[configuration] {
                    
                    entities = existingEntities
                }
                else {
                    
                    entities = []
                }
                entities.insert(entity)
                actualEntitiesByConfiguration[configuration] = entities
            }
        }
        let allEntities = Set(entityConfigurations.keys)
        actualEntitiesByConfiguration[DataStack.defaultConfigurationName] = allEntities
        
        CoreStore.assert(
            cs_lazy {
                
                let expectedCount = allEntities.count
                return Set(allEntities.map({ ObjectIdentifier($0.type) })).count == expectedCount
                    && Set(allEntities.map({ $0.entityName })).count == expectedCount
            },
            "Ambiguous entity types or entity names were found in the model. Ensure that the entity types and entity names are unique to each other. Entities: \(allEntities)"
        )
        
        self.modelVersion = modelVersion
        self.entitiesByConfiguration = actualEntitiesByConfiguration
        self.allEntities = allEntities
        
        if let versionLock = versionLock {
            
            CoreStore.assert(
                versionLock == VersionLock(entityVersionHashesByName: self.rawModel().entityVersionHashesByName),
                "A \(cs_typeName(VersionLock.self)) was provided for the \(cs_typeName(CoreStoreSchema.self)) with version \"\(modelVersion)\", but the actual hashes do not match. This may result in unwanted migrations or unusable persistent stores.\nExpected lock values: \(versionLock)\nActual lock values: \(VersionLock(entityVersionHashesByName: self.rawModel().entityVersionHashesByName))"
            )
        }
        else {
            
            #if DEBUG
                CoreStore.log(
                    .notice,
                    message: "These are hashes for the \(cs_typeName(CoreStoreSchema.self)) with version name \"\(modelVersion)\". Copy the dictionary below and pass it to the \(cs_typeName(CoreStoreSchema.self)) initializer's \"versionLock\" argument:\nversionLock: \(VersionLock(entityVersionHashesByName: self.rawModel().entityVersionHashesByName))"
                )
            #endif
        }
    }
    
    
    // MARK: - DynamicSchema
    
    public let modelVersion: ModelVersion
    
    public func rawModel() -> NSManagedObjectModel {
        
        return CoreStoreSchema.barrierQueue.sync(flags: .barrier) {
            
            if let cachedRawModel = self.cachedRawModel {
                
                return cachedRawModel
            }
            let rawModel = NSManagedObjectModel()
            var entityDescriptionsByEntity: [DynamicEntity: NSEntityDescription] = [:]
            var allCustomGettersSetters: [DynamicEntity: [KeyPathString: CoreStoreManagedObject.CustomGetterSetter]] = [:]
            for entity in self.allEntities {
                
                let (entityDescription, customGetterSetterByKeyPaths) = self.entityDescription(
                    for: entity,
                    initializer: CoreStoreSchema.firstPassCreateEntityDescription(from:in:)
                )
                entityDescriptionsByEntity[entity] = (entityDescription.copy() as! NSEntityDescription)
                allCustomGettersSetters[entity] = customGetterSetterByKeyPaths
            }
            CoreStoreSchema.secondPassConnectRelationshipAttributes(for: entityDescriptionsByEntity)
            CoreStoreSchema.thirdPassConnectInheritanceTree(for: entityDescriptionsByEntity)
            CoreStoreSchema.fourthPassSynthesizeManagedObjectClasses(
                for: entityDescriptionsByEntity,
                allCustomGettersSetters: allCustomGettersSetters
            )
            
            rawModel.entities = entityDescriptionsByEntity.values.sorted(by: { $0.name! < $1.name! })
            for (configuration, entities) in self.entitiesByConfiguration {
                
                rawModel.setEntities(
                    entities
                        .map({ entityDescriptionsByEntity[$0]! })
                        .sorted(by: { $0.name! < $1.name! }),
                    forConfigurationName: configuration
                )
            }
            self.cachedRawModel = rawModel
            return rawModel
        }
    }
    
    
    // MARK: Internal
    
    internal let entitiesByConfiguration: [String: Set<DynamicEntity>]
    
    
    // MARK: Private
    
    private static let barrierQueue = DispatchQueue.concurrent("com.coreStore.coreStoreDataModelBarrierQueue")
    
    private let allEntities: Set<DynamicEntity>
    
    private var entityDescriptionsByEntity: [DynamicEntity: NSEntityDescription] = [:]
    private var customGettersSettersByEntity: [DynamicEntity: [KeyPathString: CoreStoreManagedObject.CustomGetterSetter]] = [:]
    private weak var cachedRawModel: NSManagedObjectModel?
    
    private func entityDescription(for entity: DynamicEntity, initializer: (DynamicEntity, ModelVersion) -> (entity: NSEntityDescription, customGetterSetterByKeyPaths: [KeyPathString: CoreStoreManagedObject.CustomGetterSetter])) -> (entity: NSEntityDescription, customGetterSetterByKeyPaths: [KeyPathString: CoreStoreManagedObject.CustomGetterSetter]) {
        
        if let cachedEntityDescription = self.entityDescriptionsByEntity[entity] {
            
            return (cachedEntityDescription, self.customGettersSettersByEntity[entity] ?? [:])
        }
        let modelVersion = self.modelVersion
        let (entityDescription, customGetterSetterByKeyPaths) = withoutActuallyEscaping(initializer, do: { $0(entity, modelVersion) })
        self.entityDescriptionsByEntity[entity] = entityDescription
        self.customGettersSettersByEntity[entity] = customGetterSetterByKeyPaths
        return (entityDescription, customGetterSetterByKeyPaths)
    }
    
    private static func firstPassCreateEntityDescription(from entity: DynamicEntity, in modelVersion: ModelVersion) -> (entity: NSEntityDescription, customGetterSetterByKeyPaths: [KeyPathString: CoreStoreManagedObject.CustomGetterSetter]) {
        
        let entityDescription = NSEntityDescription()
        entityDescription.coreStoreEntity = entity
        entityDescription.name = entity.entityName
        entityDescription.isAbstract = entity.isAbstract
        entityDescription.versionHashModifier = entity.versionHashModifier
        entityDescription.managedObjectClassName = CoreStoreManagedObject.cs_subclassName(for: entity, in: modelVersion)
        
        var keyPathsByAffectedKeyPaths: [KeyPathString: Set<KeyPathString>] = [:]
        var customGetterSetterByKeyPaths: [KeyPathString: CoreStoreManagedObject.CustomGetterSetter] = [:]
        func createProperties(for type: CoreStoreObject.Type) -> [NSPropertyDescription] {
            
            var propertyDescriptions: [NSPropertyDescription] = []
            for child in Mirror(reflecting: type.meta).children {
                
                switch child.value {
                    
                case let attribute as AttributeProtocol:
                    let description = NSAttributeDescription()
                    description.name = attribute.keyPath
                    description.attributeType = Swift.type(of: attribute).attributeType
                    description.isOptional = attribute.isOptional
                    description.isIndexed = attribute.isIndexed
                    description.defaultValue = attribute.defaultValue()
                    description.isTransient = attribute.isTransient
                    description.versionHashModifier = attribute.versionHashModifier()
                    description.renamingIdentifier = attribute.renamingIdentifier()
                    propertyDescriptions.append(description)
                    keyPathsByAffectedKeyPaths[attribute.keyPath] = attribute.affectedByKeyPaths()
                    customGetterSetterByKeyPaths[attribute.keyPath] = (attribute.getter, attribute.setter)
                    
                case let relationship as RelationshipProtocol:
                    let description = NSRelationshipDescription()
                    description.name = relationship.keyPath
                    description.minCount = relationship.minCount
                    description.maxCount = relationship.maxCount
                    description.isOrdered = relationship.isOrdered
                    description.deleteRule = relationship.deleteRule
                    description.versionHashModifier = relationship.versionHashModifier()
                    description.renamingIdentifier = relationship.renamingIdentifier()
                    propertyDescriptions.append(description)
                    keyPathsByAffectedKeyPaths[relationship.keyPath] = relationship.affectedByKeyPaths()
                    
                default:
                    continue
                }
            }
            return propertyDescriptions
        }
        entityDescription.properties = createProperties(for: entity.type as! CoreStoreObject.Type)
        entityDescription.keyPathsByAffectedKeyPaths = keyPathsByAffectedKeyPaths
        return (entityDescription, customGetterSetterByKeyPaths)
    }
    
    private static func secondPassConnectRelationshipAttributes(for entityDescriptionsByEntity: [DynamicEntity: NSEntityDescription]) {
        
        var relationshipsByNameByEntity: [DynamicEntity: [String: NSRelationshipDescription]] = [:]
        for (entity, entityDescription) in entityDescriptionsByEntity {
            
            relationshipsByNameByEntity[entity] = entityDescription.relationshipsByName
        }
        func findEntity(for type: CoreStoreObject.Type) -> DynamicEntity {
            
            var matchedEntities: Set<DynamicEntity> = []
            for (entity, _) in entityDescriptionsByEntity where entity.type == type {
                
                matchedEntities.insert(entity)
            }
            if matchedEntities.count == 1 {
                
                return matchedEntities.first!
            }
            if matchedEntities.isEmpty {
                
                CoreStore.abort(
                    "No \(cs_typeName("Entity<\(type)>")) instance found in the \(cs_typeName(CoreStoreSchema.self))."
                )
            }
            else {
                
                CoreStore.abort(
                    "Ambiguous entity types or entity names were found in the model. Ensure that the entity types and entity names are unique to each other. Entities: \(matchedEntities)"
                )
            }
        }
        
        func findInverseRelationshipMatching(destinationEntity: DynamicEntity, destinationKeyPath: String) -> NSRelationshipDescription {
            
            for case (destinationKeyPath, let relationshipDescription) in relationshipsByNameByEntity[destinationEntity]! {
                
                return relationshipDescription
            }
            CoreStore.abort(
                "The inverse relationship for \"\(destinationEntity.type).\(destinationKeyPath)\" could not be found. Make sure to set the `inverse:` initializer argument for one of the paired \(cs_typeName("Relationship.ToOne<T>")), \(cs_typeName("Relationship.ToManyOrdered<T>")), or \(cs_typeName("Relationship.ToManyUnozrdered<T>"))"
            )
        }
        
        for (entity, entityDescription) in entityDescriptionsByEntity {
            
            let relationshipsByName = relationshipsByNameByEntity[entity]!
            for child in Mirror(reflecting: (entity.type as! CoreStoreObject.Type).meta).children {
                
                switch child.value {
                    
                case let relationship as RelationshipProtocol:
                    let (destinationType, destinationKeyPath) = relationship.inverse
                    let destinationEntity = findEntity(for: destinationType)
                    let description = relationshipsByName[relationship.keyPath]!
                    description.destinationEntity = entityDescriptionsByEntity[destinationEntity]!
                    
                    if let destinationKeyPath = destinationKeyPath() {
                        
                        let inverseRelationshipDescription = findInverseRelationshipMatching(
                            destinationEntity: destinationEntity,
                            destinationKeyPath: destinationKeyPath
                        )
                        description.inverseRelationship = inverseRelationshipDescription
                        
                        inverseRelationshipDescription.inverseRelationship = description
                        inverseRelationshipDescription.destinationEntity = entityDescription
                        
                        description.destinationEntity!.properties = description.destinationEntity!.properties
                    }
                    
                default:
                    continue
                }
            }
        }
        for (entity, entityDescription) in entityDescriptionsByEntity {
            
            for (name, relationshipDescription) in entityDescription.relationshipsByName {
                
                CoreStore.assert(
                    relationshipDescription.destinationEntity != nil,
                    "The destination entity for relationship \"\(entity.type).\(name)\" could not be resolved."
                )
                CoreStore.assert(
                    relationshipDescription.inverseRelationship != nil,
                    "The inverse relationship for \"\(entity.type).\(name)\" could not be found. Make sure to set the `inverse:` argument of the initializer for one of the paired \(cs_typeName("Relationship.ToOne<T>")), \(cs_typeName("Relationship.ToManyOrdered<T>")), or \(cs_typeName("Relationship.ToManyUnozrdered<T>"))"
                )
            }
        }
    }
    
    private static func thirdPassConnectInheritanceTree(for entityDescriptionsByEntity: [DynamicEntity: NSEntityDescription]) {
        
        func connectBaseEntity(mirror: Mirror, entityDescription: NSEntityDescription) {
            
            guard let superclassMirror = mirror.superclassMirror,
                let superType = superclassMirror.subjectType as? CoreStoreObject.Type,
                superType != CoreStoreObject.self else {
                    
                    return
            }
            for (superEntity, superEntityDescription) in entityDescriptionsByEntity where superEntity.type == superType {
                
                if !superEntityDescription.subentities.contains(entityDescription) {
                    
                    superEntityDescription.subentities.append(entityDescription)
                }
                connectBaseEntity(mirror: superclassMirror, entityDescription: superEntityDescription)
            }
        }
        for (entity, entityDescription) in entityDescriptionsByEntity {
            
            connectBaseEntity(
                mirror: Mirror(reflecting: (entity.type as! CoreStoreObject.Type).meta),
                entityDescription: entityDescription
            )
        }
    }
    
    private static func fourthPassSynthesizeManagedObjectClasses(for entityDescriptionsByEntity: [DynamicEntity: NSEntityDescription], allCustomGettersSetters: [DynamicEntity: [KeyPathString: CoreStoreManagedObject.CustomGetterSetter]]) {
        
        func createManagedObjectSubclass(for entityDescription: NSEntityDescription, customGetterSetterByKeyPaths: [KeyPathString: CoreStoreManagedObject.CustomGetterSetter]?) {
            
            let superEntity = entityDescription.superentity
            let className = entityDescription.managedObjectClassName!
            guard case nil = NSClassFromString(className) as! CoreStoreManagedObject.Type? else {
                
                return
            }
            if let superEntity = superEntity {
                
                createManagedObjectSubclass(
                    for: superEntity,
                    customGetterSetterByKeyPaths: superEntity.coreStoreEntity.flatMap({ allCustomGettersSetters[$0] })
                )
            }
            let superClass = cs_lazy { () -> CoreStoreManagedObject.Type in
                
                if let superClassName = superEntity?.managedObjectClassName,
                    let superClass = NSClassFromString(superClassName) {
                    
                    return superClass as! CoreStoreManagedObject.Type
                }
                return CoreStoreManagedObject.self
            }
            let managedObjectClass: AnyClass = className.withCString {
                
                return objc_allocateClassPair(superClass, $0, 0)!
            }
            defer {
            
                objc_registerClassPair(managedObjectClass)
            }
            
            func capitalize(_ string: String) -> String {
                
                return string.replacingCharacters(
                    in: Range(uncheckedBounds: (string.startIndex, string.index(after: string.startIndex))),
                    with: String(string[string.startIndex]).uppercased()
                )
            }
            for (attributeName, customGetterSetters) in (customGetterSetterByKeyPaths ?? [:])
                where customGetterSetters.getter != nil || customGetterSetters.setter != nil {
                    
                    if let getter = customGetterSetters.getter {
                        
                        let getterName = "\(attributeName)"
                        guard class_addMethod(
                            managedObjectClass,
                            NSSelectorFromString(getterName),
                            imp_implementationWithBlock(getter),
                            "@@:") else {
                                
                                CoreStore.abort("Could not dynamically add getter method \"\(getterName)\" to class \(cs_typeName(managedObjectClass))")
                        }
                    }
                    if let setter = customGetterSetters.setter {
                        
                        let setterName = "set\(capitalize(attributeName)):"
                        guard class_addMethod(
                            managedObjectClass,
                            NSSelectorFromString(setterName),
                            imp_implementationWithBlock(setter),
                            "v@:@") else {
                                
                                CoreStore.abort("Could not dynamically add setter method \"\(setterName)\" to class \(cs_typeName(managedObjectClass))")
                        }
                    }
            }
            
            let newSelector = NSSelectorFromString("cs_keyPathsForValuesAffectingValueForKey:")
            let keyPathsByAffectedKeyPaths = entityDescription.keyPathsByAffectedKeyPaths
            let keyPathsForValuesAffectingValue: @convention(block) (Any, String) -> Set<String> = { (instance, keyPath) in
                
                if let keyPaths = keyPathsByAffectedKeyPaths[keyPath] {
                    
                    return keyPaths
                }
                return []
            }
            let origSelector = #selector(NSManagedObject.keyPathsForValuesAffectingValue(forKey:))
            
            let metaClass: AnyClass = object_getClass(managedObjectClass)!
            let origMethod = class_getClassMethod(managedObjectClass, origSelector)!
            
            let origImp = method_getImplementation(origMethod)
            let newImp = imp_implementationWithBlock(keyPathsForValuesAffectingValue)
            
            if class_addMethod(metaClass, origSelector, newImp, method_getTypeEncoding(origMethod)) {
                
                class_replaceMethod(metaClass, newSelector, origImp, method_getTypeEncoding(origMethod))
            }
            else {
                
                let newMethod = class_getClassMethod(managedObjectClass, newSelector)!
                method_exchangeImplementations(origMethod, newMethod)
            }
        }
        for (dynamicEntity, entityDescription) in entityDescriptionsByEntity {
            
            createManagedObjectSubclass(
                for: entityDescription,
                customGetterSetterByKeyPaths: allCustomGettersSetters[dynamicEntity]
            )
        }
    }
}
