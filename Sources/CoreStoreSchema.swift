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
     let species = Value.Required<String>("species")
     let nickname = Value.Optional<String>("nickname")
     let master = Relationship.ToOne<Person>("master")
 }
 
 class Person: CoreStoreObject {
     let name = Value.Required<String>("name")
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
         let species = Value.Required<String>("species")
         let nickname = Value.Optional<String>("nickname")
         let master = Relationship.ToOne<Person>("master")
     }
     
     class Person: CoreStoreObject {
         let name = Value.Required<String>("name")
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
         let species = Value.Required<String>("species")
         let nickname = Value.Optional<String>("nickname")
     }
     
     class Person: CoreStoreObject {
         let name = Value.Required<String>("name")
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
        
        if let cachedRawModel = self.cachedRawModel {
            
            return cachedRawModel
        }
        let rawModel = NSManagedObjectModel()
        var entityDescriptionsByEntity: [DynamicEntity: NSEntityDescription] = [:]
        for entity in self.allEntities {
            
            let entityDescription = self.entityDescription(
                for: entity,
                initializer: CoreStoreSchema.firstPassCreateEntityDescription
            )
            entityDescriptionsByEntity[entity] = (entityDescription.copy() as! NSEntityDescription)
        }
        CoreStoreSchema.secondPassConnectRelationshipAttributes(for: entityDescriptionsByEntity)
        CoreStoreSchema.thirdPassConnectInheritanceTree(for: entityDescriptionsByEntity)
        
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
    
    
    // MARK: Internal
    
    internal let entitiesByConfiguration: [String: Set<DynamicEntity>]
    
    
    // MARK: Private
    
    private static let barrierQueue = DispatchQueue.concurrent("com.coreStore.coreStoreDataModelBarrierQueue")
    
    private let allEntities: Set<DynamicEntity>
    
    private var entityDescriptionsByEntity: [DynamicEntity: NSEntityDescription] = [:]
    private weak var cachedRawModel: NSManagedObjectModel?
    
    private func entityDescription(for entity: DynamicEntity, initializer: (DynamicEntity) -> NSEntityDescription) -> NSEntityDescription {
        
        if let cachedEntityDescription = self.entityDescriptionsByEntity[entity] {
            
            return cachedEntityDescription
        }
        let entityDescription = withoutActuallyEscaping(initializer, do: { $0(entity) })
        self.entityDescriptionsByEntity[entity] = entityDescription
        return entityDescription
    }
    
    private static func firstPassCreateEntityDescription(from entity: DynamicEntity) -> NSEntityDescription {
        
        let entityDescription = NSEntityDescription()
        entityDescription.coreStoreEntity = entity
        entityDescription.name = entity.entityName
        entityDescription.isAbstract = entity.isAbstract
        entityDescription.versionHashModifier = entity.versionHashModifier
        entityDescription.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        
        func createProperties(for type: CoreStoreObject.Type) -> [NSPropertyDescription] {
            
            var propertyDescriptions: [NSPropertyDescription] = []
            for child in Mirror(reflecting: type.meta).children {
                
                switch child.value {
                    
                case let attribute as AttributeProtocol:
                    let description = NSAttributeDescription()
                    description.name = attribute.keyPath
                    description.attributeType = type(of: attribute).attributeType
                    description.isOptional = attribute.isOptional
                    description.isIndexed = attribute.isIndexed
                    description.defaultValue = attribute.defaultValue
                    description.isTransient = attribute.isTransient
                    description.versionHashModifier = attribute.versionHashModifier
                    description.renamingIdentifier = attribute.renamingIdentifier
                    propertyDescriptions.append(description)
                    
                case let relationship as RelationshipProtocol:
                    let description = NSRelationshipDescription()
                    description.name = relationship.keyPath
                    description.minCount = relationship.minCount
                    description.maxCount = relationship.maxCount
                    description.isOrdered = relationship.isOrdered
                    description.deleteRule = relationship.deleteRule
                    description.versionHashModifier = relationship.versionHashModifier
                    description.renamingIdentifier = relationship.renamingIdentifier
                    propertyDescriptions.append(description)
                    
                default:
                    continue
                }
            }
            return propertyDescriptions
        }
        
        entityDescription.properties = createProperties(for: entity.type as! CoreStoreObject.Type)
        return entityDescription
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
}
