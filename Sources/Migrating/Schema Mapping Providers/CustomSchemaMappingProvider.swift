//
//  CustomSchemaMappingProvider.swift
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


// MARK: - CustomSchemaMappingProvider

open class CustomSchemaMappingProvider: Hashable, SchemaMappingProvider {
    
    // MARK: - CustomMapping
    
    public enum CustomMapping: Hashable {
        
        case deleteEntity(sourceEntity: EntityName)
        case insertEntity(destinationEntity: EntityName)
        case transformEntity(sourceEntity: EntityName, destinationEntity: EntityName, transformEntity: (_ sourceObject: UnsafeProxyObject, _ destinationObject: UnsafeProxyObject) throws -> Void)
        
        static func inferredTransformation(sourceObject: UnsafeProxyObject, destinationObject: UnsafeProxyObject) throws -> Void {
            
            // TODO:
        }
//        
//        case deleteAttribute(sourceEntity: EntityName, sourceAttribute: KeyPath)
//        case insertAttribute(destinationEntity: EntityName, destinationAttribute: KeyPath)
//        case transformAttribute(sourceEntity: EntityName, sourceAttribute: KeyPath, destinationEntity: EntityName, destinationAttribute: KeyPath, transform: (_ sourceValue: Any?) throws -> Any?)
        
        var entityMappingSourceEntity: EntityName? {
            
            switch self {
                
            case .deleteEntity(let sourceEntity),
                 .transformEntity(let sourceEntity, _, _):
                return sourceEntity
                
            case .insertEntity:
//                 .insertAttribute,
//                 .deleteAttribute,
//                 .transformAttribute:
                return nil
            }
        }
        
        var entityMappingDestinationEntity: EntityName? {
            
            switch self {
                
            case .insertEntity(let destinationEntity),
                 .transformEntity(_, let destinationEntity, _):
                return destinationEntity
                
            case .deleteEntity:
//                 .deleteAttribute,
//                 .insertAttribute,
//                 .transformAttribute:
                return nil
            }
        }
        
//        func attributeMappingSourceAttribute(for sourceEntity: EntityName) -> KeyPath? {
//            
//            switch self {
//                
//            case .deleteAttribute(sourceEntity, let sourceAttribute),
//                 .transformAttribute(sourceEntity, let sourceAttribute, _, _, _):
//                return sourceAttribute
//                
//            case .deleteEntity,
//                 .insertEntity,
//                 .insertAttribute,
//                 .transformEntity:
//                return nil
//            }
//        }
//        
//        func attributeMappingDestinationAttribute(for destinationEntity: EntityName) -> KeyPath? {
//            
//            switch self {
//                
//            case .insertAttribute(destinationEntity, let destinationAttribute),
//                 .transformAttribute(_, _, destinationEntity, let destinationAttribute, _):
//                return destinationAttribute
//                
//            case .deleteEntity,
//                 .insertEntity,
//                 .deleteAttribute,
//                 .transformEntity:
//                return nil
//            }
//        }
        
        
        
        // MARK: Equatable
        
