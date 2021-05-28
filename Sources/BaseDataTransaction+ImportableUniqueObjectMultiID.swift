//
//  File.swift
//
//
//  Created by Sergio Hurtado on 28/5/21.
//

import CoreData
import Foundation

public protocol ImportableUniqueObjectMultiID: ImportableUniqueObject {
    static var optionalUUIDKeyPath: String? { get }
    var optionalUUID: UUID? { get }
    
    static func uniqueUUID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> UUID?
    
    func shouldUpdate(in transaction: BaseDataTransaction) -> Bool
}

extension BaseDataTransaction {
    func fetchOne<O: ImportableUniqueObjectMultiID>(object: O) throws -> O? {
        let uniqueIDKeyPath = O.uniqueIDKeyPath
        let uniqueIDValue = object.uniqueIDValue
        var uniqueIDValueWhere = Where<O>(uniqueIDKeyPath, isEqualTo: uniqueIDValue)
        
        if let uuid = object.optionalUUID, let uuidKeyPath = O.optionalUUIDKeyPath {
            uniqueIDValueWhere = uniqueIDValueWhere || Where<O>(uuidKeyPath, isEqualTo: uuid)
        }
        
        return try self.fetchOne(From(O.self), uniqueIDValueWhere)
    }
    
    func importUUIDUniqueObject<O: ImportableUniqueObjectMultiID>(_ into: Into<O>,
                                                                  source: O.ImportSource) throws -> O?
    {
        Internals.assert(
            self.isRunningInAllowedQueue(),
            "Attempted to import an object of type \(Internals.typeName(into.entityClass)) outside the transaction's designated queue."
        )
         
        return try autoreleasepool {
            let entityType = into.entityClass
            let uniqueIDKeyPath = entityType.uniqueIDKeyPath
            guard let uniqueIDValue = try entityType.uniqueID(from: source, in: self) else {
                return nil
            }
            
            var uniqueIDValueWhere = Where<O>(uniqueIDKeyPath, isEqualTo: uniqueIDValue)
            
            if let uuid = try entityType.uniqueUUID(from: source, in: self), let uuidKeyPath = O.optionalUUIDKeyPath {
                uniqueIDValueWhere = uniqueIDValueWhere || Where<O>(uuidKeyPath, isEqualTo: uuid)
            }
            
            if let object = try self.fetchOne(From(entityType), uniqueIDValueWhere) {
                guard entityType.shouldUpdate(from: source, in: self) else {
                    return nil
                }
                try object.update(from: source, in: self)
                return object
            }
            else {
                guard entityType.shouldInsert(from: source, in: self) else {
                    return nil
                }
                let object = self.create(into)
                object.uniqueIDValue = uniqueIDValue
                try object.didInsert(from: source, in: self)
                return object
            }
        }
    }
    
    public func importUUIDUniqueObjects<O: ImportableUniqueObjectMultiID, S: Sequence>(_ into: Into<O>, sourceArray: S) throws -> [O] where S.Iterator.Element == O.ImportSource {
        Internals.assert(
            self.isRunningInAllowedQueue(),
            "Attempted to import an object of type \(Internals.typeName(into.entityClass)) outside the transaction's designated queue."
        )
        
        return try autoreleasepool {
           
            
            let entityType = into.entityClass
            var importSourceByID = [(source: S.Element, uniqueID: O.UniqueIDType, uuid: UUID?)]()
            
            var sortedIDs: [O.UniqueIDType] = []
            var sortedUUIDs: [UUID] = []
            
            try autoreleasepool {
                for source in sourceArray {
                    guard let uniqueIDValue = try O.uniqueID(from: source, in: self) else { continue }
                    let uuid = try O.uniqueUUID(from: source, in: self)
                    
                    sortedIDs.append(uniqueIDValue)
                    
                    if let uuid = uuid {
                        sortedUUIDs.append(uuid)
                    }
                    
                    importSourceByID.append((source: source, uniqueID: uniqueIDValue, uuid: uuid))
                }
            }
            
            var uniqueIDValueWhere = Where<O>(O.uniqueIDKeyPath, isMemberOf: sortedIDs)
            
            if sortedUUIDs.isEmpty == false, let uuidKeyPath = O.optionalUUIDKeyPath {
                uniqueIDValueWhere = uniqueIDValueWhere || Where<O>(uuidKeyPath, isMemberOf: sortedUUIDs)
            }
            let groupBy = GroupBy<O>(["objectID"])
            
            var existingObjectsByID = [NSManagedObjectID: O]()
            
            try autoreleasepool {
                try self.fetchAll(From(entityType), [uniqueIDValueWhere, groupBy])
                    .forEach { existingObjectsByID[$0.cs_id()] = $0 }
            }
            
            autoreleasepool {
                let insertedObjects = self.context.insertedObjects
                    .compactMap { O.cs_matches(object: $0) ? ($0.cs_id(), O.cs_fromRaw(object: $0)) : nil }
                
                existingObjectsByID.merge(insertedObjects) { _, new in
                    new
                }
            }
            
            var result = [O]()
            
            for existingObject in existingObjectsByID {
                guard let sourceIndex = importSourceByID.firstIndex(where: { _, uniqueID, uuid in
                    let object = existingObject.value
                    return object.uniqueIDValue == uniqueID || object.optionalUUID == uuid
                }) else { continue }
                
                let sourceInfo = importSourceByID[sourceIndex]
                importSourceByID.remove(at: sourceIndex)
                
                try autoreleasepool {
                    guard entityType.shouldUpdate(from: sourceInfo.source, in: self) else { return }
                    guard existingObject.value.shouldUpdate(in: self) else { return }
                    
                    try existingObject.value.update(from: sourceInfo.source, in: self)
                    result.append(existingObject.value)
                }
            }
            
            for sourceInfo in importSourceByID {
                if entityType.shouldInsert(from: sourceInfo.source, in: self) {
                    try autoreleasepool {
                        let object = self.create(into)
                    
                        try object.didInsert(from: sourceInfo.source, in: self)
                        result.append(object)
                    }
                }
            }
            
            return result
        }
    }
}
