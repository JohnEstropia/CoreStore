//
//  BaseDataTransaction+Importing.swift
//  CoreStore
//
//  Copyright (c) 2015 John Rommel Estropia
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

import Foundation
import CoreData


public protocol ImportableObject: class {
    
    typealias ImportSource
    
    static func shouldInsertFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) -> Bool
    
    func didInsertFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) throws
}

public extension ImportableObject {
    
    static func shouldInsertFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) -> Bool {
        
        return true
    }
}


public protocol ImportableUniqueObject: ImportableObject {
    
    typealias UniqueIDType: NSObject
    
    static var uniqueIDKeyPath: String { get }
    
    var uniqueIDValue: UniqueIDType { get set }
    
    static func uniqueIDFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) throws -> UniqueIDType?
    
    static func shouldUpdateFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) -> Bool
    
    func updateFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) throws
}


public extension ImportableUniqueObject {
    
    static func shouldUpdateFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) -> Bool {
        
        return true
    }
    
    func didInsertFromImportSource(source: ImportSource, inTransaction transaction: BaseDataTransaction) throws {
        
        try self.updateFromImportSource(source, inTransaction: transaction)
    }
}


public extension BaseDataTransaction {
    
    func importObject<T where T: NSManagedObject, T: ImportableObject>(
        into: Into<T>,
        source: T.ImportSource) throws -> T? {
            
            CoreStore.assert(
                self.bypassesQueueing || self.transactionQueue.isCurrentExecutionContext(),
                "Attempted to import an object of type \(typeName(into.entityClass)) outside the transaction's designated queue."
            )
            
            return try autoreleasepool {
                
                guard T.shouldInsertFromImportSource(source, inTransaction: self) else {
                    
                    return nil
                }
                
                let object = self.create(into)
                try object.didInsertFromImportSource(source, inTransaction: self)
                return object
            }
    }
    
    func importObjects<T where T: NSManagedObject, T: ImportableObject>(
        into: Into<T>,
        sourceArray: [T.ImportSource]) throws {
            
            CoreStore.assert(
                self.bypassesQueueing || self.transactionQueue.isCurrentExecutionContext(),
                "Attempted to import an object of type \(typeName(into.entityClass)) outside the transaction's designated queue."
            )
            
            try autoreleasepool {
                
                for source in sourceArray {
                    
                    guard T.shouldInsertFromImportSource(source, inTransaction: self) else {
                        
                        continue
                    }
                    
                    try autoreleasepool {
                        
                        let object = self.create(into)
                        try object.didInsertFromImportSource(source, inTransaction: self)
                    }
                }
            }
    }
    
    func importObjects<T where T: NSManagedObject, T: ImportableObject>(
        into: Into<T>,
        sourceArray: [T.ImportSource],
        postProcess: (sorted: [T]) -> Void) throws {
            
            CoreStore.assert(
                self.bypassesQueueing || self.transactionQueue.isCurrentExecutionContext(),
                "Attempted to import an object of type \(typeName(into.entityClass)) outside the transaction's designated queue."
            )
            
            try autoreleasepool {
                
                var objects = [T]()
                for source in sourceArray {
                    
                    guard T.shouldInsertFromImportSource(source, inTransaction: self) else {
                        
                        continue
                    }
                    
                    try autoreleasepool {
                        
                        let object = self.create(into)
                        try object.didInsertFromImportSource(source, inTransaction: self)
                        
                        objects.append(object)
                    }
                }
                postProcess(sorted: objects)
            }
    }
    
    func importUniqueObject<T where T: NSManagedObject, T: ImportableUniqueObject>(
        into: Into<T>,
        source: T.ImportSource) throws -> T?  {
            
            CoreStore.assert(
                self.bypassesQueueing || self.transactionQueue.isCurrentExecutionContext(),
                "Attempted to import an object of type \(typeName(into.entityClass)) outside the transaction's designated queue."
            )
            
            return try autoreleasepool {
                
                let uniqueIDKeyPath = T.uniqueIDKeyPath
                guard let uniqueIDValue = try T.uniqueIDFromImportSource(source, inTransaction: self) else {
                    
                    return nil
                }
                
                if let object = self.fetchOne(From(T), Where(uniqueIDKeyPath, isEqualTo: uniqueIDValue)) {
                    
                    try object.updateFromImportSource(source, inTransaction: self)
                    return object
                }
                else {
                    
                    guard T.shouldInsertFromImportSource(source, inTransaction: self) else {
                        
                        return nil
                    }
                    
                    let object = self.create(into)
                    object.uniqueIDValue = uniqueIDValue
                    try object.didInsertFromImportSource(source, inTransaction: self)
                    return object
                }
            }
    }
    
