//
//  CSDataStack+Migrating.swift
//  CoreStore
//
//  Copyright © 2016 John Rommel Estropia
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


// MARK: - CSDataStack

public extension CSDataStack {
    
//    /**
//     Asynchronously adds a `StorageInterface` to the stack. Migrations are also initiated by default.
//     ```
//     try dataStack.addStorage(
//     InMemoryStore(configuration: "Config1"),
//     completion: { result in
//     switch result {
//     case .Success(let storage): // ...
//     case .Failure(let error): // ...
//     }
//     }
//     )
//     ```
//     - parameter storage: the local storage
//     - parameter completion: the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `SetupResult` argument indicates the result. This closure is NOT executed if an error is thrown, but will be executed with a `.Failure` result if an error occurs asynchronously.
//     - returns: an `NSProgress` instance if a migration has started, or `nil` is no migrations are required
//     */
//    public func addStorage(storage: StorageInterface, completion: (SetupResult<T>) -> Void) throws -> NSProgress? {
//        
//        self.coordinator.performAsynchronously {
//            
//            if let _ = self.persistentStoreForStorage(storage) {
//                
//                GCDQueue.Main.async {
//                    
//                    completion(SetupResult(storage))
//                }
//                return
//            }
//            
//            do {
//                
//                try self.createPersistentStoreFromStorage(
//                    storage,
//                    finalURL: nil,
//                    finalStoreOptions: storage.storeOptions
//                )
//                
//                GCDQueue.Main.async {
//                    
//                    completion(SetupResult(storage))
//                }
//            }
//            catch {
//                
//                let storeError = CoreStoreError(error)
//                CoreStore.log(
//                    storeError,
//                    "Failed to add \(typeName(storage)) to the stack."
//                )
//                
//                GCDQueue.Main.async {
//                    
//                    completion(SetupResult(storeError))
//                }
//            }
//        }
//        
//        return nil
//    }
//    
//    /**
//     Asynchronously adds a `LocalStorage` with default settings to the stack. Migrations are also initiated by default.
//     ```
//     try dataStack.addStorage(
//     SQLiteStore.self,
//     completion: { result in
//     switch result {
//     case .Success(let storage): // ...
//     case .Failure(let error): // ...
//     }
//     }
//     )
//     ```
//     - parameter storeType: the local storage type
//     - parameter completion: the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `SetupResult` argument indicates the result. This closure is NOT executed if an error is thrown, but will be executed with a `.Failure` result if an error occurs asynchronously. Note that the `LocalStorage` associated to the `SetupResult.Success` may not always be the same instance as the parameter argument if a previous `LocalStorage` was already added at the same URL and with the same configuration.
//     - returns: an `NSProgress` instance if a migration has started, or `nil` is no migrations are required
//     */
//    public func addStorage<T: LocalStorage where T: DefaultInitializableStore>(storeType: T.Type, completion: (SetupResult<T>) -> Void) throws -> NSProgress? {
//        
//        return try self.addStorage(storeType.init(), completion: completion)
//    }
//    
//    /**
//     Asynchronously adds a `LocalStorage` to the stack. Migrations are also initiated by default.
//     ```
//     try dataStack.addStorage(
//     SQLiteStore(configuration: "Config1"),
//     completion: { result in
//     switch result {
//     case .Success(let storage): // ...
//     case .Failure(let error): // ...
//     }
//     }
//     )
//     ```
//     - parameter storage: the local storage
//     - parameter completion: the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `SetupResult` argument indicates the result. This closure is NOT executed if an error is thrown, but will be executed with a `.Failure` result if an error occurs asynchronously. Note that the `LocalStorage` associated to the `SetupResult.Success` may not always be the same instance as the parameter argument if a previous `LocalStorage` was already added at the same URL and with the same configuration.
//     - returns: an `NSProgress` instance if a migration has started, or `nil` is no migrations are required
//     */
//    public func addStorage<T: LocalStorage>(storage: T, completion: (SetupResult<T>) -> Void) throws -> NSProgress? {
//        
//        let fileURL = storage.fileURL
//        CoreStore.assert(
//            fileURL.fileURL,
//            "The specified URL for the \(typeName(storage)) is invalid: \"\(fileURL)\""
//        )
//        
//        return try self.coordinator.performSynchronously {
//            
//            if let _ = self.persistentStoreForStorage(storage) {
//                
//                GCDQueue.Main.async {
//                    
//                    completion(SetupResult(storage))
//                }
//                return nil
//            }
//            
//            if let persistentStore = self.coordinator.persistentStoreForURL(fileURL) {
//                
//                if let existingStorage = persistentStore.storageInterface as? T
//                    where storage.matchesPersistentStore(persistentStore) {
//                    
//                    GCDQueue.Main.async {
//                        
//                        completion(SetupResult(existingStorage))
//                    }
//                    return nil
//                }
//                
//                let error = CoreStoreError.DifferentStorageExistsAtURL(existingPersistentStoreURL: fileURL)
//                CoreStore.log(
//                    error,
//                    "Failed to add \(typeName(storage)) at \"\(fileURL)\" because a different \(typeName(NSPersistentStore)) at that URL already exists."
//                )
//                throw error
//            }
//            
//            do {
//                
//                try NSFileManager.defaultManager().createDirectoryAtURL(
//                    fileURL.URLByDeletingLastPathComponent!,
//                    withIntermediateDirectories: true,
//                    attributes: nil
//                )
//                
//                let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
//                    storage.dynamicType.storeType,
//                    URL: fileURL,
//                    options: storage.storeOptions
//                )
//                
//                return self.upgradeStorageIfNeeded(
//                    storage,
//                    metadata: metadata,
//                    completion: { (result) -> Void in
//                        
//                        if case .Failure(.InternalError(let error)) = result {
//                            
//                            if storage.localStorageOptions.contains(.RecreateStoreOnModelMismatch) && error.isCoreDataMigrationError {
//                                
//                                do {
//                                    
//                                    try _ = self.model[metadata].flatMap(storage.eraseStorageAndWait)
//                                    try self.addStorageAndWait(storage)
//                                    
//                                    GCDQueue.Main.async {
//                                        
//                                        completion(SetupResult(storage))
//                                    }
//                                }
//                                catch {
//                                    
//                                    completion(SetupResult(error))
//                                }
//                                return
//                            }
//                            
//                            completion(SetupResult(error))
//                            return
//                        }
//                        
//                        do {
//                            
//                            try self.addStorageAndWait(storage)
//                            
//                            completion(SetupResult(storage))
//                        }
//                        catch {
//                            
//                            completion(SetupResult(error))
//                        }
//                    }
//                )
//            }
//            catch let error as NSError
//                where error.code == NSFileReadNoSuchFileError && error.domain == NSCocoaErrorDomain {
//                    
//                    try self.addStorageAndWait(storage)
//                    
//                    GCDQueue.Main.async {
//                        
//                        completion(SetupResult(storage))
//                    }
//                    return nil
//            }
//            catch {
//                
//                let storeError = CoreStoreError(error)
//                CoreStore.log(
//                    storeError,
//                    "Failed to load SQLite \(typeName(NSPersistentStore)) metadata."
//                )
//                throw storeError
//            }
//        }
//    }
//    
//    /**
//     Migrates a local storage to match the `DataStack`'s managed object model version. This method does NOT add the migrated store to the data stack.
//     
//     - parameter storage: the local storage
//     - parameter completion: the closure to be executed on the main queue when the migration completes, either due to success or failure. The closure's `MigrationResult` argument indicates the result. This closure is NOT executed if an error is thrown, but will be executed with a `.Failure` result if an error occurs asynchronously.
//     - returns: an `NSProgress` instance if a migration has started, or `nil` is no migrations are required
//     */
//    public func upgradeStorageIfNeeded<T: LocalStorage>(storage: T, completion: (MigrationResult) -> Void) throws -> NSProgress? {
//        
//        return try self.coordinator.performSynchronously {
//            
//            let fileURL = storage.fileURL
//            do {
//                
//                CoreStore.assert(
//                    self.persistentStoreForStorage(storage) == nil,
//                    "Attempted to migrate an already added \(typeName(storage)) at URL \"\(fileURL)\""
//                )
//                
//                let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
//                    storage.dynamicType.storeType,
//                    URL: fileURL,
//                    options: storage.storeOptions
//                )
//                return self.upgradeStorageIfNeeded(
//                    storage,
//                    metadata: metadata,
//                    completion: completion
//                )
//            }
//            catch {
//                
//                let metadataError = CoreStoreError(error)
//                CoreStore.log(
//                    metadataError,
//                    "Failed to load \(typeName(storage)) metadata from URL \"\(fileURL)\"."
//                )
//                throw metadataError
//            }
//        }
//    }
//    
//    /**
//     Checks the migration steps required for the storage to match the `DataStack`'s managed object model version.
//     
//     - parameter storage: the local storage
//     - returns: a `MigrationType` array indicating the migration steps required for the store, or an empty array if the file does not exist yet. Otherwise, an error is thrown if either inspection of the store failed, or if no mapping model was found/inferred.
//     */
//    @warn_unused_result
//    public func requiredMigrationsForStorage<T: LocalStorage>(storage: T) throws -> [MigrationType] {
//        
//        return try self.coordinator.performSynchronously {
//            
//            let fileURL = storage.fileURL
//            
//            CoreStore.assert(
//                self.persistentStoreForStorage(storage) == nil,
//                "Attempted to query required migrations for an already added \(typeName(storage)) at URL \"\(fileURL)\""
//            )
//            do {
//                
//                let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
//                    storage.dynamicType.storeType,
//                    URL: fileURL,
//                    options: storage.storeOptions
//                )
//                
//                guard let migrationSteps = self.computeMigrationFromStorage(storage, metadata: metadata) else {
//                    
//                    let error = CoreStoreError.MappingModelNotFound(
//                        localStoreURL: fileURL,
//                        targetModel: self.model,
//                        targetModelVersion: self.modelVersion
//                    )
//                    CoreStore.log(
//                        error,
//                        "Failed to find migration steps from the \(typeName(storage)) at URL \"\(fileURL)\" to version model \"\(self.modelVersion)\"."
//                    )
//                    throw error
//                }
//                
//                if migrationSteps.count > 1 && storage.localStorageOptions.contains(.PreventProgressiveMigration) {
//                    
//                    let error = CoreStoreError.ProgressiveMigrationRequired(localStoreURL: fileURL)
//                    CoreStore.log(
//                        error,
//                        "Failed to find migration mapping from the \(typeName(storage)) at URL \"\(fileURL)\" to version model \"\(self.modelVersion)\" without requiring progessive migrations."
//                    )
//                    throw error
//                }
//                
//                return migrationSteps.map { $0.migrationType }
//            }
//            catch let error as NSError
//                where error.code == NSFileReadNoSuchFileError && error.domain == NSCocoaErrorDomain {
//                    
//                    return []
//            }
//            catch {
//                
//                let metadataError = CoreStoreError(error)
//                CoreStore.log(
//                    metadataError,
//                    "Failed to load \(typeName(storage)) metadata from URL \"\(fileURL)\"."
//                )
//                throw metadataError
//            }
//        }
//    }
}