        public static func == (lhs: CustomMapping, rhs: CustomMapping) -> Bool {
            
            switch (lhs, rhs) {
                
            case (.deleteEntity(let sourceEntity1), .deleteEntity(let sourceEntity2)):
                return sourceEntity1 == sourceEntity2
                
            case (.insertEntity(let destinationEntity1), .insertEntity(let destinationEntity2)):
                return destinationEntity1 == destinationEntity2
                
            case (.transformEntity(let sourceEntity1, let destinationEntity1, _), .transformEntity(let sourceEntity2, let destinationEntity2, _)):
                return sourceEntity1 == sourceEntity2
                    && destinationEntity1 == destinationEntity2
                
//            case (.deleteAttribute(let sourceEntity1, let sourceAttribute1), .deleteAttribute(let sourceEntity2, let sourceAttribute2)):
//                return sourceEntity1 == sourceEntity2
//                    && sourceAttribute1 == sourceAttribute2
//                
//            case (.insertAttribute(let destinationEntity1, let destinationAttribute1), .insertAttribute(let destinationEntity2, let destinationAttribute2)):
//                return destinationEntity1 == destinationEntity2
//                    && destinationAttribute1 == destinationAttribute2
//                
//            case (.transformAttribute(let sourceEntity1, let sourceAttribute1, let destinationEntity1, let destinationAttribute1, _), .transformAttribute(let sourceEntity2, let sourceAttribute2, let destinationEntity2, let destinationAttribute2, _)):
//                return sourceEntity1 == sourceEntity2
//                    && sourceAttribute1 == sourceAttribute2
//                    && destinationEntity1 == destinationEntity2
//                    && destinationAttribute1 == destinationAttribute2
                
            default:
                return false
            }
        }
        
        
        // MARK: Hashable
        
        public var hashValue: Int {
            
            switch self {
                
            case .deleteEntity(let sourceEntity):
                return sourceEntity.hashValue
                
            case .insertEntity(let destinationEntity):
                return destinationEntity.hashValue
                
            case .transformEntity(let sourceEntity, let destinationEntity, _):
                return sourceEntity.hashValue
                    ^ destinationEntity.hashValue
                
//            case .deleteAttribute(let sourceEntity, let sourceAttribute):
//                return sourceEntity.hashValue
//                    ^ sourceAttribute.hashValue
//                
//            case .insertAttribute(let destinationEntity, let destinationAttribute):
//                return destinationEntity.hashValue
//                    ^ destinationAttribute.hashValue
//                
//            case .transformAttribute(let sourceEntity, let sourceAttribute, let destinationEntity, let destinationAttribute, _):
//                return sourceEntity.hashValue
//                    ^ sourceAttribute.hashValue
//                    ^ destinationEntity.hashValue
//                    ^ destinationAttribute.hashValue
            }
        }
    }
    
    
    // MARK: - UnsafeProxyTransaction
    
    public final class UnsafeProxyTransaction {
        
        func fetchAll(entityName: EntityName, _ fetchClauses: FetchClause...) -> [UnsafeProxyObject] {
            
            return self.fetchAll(entityName: entityName, fetchClauses)
        }
        
        func fetchAll(entityName: EntityName, _ fetchClauses: [FetchClause]) -> [UnsafeProxyObject] {
            
            // TODO:
            fatalError()
        }
    }
    
    
    // MARK: - UnsafeProxyObject
    
    public final class UnsafeProxyObject {
        
        public subscript(kvcKey: KeyPath) -> Any? {
            
            get { return self.rawObject.cs_accessValueForKVCKey(kvcKey) }
            set { self.rawObject.cs_setValue(newValue, forKVCKey: kvcKey) }
        }
        
        
        // MARK: Internal
        
        internal init(_ rawObject: NSManagedObject) {
            
            self.rawObject = rawObject
        }
        
        
        // MARK: Private
        
        private let rawObject: NSManagedObject
    }
    
    
    // MARK: - Public
    
    public let sourceVersion: ModelVersion
    public let destinationVersion: ModelVersion
    
    public required init(from sourceVersion: ModelVersion, to destinationVersion: ModelVersion, entityMappings: Set<CustomMapping> = []) {
        
        CoreStore.assert(
            cs_lazy {
             
                let sources = entityMappings.flatMap({ $0.entityMappingSourceEntity })
                let destinations = entityMappings.flatMap({ $0.entityMappingDestinationEntity })
                return sources.count == Set(sources).count
                    && destinations.count == Set(destinations).count
            },
            "Duplicate source/destination entities found in provided \"entityMappings\" argument."
        )
        self.sourceVersion = sourceVersion
        self.destinationVersion = destinationVersion
        self.entityMappings = entityMappings
    }
    
    
    // MARK: Equatable
    