    func importUniqueObjects<T where T: NSManagedObject, T: ImportableUniqueObject>(
        into: Into<T>,
        sourceArray: [T.ImportSource],
        preProcess: ((mapping: [T.UniqueIDType: T.ImportSource]) throws -> [T.UniqueIDType: T.ImportSource])? = nil) throws {
            
            CoreStore.assert(
                self.bypassesQueueing || self.transactionQueue.isCurrentExecutionContext(),
                "Attempted to import an object of type \(typeName(into.entityClass)) outside the transaction's designated queue."
            )
            
            try autoreleasepool {
                
                var mapping = Dictionary<T.UniqueIDType, T.ImportSource>()
                for source in sourceArray {
                    
                    try autoreleasepool {
                        
                        guard let uniqueIDValue = try T.uniqueIDFromImportSource(source, inTransaction: self) else {
                            
                            return
                        }
                        
                        mapping[uniqueIDValue] = source
                    }
                }
                
                if let preProcess = preProcess {
                    
                    try autoreleasepool {
                        
                        mapping = try preProcess(mapping: mapping)
                    }
                }
                
                for object in self.fetchAll(From(T), Where(T.uniqueIDKeyPath, isMemberOf: mapping.keys)) ?? [] {
                    
                    try autoreleasepool {
                        
                        let uniqueIDValue = object.uniqueIDValue
                        
                        guard let source = mapping.removeValueForKey(uniqueIDValue)
                            where T.shouldUpdateFromImportSource(source, inTransaction: self) else {
                                
                                return
                        }
                        
                        try object.updateFromImportSource(source, inTransaction: self)
                    }
                }
                
                for (uniqueIDValue, source) in mapping {
                    
                    try autoreleasepool {
                        
                        guard T.shouldInsertFromImportSource(source, inTransaction: self) else {
                            
                            return
                        }
                        
                        let object = self.create(into)
                        object.uniqueIDValue = uniqueIDValue
                        try object.didInsertFromImportSource(source, inTransaction: self)
                    }
                }
            }
    }
    
    func importUniqueObjects<T where T: NSManagedObject, T: ImportableUniqueObject>(
        into: Into<T>,
        sourceArray: [T.ImportSource],
        preProcess: ((mapping: [T.UniqueIDType: T.ImportSource]) throws -> [T.UniqueIDType: T.ImportSource])? = nil,
        postProcess: (sorted: [T]) -> Void) throws {
            
            CoreStore.assert(
                self.bypassesQueueing || self.transactionQueue.isCurrentExecutionContext(),
                "Attempted to import an object of type \(typeName(into.entityClass)) outside the transaction's designated queue."
            )
            
            try autoreleasepool {
                
                var sortedIDs = Array<T.UniqueIDType>()
                var mapping = Dictionary<T.UniqueIDType, T.ImportSource>()
                for source in sourceArray {
                    
                    try autoreleasepool {
                        
                        guard let uniqueIDValue = try T.uniqueIDFromImportSource(source, inTransaction: self) else {
                            
                            return
                        }
                        
                        mapping[uniqueIDValue] = source
                        sortedIDs.append(uniqueIDValue)
                    }
                }
                
                if let preProcess = preProcess {
                    
                    try autoreleasepool {
                        
                        mapping = try preProcess(mapping: mapping)
                    }
                }
                
                var objects = Dictionary<T.UniqueIDType, T>()
                for object in self.fetchAll(From(T), Where(T.uniqueIDKeyPath, isMemberOf: mapping.keys)) ?? [] {
                    
                    try autoreleasepool {
                        
                        let uniqueIDValue = object.uniqueIDValue
                        
                        guard let source = mapping.removeValueForKey(uniqueIDValue)
                            where T.shouldUpdateFromImportSource(source, inTransaction: self) else {
                                
                                return
                        }
                        
                        try object.updateFromImportSource(source, inTransaction: self)
                        objects[uniqueIDValue] = object
                    }
                }
                
                for (uniqueIDValue, source) in mapping {
                    
                    try autoreleasepool {
                        
                        guard T.shouldInsertFromImportSource(source, inTransaction: self) else {
                            
                            return
                        }
                        
                        let object = self.create(into)
                        object.uniqueIDValue = uniqueIDValue
                        try object.didInsertFromImportSource(source, inTransaction: self)
                        
                        objects[uniqueIDValue] = object
                    }
                }
                
                postProcess(sorted: sortedIDs.flatMap { objects[$0] })
            }
    }
}
