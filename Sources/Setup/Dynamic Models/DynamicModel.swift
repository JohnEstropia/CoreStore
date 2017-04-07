//
//  DynamicModel.swift
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

import CoreGraphics
import Foundation


// MARK: - DynamicModel

public final class DynamicModel {
    
    public convenience init(version: String, entities: [EntityProtocol]) {
        
        self.init(version: version, entitiesByConfiguration: [DataStack.defaultConfigurationName: entities])
    }
    
    public required init(version: String, entitiesByConfiguration: [String: [EntityProtocol]]) {
        
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
        
        self.version = version
        self.entitiesByConfiguration = actualEntitiesByConfiguration
        self.allEntities = allEntities
    }
    
    
    // MARK: Internal
    
    // MARK: - AnyEntity
    
    internal struct AnyEntity: EntityProtocol, Hashable {
        
        internal init(_ entity: EntityProtocol) {
            
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
        
        // MARK: EntityProtocol
        
        internal let type: CoreStoreObject.Type
        internal let entityName: EntityName
    }
    
    
    // MARK: -
    
    internal func createModel() -> NSManagedObjectModel {
        
        let model = NSManagedObjectModel()
        let entityDescriptionsByEntity: [AnyEntity: NSEntityDescription] = ModelCache.performUpdate {
            
            var entityDescriptionsByEntity: [AnyEntity: NSEntityDescription] = [:]
            for entity in self.allEntities {
                
                let entityDescription = ModelCache.entityDescription(
                    for: entity,
                    initializer: DynamicModel.firstPassCreateEntityDescription
                )
                entityDescriptionsByEntity[entity] = entityDescription
            }
            DynamicModel.secondPassConnectRelationshipAttributes(for: entityDescriptionsByEntity)
            DynamicModel.thirdPassConnectInheritanceTree(for: entityDescriptionsByEntity)
            return entityDescriptionsByEntity
        }
        model.entities = entityDescriptionsByEntity.values.sorted(by: { $0.name! < $1.name! })
        for (configuration, entities) in self.entitiesByConfiguration {
            
            model.setEntities(
                entities
                    .map({ entityDescriptionsByEntity[$0]! })
                    .sorted(by: { $0.name! < $1.name! }),
                forConfigurationName: configuration
            )
        }
        return model
    }
    
    
    // MARK: FilePrivate
    
    fileprivate static func firstPassCreateEntityDescription(from entity: AnyEntity) -> NSEntityDescription {
        
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
    
    fileprivate static func secondPassConnectRelationshipAttributes(for entityDescriptionsByEntity: [AnyEntity: NSEntityDescription]) {
        
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
                    "No \(cs_typeName("Entity<\(type)>")) instance found in the \(cs_typeName(DynamicModel.self))."
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
    
    fileprivate static func thirdPassConnectInheritanceTree(for entityDescriptionsByEntity: [AnyEntity: NSEntityDescription]) {
        
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
    
    
    // MARK: Private
    
    private let version: String
    private let allEntities: Set<AnyEntity>
    private let entitiesByConfiguration: [String: Set<AnyEntity>]
}


// MARK: - ModelCache

fileprivate enum ModelCache {
    
    fileprivate static func performUpdate<T>(_ closure: () -> T) -> T {
        
        return self.barrierQueue.cs_barrierSync(closure)
    }
    
    fileprivate static func entityDescription(for entity: DynamicModel.AnyEntity, initializer: (DynamicModel.AnyEntity) -> NSEntityDescription) -> NSEntityDescription {
        
        if let cachedEntityDescription = self.entityDescriptionsByEntity[entity] {
            
            return cachedEntityDescription
        }
        let entityDescription = withoutActuallyEscaping(initializer, do: { $0(entity) })
        self.entityDescriptionsByEntity[entity] = entityDescription
        return entityDescription
    }
    
    
    // MARK: Private
    
    private static let barrierQueue = DispatchQueue.concurrent("com.coreStore.modelCacheBarrierQueue")
    
    private static var entityDescriptionsByEntity: [DynamicModel.AnyEntity: NSEntityDescription] = [:]
}
