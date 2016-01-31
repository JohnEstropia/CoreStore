//
//  DataStack+iCloud.swift
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
#if USE_FRAMEWORKS
    import GCDKit
#endif

public extension DataStack {
    
    public func addICloudStore(ubiquitousContentName: String, ubiquitousContentURLRelativePath: String? = nil, ubiquitousContainerID: String? = nil, ubiquitousPeerToken: String? = nil, configuration: String? = nil, mappingModelBundles: [NSBundle]? = NSBundle.allBundles(), automigrating: Bool, resetStoreOnModelMismatch: Bool = false, completion: (PersistentStoreResult) -> Void) throws -> NSProgress? {
        
        CoreStore.assert(
            !ubiquitousContentName.isEmpty,
            "The ubiquitousContentName cannot be empty."
        )
        CoreStore.assert(
            !ubiquitousContentName.containsString("."),
            "The ubiquitousContentName cannot contain periods."
        )
        CoreStore.assert(
            ubiquitousContentURLRelativePath?.isEmpty != true,
            "The ubiquitousContentURLRelativePath should not be empty if provided."
        )
        CoreStore.assert(
            ubiquitousPeerToken?.isEmpty != true,
            "The ubiquitousPeerToken should not be empty if provided."
        )
        
        let fileManager = NSFileManager.defaultManager()
        guard let fileURL = fileManager.URLForUbiquityContainerIdentifier(ubiquitousContainerID) else {
            
            throw NSError(coreStoreErrorCode: .ICloudContainerNotFound)
        }
        
        let coordinator = self.coordinator;
        if let store = coordinator.persistentStoreForURL(fileURL) {
            
            guard store.type == NSSQLiteStoreType
                && store.configurationName == (configuration ?? Into.defaultConfigurationName) else {
                    
                    let error = NSError(coreStoreErrorCode: .DifferentPersistentStoreExistsAtURL)
                    CoreStore.handleError(
                        error,
                        "Failed to add SQLite \(typeName(NSPersistentStore)) at \"\(fileURL)\" because a different \(typeName(NSPersistentStore)) at that URL already exists."
                    )
                    throw error
            }
            
            GCDQueue.Main.async {
                
                completion(PersistentStoreResult(store))
            }
            return nil
        }
        
        _ = try? fileManager.createDirectoryAtURL(
            fileURL.URLByDeletingLastPathComponent!,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        var options = self.optionsForSQLiteStore()
        options[NSPersistentStoreUbiquitousContentNameKey] = ubiquitousContentName
        options[NSMigratePersistentStoresAutomaticallyOption] = automigrating
        options[NSInferMappingModelAutomaticallyOption] = automigrating
        
        if let ubiquitousContentURLRelativePath = ubiquitousContentURLRelativePath {
            
            options[NSPersistentStoreUbiquitousContentURLKey] = ubiquitousContentURLRelativePath
        }
        if let ubiquitousContainerID = ubiquitousContainerID {
            
            options[NSPersistentStoreUbiquitousContainerIdentifierKey] = ubiquitousContainerID
        }
        if let ubiquitousPeerToken = ubiquitousPeerToken {
            
            options[NSPersistentStoreUbiquitousPeerTokenOption] = ubiquitousPeerToken
        }
        
        var store: NSPersistentStore?
        var storeError: NSError?
        coordinator.performBlockAndWait {
            
            do {
                
                store = try coordinator.addPersistentStoreWithType(
                    NSSQLiteStoreType,
                    configuration: configuration,
                    URL: fileURL,
                    options: options
                )
            }
            catch {
                
                storeError = error as NSError
            }
        }
        
        if let store = store {
            
            self.updateMetadataForPersistentStore(store)
            return store
        }
        
        if let error = storeError
            where (resetStoreOnModelMismatch && error.isCoreDataMigrationError) {
                
                fileManager.removeSQLiteStoreAtURL(fileURL)
                
                var store: NSPersistentStore?
                coordinator.performBlockAndWait {
                    
                    do {
                        
                        store = try coordinator.addPersistentStoreWithType(
                            NSSQLiteStoreType,
                            configuration: configuration,
                            URL: fileURL,
                            options: options
                        )
                    }
                    catch {
                        
                        storeError = error as NSError
                    }
                }
                
                if let store = store {
                    
                    self.updateMetadataForPersistentStore(store)
                    return store
                }
        }
        
        let error = storeError ?? NSError(coreStoreErrorCode: .UnknownError)
        CoreStore.handleError(
            error,
            "Failed to add SQLite \(typeName(NSPersistentStore)) at \"\(fileURL)\"."
        )
        throw error
        
        
        
    }
}
