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

public final class CoreStoreSchema: DynamicSchema {
    
    public convenience init(modelVersion: String, _ entity: DynamicEntity, _ entities: DynamicEntity...) {
        
        self.init(
            modelVersion: modelVersion,
            entities: [entity] + entities
        )
    }
    
    public convenience init(modelVersion: String, entities: [DynamicEntity]) {
        
        self.init(
            modelVersion: modelVersion,
            entitiesByConfiguration: [DataStack.defaultConfigurationName: entities]
        )
    }
    
    public required init(modelVersion: String, entitiesByConfiguration: [String: [DynamicEntity]]) {
        
        var actualEntitiesByConfiguration: [String: Set<AnyEntity>] = [:]
        for (configuration, entities) in entitiesByConfiguration {
            
            actualEntitiesByConfiguration[configuration] = Set(entities.map(AnyEntity.init))
        }
        let allEntities = Set(actualEntitiesByConfiguration.values.joined())
        actualEntitiesByConfiguration[DataStack.defaultConfigurationName] = allEntities
        
        CoreStore.assert(
            autoreleasepool {
                
                let expectedCount = allEntities.count
                return Set(allEntities.map({ ObjectIdentifier($0.type) })).count == expectedCount
                    && Set(allEntities.map({ $0.entityName })).count == expectedCount
            },
            "Ambiguous entity types or entity names were found in the model. Ensure that the entity types and entity names are unique to each other. Entities: \(allEntities)"
        )
        
        self.modelVersion = modelVersion
        self.entitiesByConfiguration = actualEntitiesByConfiguration
        self.allEntities = allEntities
    }
    
    
    // MARK: - DynamicSchema
    
    public let modelVersion: ModelVersion
    
    public func rawModel() -> NSManagedObjectModel {
        
        if let cachedRawModel = self.cachedRawModel {
            
            return cachedRawModel
        }
        let rawModel = NSManagedObjectModel()
        var entityDescriptionsByEntity: [AnyEntity: NSEntityDescription] = [:]
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
    
    // MARK: - AnyEntity
    
    internal struct AnyEntity: DynamicEntity, Hashable {
        
        internal init(_ entity: DynamicEntity) {
            
            self.type = entity.type
            self.entityName = entity.entityName
        }
        
        internal init(type: CoreStoreObject.Type, entityName: String) {
            
            self.type = type
            self.entityName = entityName
        }
        
        
        // MARK: Equatable
        
        static func == (lhs: AnyEntity, rhs: AnyEntity) -> Bool {
            
            return lhs.type == rhs.type
                && lhs.entityName == rhs.entityName
        }
        
        // MARK: Hashable
        
        var hashValue: Int {
            
            return ObjectIdentifier(self.type).hashValue
                ^ self.entityName.hashValue
        }
        
        // MARK: DynamicEntity
        
        internal let type: CoreStoreObject.Type
        internal let entityName: EntityName
    }
    
    
    // MARK: -
    
    internal let entitiesByConfiguration: [String: Set<AnyEntity>]
    
    
    // MARK: Private
    
    private static let barrierQueue = DispatchQueue.concurrent("com.coreStore.coreStoreDataModelBarrierQueue")
    
    private let allEntities: Set<AnyEntity>
    
    private var entityDescriptionsByEntity: [CoreStoreSchema.AnyEntity: NSEntityDescription] = [:]
    private weak var cachedRawModel: NSManagedObjectModel?
    
    private func entityDescription(for entity: CoreStoreSchema.AnyEntity, initializer: (CoreStoreSchema.AnyEntity) -> NSEntityDescription) -> NSEntityDescription {
        
        if let cachedEntityDescription = self.entityDescriptionsByEntity[entity] {
            
            return cachedEntityDescription
        }
        let entityDescription = withoutActuallyEscaping(initializer, do: { $0(entity) })
        self.entityDescriptionsByEntity[entity] = entityDescription
        return entityDescription
    }
    
    private static func firstPassCreateEntityDescription(from entity: AnyEntity) -> NSEntityDescription {
        
        let entityDescription = NSEntityDescription()
        entityDescription.anyEntity = entity
        entityDescription.name = entity.entityName
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
                    // TODO: versionHash, renamingIdentifier, etc
                    propertyDescriptions.append(description)
                    
                case let relationship as RelationshipProtocol:
                    let description = NSRelationshipDescription()
                    description.name = relationship.keyPath
                    description.minCount = 0
                    description.maxCount = relationship.isToMany ? 0 : 1
                    description.isOrdered = relationship.isOrdered
                    description.deleteRule = relationship.deleteRule
                    // TODO: versionHash, renamingIdentifier, etc
                    propertyDescriptions.append(description)
                    
                default:
                    continue
                }
            }
            return propertyDescriptions
        }
        
        entityDescription.properties = createProperties(for: entity.type)
        return entityDescription
    }
    
    private static func secondPassConnectRelationshipAttributes(for entityDescriptionsByEntity: [AnyEntity: NSEntityDescription]) {
        
        var relationshipsByNameByEntity: [AnyEntity: [String: NSRelationshipDescription]] = [:]
        for (entity, entityDescription) in entityDescriptionsByEntity {
            
            relationshipsByNameByEntity[entity] = entityDescription.relationshipsByName
        }
        func findEntity(for type: CoreStoreObject.Type) -> AnyEntity {
            
            var matchedEntities: Set<AnyEntity> = []
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
        
        func findInverseRelationshipMatching(destinationEntity: AnyEntity, destinationKeyPath: String) -> NSRelationshipDescription {
            
            for case (destinationKeyPath, let relationshipDescription) in relationshipsByNameByEntity[destinationEntity]! {
                
                return relationshipDescription
            }
            CoreStore.abort(
                "The inverse relationship for \"\(destinationEntity.type).\(destinationKeyPath)\" could not be found. Make sure to set the `inverse:` initializer argument for one of the paired \(cs_typeName("Relationship.ToOne<T>")), \(cs_typeName("Relationship.ToManyOrdered<T>")), or \(cs_typeName("Relationship.ToManyUnozrdered<T>"))"
            )
        }
        
        for (entity, entityDescription) in entityDescriptionsByEntity {
            
            let relationshipsByName = relationshipsByNameByEntity[entity]!
            for child in Mirror(reflecting: entity.type.meta).children {
                
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
    
    private static func thirdPassConnectInheritanceTree(for entityDescriptionsByEntity: [AnyEntity: NSEntityDescription]) {
        
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
                mirror: Mirror(reflecting: entity.type.meta),
                entityDescription: entityDescription
            )
        }
    }
}