    public static func == (lhs: CustomSchemaMappingProvider, rhs: CustomSchemaMappingProvider) -> Bool {
        
        return lhs.sourceVersion == rhs.sourceVersion
            && lhs.destinationVersion == rhs.destinationVersion
            && type(of: lhs) == type(of: rhs)
    }
    
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        return self.sourceVersion.hashValue
            ^ self.destinationVersion.hashValue
    }
    
    
    // MARK: SchemaMappingProvider
    
    public func createMappingModel(from sourceSchema: DynamicSchema, to destinationSchema: DynamicSchema, storage: LocalStorage) throws -> (mappingModel: NSMappingModel, migrationType: MigrationType) {
        
        let sourceModel = sourceSchema.rawModel()
        let destinationModel = destinationSchema.rawModel()
        
        let mappingModel = NSMappingModel()
        
        let (deleteMappings, insertMappings, transformMappings) = self.resolveEntityMappings(
            sourceModel: sourceModel,
            destinationModel: destinationModel
        )
        func expression(forSource sourceEntity: NSEntityDescription) -> NSExpression {
            
            return NSExpression(format: "FETCH(FUNCTION($manager, \"fetchRequestForSourceEntityNamed:predicateString:\" , \"\(sourceEntity.name!)\", \"TRUEPREDICATE\"), $manager.sourceContext, NO)")
        }
        
        let sourceEntitiesByName = sourceModel.entitiesByName
        let destinationEntitiesByName = destinationModel.entitiesByName
        
        var entityMappings: [NSEntityMapping] = []
        for case .deleteEntity(let sourceEntityName) in deleteMappings {
            
            let sourceEntity = sourceEntitiesByName[sourceEntityName]!
            
            let entityMapping = NSEntityMapping()
            entityMapping.sourceEntityName = sourceEntity.name
            entityMapping.sourceEntityVersionHash = sourceEntity.versionHash
            entityMapping.mappingType = .removeEntityMappingType
            entityMapping.sourceExpression = expression(forSource: sourceEntity)
            
            entityMappings.append(entityMapping)
        }
        for case .insertEntity(let destinationEntityName) in insertMappings {
            
            let destinationEntity = destinationEntitiesByName[destinationEntityName]!
            
            let entityMapping = NSEntityMapping()
            entityMapping.destinationEntityName = destinationEntity.name
            entityMapping.destinationEntityVersionHash = destinationEntity.versionHash
            entityMapping.mappingType = .addEntityMappingType
            entityMapping.attributeMappings = autoreleasepool { () -> [NSPropertyMapping] in
                
                var attributeMappings: [NSPropertyMapping] = []
                for (_, destinationAttribute) in destinationEntity.attributesByName {
                    
                    let propertyMapping = NSPropertyMapping()
                    propertyMapping.name = destinationAttribute.name
                    propertyMapping.valueExpression = NSExpression(forConstantValue: destinationAttribute.defaultValue)
                    attributeMappings.append(propertyMapping)
                }
                return attributeMappings
            }
            entityMapping.relationshipMappings = autoreleasepool { () -> [NSPropertyMapping] in
                
                var relationshipMappings: [NSPropertyMapping] = []
                for (_, destinationRelationship) in destinationEntity.relationshipsByName {
                    
                    let propertyMapping = NSPropertyMapping()
                    propertyMapping.name = destinationRelationship.name
                    relationshipMappings.append(propertyMapping)
                }
                return relationshipMappings
            }
            entityMappings.append(entityMapping)
        }
        for case .transformEntity(let sourceEntityName, let destinationEntityName, let transformEntity) in transformMappings {
            
            let sourceEntity = sourceEntitiesByName[sourceEntityName]!
            let destinationEntity = destinationEntitiesByName[destinationEntityName]!
            
            let entityMapping = NSEntityMapping()
            entityMapping.sourceEntityName = sourceEntity.name
            entityMapping.sourceEntityVersionHash = sourceEntity.versionHash
            entityMapping.destinationEntityName = destinationEntity.name
            entityMapping.destinationEntityVersionHash = destinationEntity.versionHash
            entityMapping.mappingType = .transformEntityMappingType
            entityMapping.sourceExpression = expression(forSource: sourceEntity)
            entityMapping.attributeMappings = autoreleasepool { () -> [NSPropertyMapping] in
                
                let sourceAttributes = sourceEntity.cs_resolvedAttributeRenamingIdentities()
                let destinationAttributes = sourceEntity.cs_resolvedAttributeRenamingIdentities()
                
                let removedAttributeKeys = Set(sourceAttributes.keys)
                    .subtracting(destinationAttributes.keys)
                let addedAttributeKeys = Set(destinationAttributes.keys)
                    .subtracting(sourceAttributes.keys)
                let copiedAttributeKeys = Set(destinationAttributes.keys)
                    .subtracting(addedAttributeKeys)
                    .subtracting(removedAttributeKeys)
                    .filter({ sourceAttributes[$0]!.versionHash == destinationAttributes[$0]!.versionHash })
                let transformedAttributeKeys = Set(destinationAttributes.keys)
                    .subtracting(addedAttributeKeys)
                    .subtracting(removedAttributeKeys)
                    .subtracting(copiedAttributeKeys)
                
                var attributeMappings: [NSPropertyMapping] = []
//                for attributeKey in removedAttributeKeys {
//                    
//                    let propertyMapping = NSPropertyMapping()
//                    propertyMapping.name = sourceAttributes[attributeKey]!.attribute.name
//                    attributeMappings.append(propertyMapping)
//                }
                for attributeKey in transformedAttributeKeys {
                    
                    let sourceAttribute = sourceAttributes[attributeKey]!.attribute
                    let destinationAttribute = destinationAttributes[attributeKey]!.attribute
                    // TODO: assert valid and invalid transformations
                    let propertyMapping = NSPropertyMapping()
                    propertyMapping.name = destinationAttribute.name
                    propertyMapping.valueExpression = NSExpression(format: "$source.\(sourceAttribute.name)")
                    attributeMappings.append(propertyMapping)
                }
                for attributeKey in copiedAttributeKeys {
                    
                    let sourceAttribute = sourceAttributes[attributeKey]!.attribute
                    let destinationAttribute = destinationAttributes[attributeKey]!.attribute
                    let propertyMapping = NSPropertyMapping()
                    propertyMapping.name = destinationAttribute.name
                    propertyMapping.valueExpression = NSExpression(format: "$source.\(sourceAttribute.name)")
                    attributeMappings.append(propertyMapping)
                }
                for attributeKey in addedAttributeKeys {
                    
                    let destinationAttribute = destinationAttributes[attributeKey]!.attribute
                    let propertyMapping = NSPropertyMapping()
                    propertyMapping.name = destinationAttribute.name
                    propertyMapping.valueExpression = NSExpression(forConstantValue: destinationAttribute.defaultValue)
                    attributeMappings.append(propertyMapping)
                }
                return attributeMappings
            }
            entityMapping.relationshipMappings = autoreleasepool { () -> [NSPropertyMapping] in
                
                let sourceRelationships = source.entity.cs_resolvedRelationshipRenamingIdentities()
                let destinationRelationships = destination.entity.cs_resolvedRelationshipRenamingIdentities()
                
                let removedRelationshipKeys = Set(sourceRelationships.keys)
                    .subtracting(destinationRelationships.keys)
                let addedRelationshipKeys = Set(destinationRelationships.keys)
                    .subtracting(sourceRelationships.keys)
                let copiedRelationshipKeys = Set(destinationRelationships.keys)
                    .subtracting(addedRelationshipKeys)
                    .subtracting(removedRelationshipKeys)
                    .filter({ sourceRelationships[$0]!.versionHash == destinationRelationships[$0]!.versionHash })
                let transformedRelationshipKeys = Set(destinationRelationships.keys)
                    .subtracting(addedRelationshipKeys)
                    .subtracting(removedRelationshipKeys)
                    .subtracting(copiedRelationshipKeys)
                
                var relationshipMappings: [NSPropertyMapping] = []
                for relationshipKey in removedRelationshipKeys {
                    
                    let propertyMapping = NSPropertyMapping()
                    propertyMapping.name = sourceRelationships[relationshipKey]!.relationship.name
                    relationshipMappings.append(propertyMapping)
                }
                for attributeKey in transformedRelationshipKeys {
                    
                    let sourceRelationship = sourceRelationships[attributeKey]!.relationship
                    let destinationRelationship = destinationRelationships[attributeKey]!.relationship
                    // TODO: assert valid and invalid transformations
                    let propertyMapping = NSPropertyMapping()
                    propertyMapping.name = destinationRelationship.name
                    propertyMapping.valueExpression = NSExpression(format: "$source.\(sourceRelationship.name)")
                    relationshipMappings.append(propertyMapping)
                }
                for attributeKey in copiedRelationshipKeys {
                    
                    let sourceRelationship = sourceRelationships[attributeKey]!.relationship
                    let destinationRelationship = destinationRelationships[attributeKey]!.relationship
                    let propertyMapping = NSPropertyMapping()
                    propertyMapping.name = destinationRelationship.name
                    propertyMapping.valueExpression = NSExpression(format: "$source.\(sourceRelationship.name)")
                    relationshipMappings.append(propertyMapping)
                }
                for attributeKey in addedRelationshipKeys {
                    
                    let destinationRelationship = destinationRelationships[attributeKey]!.relationship
                    let propertyMapping = NSPropertyMapping()
                    propertyMapping.name = destinationRelationship.name
                    relationshipMappings.append(propertyMapping)
                }
                return relationshipMappings
            }
            entityMappings.append(entityMapping)
        }
        for entityKey in copiedEntityKeys {
            
            let source = sourceEntities[entityKey]!
            let destination = destinationEntities[entityKey]!
            
            let entityMapping = NSEntityMapping()
            entityMapping.sourceEntityName = source.entity.name
            entityMapping.sourceEntityVersionHash = source.versionHash
            entityMapping.destinationEntityName = destination.entity.name
            entityMapping.destinationEntityVersionHash = destination.versionHash
            entityMapping.mappingType = .copyEntityMappingType
            entityMapping.sourceExpression = expression(forSource: source.entity)
            entityMapping.attributeMappings = autoreleasepool { () -> [NSPropertyMapping] in
                
                var attributeMappings: [NSPropertyMapping] = []
                for (_, sourceAttribute) in source.entity.attributesByName {
                    
                    let propertyMapping = NSPropertyMapping()
                    propertyMapping.name = sourceAttribute.name
                    propertyMapping.valueExpression = NSExpression(format: "$source.\(sourceAttribute.name)")
                    attributeMappings.append(propertyMapping)
                }
                return attributeMappings
            }
            entityMapping.relationshipMappings = autoreleasepool { () -> [NSPropertyMapping] in
                
                var relationshipMappings: [NSPropertyMapping] = []
                for (_, sourceRelationship) in source.entity.relationshipsByName {
                    
                    let propertyMapping = NSPropertyMapping()
                    propertyMapping.name = sourceRelationship.name
                    propertyMapping.valueExpression = NSExpression(format: "$source.\(sourceRelationship.name)")
                    relationshipMappings.append(propertyMapping)
                }
                return relationshipMappings
            }
            entityMappings.append(entityMapping)
        }
        
        mappingModel.entityMappings = entityMappings
        return (
            mappingModel,
            .heavyweight(
                sourceVersion: self.sourceVersion,
                destinationVersion: self.destinationVersion
            )
        )
    }
    
    
    // MARK: Private
    
    // MARK: - CustomEntityMigrationPolicy
    
    private final class CustomEntityMigrationPolicy: NSEntityMigrationPolicy {
        
        override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
            
            try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
        }
        
        override func createRelationships(forDestination dInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
            
            try super.createRelationships(forDestination: dInstance, in: mapping, manager: manager)
        }
    }
    
    
    // MARK: -
    
    private let entityMappings: Set<CustomMapping>
    
    private func resolveEntityMappings(sourceModel: NSManagedObjectModel, destinationModel: NSManagedObjectModel) -> (delete: Set<CustomMapping>, insert: Set<CustomMapping>, transform: Set<CustomMapping>) {
        
        var deleteMappings: Set<CustomMapping> = []
        var insertMappings: Set<CustomMapping> = []
        var transformMappings: Set<CustomMapping> = []
        var allMappedSourceKeys: [KeyPath: KeyPath] = [:]
        var allMappedDestinationKeys: [KeyPath: KeyPath] = [:]
        
        let sourceRenamingIdentifiers = sourceModel.cs_resolvedRenamingIdentities()
        let sourceEntityNames = sourceModel.entitiesByName
        let destinationRenamingIdentifiers = destinationModel.cs_resolvedRenamingIdentities()
        let destinationEntityNames = destinationModel.entitiesByName
        
        let removedRenamingIdentifiers = Set(sourceRenamingIdentifiers.keys)
            .subtracting(destinationRenamingIdentifiers.keys)
        let addedRenamingIdentifiers = Set(destinationRenamingIdentifiers.keys)
            .subtracting(sourceRenamingIdentifiers.keys)
        let transformedRenamingIdentifiers = Set(destinationRenamingIdentifiers.keys)
            .subtracting(addedRenamingIdentifiers)
            .subtracting(removedRenamingIdentifiers)
        
        // First pass: resolve source-destination entities
        for mapping in self.entityMappings {
            
            switch mapping {
                
            case .deleteEntity(let sourceEntity):
                CoreStore.assert(
                    sourceEntityNames[sourceEntity] != nil,
                    "A \(cs_typeName(CustomMapping.self)) with value '\(mapping)' passed to \(cs_typeName(CustomSchemaMappingProvider.self)) could not be mapped to any \(cs_typeName(NSEntityDescription.self)) from the source \(cs_typeName(NSManagedObjectModel.self))."
                )
                CoreStore.assert(
                    allMappedSourceKeys[sourceEntity] == nil,
                    "Duplicate \(cs_typeName(CustomMapping.self))s found for source entity name \"\(sourceEntity)\" in \(cs_typeName(CustomSchemaMappingProvider.self))."
                )
                deleteMappings.insert(mapping)
                allMappedSourceKeys[sourceEntity] = ""
                
            case .insertEntity(let destinationEntity):
                CoreStore.assert(
                    destinationEntityNames[destinationEntity] != nil,
                    "A \(cs_typeName(CustomMapping.self)) with value '\(mapping)' passed to \(cs_typeName(CustomSchemaMappingProvider.self)) could not be mapped to any \(cs_typeName(NSEntityDescription.self)) from the destination \(cs_typeName(NSManagedObjectModel.self))."
                )
                CoreStore.assert(
                    allMappedDestinationKeys[destinationEntity] == nil,
                    "Duplicate \(cs_typeName(CustomMapping.self))s found for destination entity name \"\(destinationEntity)\" in \(cs_typeName(CustomSchemaMappingProvider.self))."
                )
                insertMappings.insert(mapping)
                allMappedDestinationKeys[destinationEntity] = ""
                
            case .transformEntity(let sourceEntity, let destinationEntity, _):
                CoreStore.assert(
                    sourceEntityNames[sourceEntity] != nil,
                    "A \(cs_typeName(CustomMapping.self)) with value '\(mapping)' passed to \(cs_typeName(CustomSchemaMappingProvider.self)) could not be mapped to any \(cs_typeName(NSEntityDescription.self)) from the source \(cs_typeName(NSManagedObjectModel.self))."
                )
                CoreStore.assert(
                    destinationEntityNames[destinationEntity] != nil,
                    "A \(cs_typeName(CustomMapping.self)) with value '\(mapping)' passed to \(cs_typeName(CustomSchemaMappingProvider.self)) could not be mapped to any \(cs_typeName(NSEntityDescription.self)) from the destination \(cs_typeName(NSManagedObjectModel.self))."
                )
                CoreStore.assert(
                    allMappedSourceKeys[sourceEntity] == nil,
                    "Duplicate \(cs_typeName(CustomMapping.self))s found for source entity name \"\(sourceEntity)\" in \(cs_typeName(CustomSchemaMappingProvider.self))."
                )
                CoreStore.assert(
                    allMappedDestinationKeys[destinationEntity] == nil,
                    "Duplicate \(cs_typeName(CustomMapping.self))s found for destination entity name \"\(destinationEntity)\" in \(cs_typeName(CustomSchemaMappingProvider.self))."
                )
                transformMappings.insert(mapping)
                allMappedSourceKeys[sourceEntity] = destinationEntity
                allMappedDestinationKeys[destinationEntity] = sourceEntity
            }
            
            for renamingIdentifier in transformedRenamingIdentifiers {
                
                let sourceEntity = sourceRenamingIdentifiers[renamingIdentifier]!.entity
                let destinationEntity = destinationRenamingIdentifiers[renamingIdentifier]!.entity
                let sourceEntityName = sourceEntity.name!
                let destinationEntityName = destinationEntity.name!
                switch (allMappedSourceKeys[sourceEntityName], allMappedDestinationKeys[destinationEntityName]) {
                    
                case (nil, nil):
                    transformMappings.insert(
                        .transformEntity(
                            sourceEntity: sourceEntityName,
                            destinationEntity: destinationEntityName,
                            transformEntity: CustomMapping.inferredTransformation
                        )
                    )
                    allMappedSourceKeys[sourceEntityName] = destinationEntityName
                    allMappedDestinationKeys[destinationEntityName] = sourceEntityName
                    
                case (""?, nil):
                    insertMappings.insert(.insertEntity(destinationEntity: destinationEntityName))
                    allMappedDestinationKeys[destinationEntityName] = ""
                    
                case (nil, ""?):
                    deleteMappings.insert(.deleteEntity(sourceEntity: sourceEntityName))
                    allMappedSourceKeys[sourceEntityName] = ""
                    
                default:
                    continue
                }
            }
            for renamingIdentifier in removedRenamingIdentifiers {
                
                let sourceEntity = sourceRenamingIdentifiers[renamingIdentifier]!.entity
                let sourceEntityName = sourceEntity.name!
                switch allMappedSourceKeys[sourceEntityName] {
                    
                case nil:
                    deleteMappings.insert(.deleteEntity(sourceEntity: sourceEntityName))
                    allMappedSourceKeys[sourceEntityName] = ""
                    
                default:
                    continue
                }
            }
            for renamingIdentifier in addedRenamingIdentifiers {
                
                let destinationEntity = destinationRenamingIdentifiers[renamingIdentifier]!.entity
                let destinationEntityName = destinationEntity.name!
                switch allMappedDestinationKeys[destinationEntityName] {
                    
                case nil:
                    insertMappings.insert(.insertEntity(destinationEntity: destinationEntityName))
                    allMappedDestinationKeys[destinationEntityName] = ""
                    
                default:
                    continue
                }
            }
        }
        return (deleteMappings, insertMappings, transformMappings)
    }
}
