//
//  Internals.AppGroupsManager.swift
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

import Foundation


// MARK: - Internals

extension Internals {

    // MARK: - AppGroupsManager

    internal enum AppGroupsManager {

        // MARK: Internal
        
        internal typealias BundleID = String
        
        internal typealias StoreID = UUID
        
        @discardableResult
        internal static func register(
            appGroupIdentifier: String,
            subdirectory: String?,
            fileName: String
        ) throws -> StoreID {
            
            let bundleID = self.bundleID()
            let indexMetadataURL = self.indexMetadataURL(
                appGroupIdentifier: appGroupIdentifier
            )
            return try self.metadata(
                forWritingAt: indexMetadataURL,
                initializer: IndexMetadata.init,
                { metadata in
                    
                    return metadata.fetchOrCreateStoreID(
                        bundleID: bundleID,
                        subdirectory: subdirectory,
                        fileName: fileName
                    )
                }
            )
        }
        
        internal static func existingToken(
            appGroupIdentifier: String,
            subdirectory: String,
            fileName: String
        ) throws -> NSPersistentHistoryToken? {
            
            let bundleID = self.bundleID()
            let indexMetadataURL = self.indexMetadataURL(
                appGroupIdentifier: appGroupIdentifier
            )
            guard
                let storeID = try self.metadata(
                    forReadingAt: indexMetadataURL,
                    { (metadata: IndexMetadata) in
                        
                        return metadata.fetchStoreID(
                            bundleID: bundleID,
                            subdirectory: subdirectory,
                            fileName: fileName
                        )
                    }
                )
            else {
                
                return nil
            }
            let storageMetadataURL = self.storageMetadataURL(
                appGroupIdentifier: appGroupIdentifier,
                bundleID: bundleID,
                storeID: storeID
            )
            return try self.metadata(
                forReadingAt: storageMetadataURL,
                { (metadata: StorageMetadata) in
                    
                    return metadata.persistentHistoryToken
                }
            )
        }
        
        internal static func setExistingToken(
            _ newToken: NSPersistentHistoryToken,
            appGroupIdentifier: String,
            subdirectory: String,
            fileName: String
        ) throws {
            
            let bundleID = self.bundleID()
            let indexMetadataURL = self.indexMetadataURL(
                appGroupIdentifier: appGroupIdentifier
            )
            guard
                let storeID = try self.metadata(
                    forReadingAt: indexMetadataURL,
                    { (metadata: IndexMetadata) in
                        
                        return metadata.fetchStoreID(
                            bundleID: bundleID,
                            subdirectory: subdirectory,
                            fileName: fileName
                        )
                    }
                )
            else {
                
                return
            }
            let storageMetadataURL = self.storageMetadataURL(
                appGroupIdentifier: appGroupIdentifier,
                bundleID: bundleID,
                storeID: storeID
            )
            try self.metadata(
                forWritingAt: storageMetadataURL,
                initializer: StorageMetadata.init,
                { metadata in
                    
                    metadata.persistentHistoryToken = newToken
                }
            )
        }
        
        
        // MARK: Private
        
        private static func appGroupContainerURL(
            appGroupIdentifier: String
        ) -> URL {
            
            guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
                
                Internals.abort("Failed to join app group named \"\(appGroupIdentifier)\". Make sure that this app is registered into this app group through the entitlements file.")
            }
            return containerURL
                .appendingPathComponent(Internals.libReverseDomain(), isDirectory: true)
        }
        
        private static func indexMetadataURL(
            appGroupIdentifier: String
        ) -> URL {
            
            return self.appGroupContainerURL(appGroupIdentifier: appGroupIdentifier)
                .appendingPathComponent("index.meta", isDirectory: false)
        }
        
        private static func storageMetadataURL(
            appGroupIdentifier: String,
            bundleID: BundleID,
            storeID: StoreID
        ) -> URL {
            
            return self
                .appGroupContainerURL(appGroupIdentifier: appGroupIdentifier)
                .appendingPathComponent(bundleID, isDirectory: true)
                .appendingPathComponent(storeID.uuidString, isDirectory: false)
                .appendingPathExtension("meta")
        }
        
        private static func metadata<Metadata: Codable, Result>(
            forReadingAt url: URL,
            _ task: @escaping (Metadata) -> Result?
        ) throws -> Result? {
            
            let fileCoordinator = NSFileCoordinator()
            var fileCoordinatorError: NSError?
            var accessorError: Error?
            var result: Result?
            fileCoordinator.coordinate(
                readingItemAt: url,
                options: .withoutChanges,
                error: &fileCoordinatorError,
                byAccessor: { url in
                    
                    do {
                        
                        guard let metadata: Metadata = try self.loadMetadata(lockedURL: url) else {
                            
                            return
                        }
                        result = task(metadata)
                    }
                    catch {
                        
                        accessorError = error
                    }
                }
            )
            if let fileCoordinatorError = fileCoordinatorError {
                
                throw CoreStoreError(fileCoordinatorError)
            }
            else if let accessorError = accessorError {
                
                throw CoreStoreError(accessorError)
            }
            else {
                
                return result
            }
        }
        
        private static func metadata<Metadata: Codable, Result>(
            forWritingAt url: URL,
            initializer: @escaping () -> Metadata,
            _ task: @escaping (inout Metadata) -> Result
        ) throws -> Result {
            
            let fileManager = FileManager.default
            try? fileManager.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true,
                attributes: nil
            )
            
            let fileCoordinator = NSFileCoordinator()
            var fileCoordinatorError: NSError?
            var accessorError: Error?
            var result: Result?
            fileCoordinator.coordinate(
                writingItemAt: url,
                options: .forReplacing,
                error: &fileCoordinatorError,
                byAccessor: { url in
                    
                    do {
                        
                        var metadata: Metadata = try self.loadMetadata(lockedURL: url)
                            ?? initializer()
                        result = task(&metadata)
                        try self.saveMetadata(metadata, lockedURL: url)
                    }
                    catch {
                        
                        accessorError = error
                    }
                }
            )
            if let fileCoordinatorError = fileCoordinatorError {
                
                throw CoreStoreError(fileCoordinatorError)
            }
            else if let accessorError = accessorError {
                
                throw CoreStoreError(accessorError)
            }
            else {
                
                return result!
            }
        }
        
        private static func bundleID() -> String {
            
            guard let bundleID = Bundle.main.bundleIdentifier else {
                
                Internals.abort("App Group containers can only be used for bundled projects.")
            }
            return bundleID
        }
        
        private static func loadMetadata<Metadata: Codable>(
            lockedURL url: URL
        ) throws -> Metadata? {
            
            let decoder = PropertyListDecoder()
            guard let data = try? Data(contentsOf: url) else {
                
                return nil
            }
            return try decoder.decode(Metadata.self, from: data)
        }
        
        private static func saveMetadata<Metadata: Codable>(
            _ metadata: Metadata,
            lockedURL url: URL
        ) throws {
            
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(metadata)
            try data.write(to: url, options: .atomic)
        }
        
        
        // MARK: - IndexMetadata
        
        fileprivate struct IndexMetadata: Codable {
            
            // MARK: FilePrivate
            
            fileprivate func fetchStoreID(
                bundleID: BundleID,
                subdirectory: String?,
                fileName: String
            ) -> StoreID? {
                
                let fileTag = Self.createFileTag(subdirectory: subdirectory, fileName: fileName)
                return self.contents[bundleID, default: [:]][fileTag]
            }
            
            fileprivate mutating func fetchOrCreateStoreID(
                bundleID: BundleID,
                subdirectory: String?,
                fileName: String
            ) -> StoreID {
                
                let fileTag = Self.createFileTag(subdirectory: subdirectory, fileName: fileName)
                return self.contents[bundleID, default: [:]][fileTag, default: UUID()]
            }
            
            // MARK: Codable
            
            private enum CodingKeys: String, CodingKey {
                
                case contents = "contents"
            }
            
            // MARK: Private
            
            private typealias FileTag = String
            
            private var contents: [BundleID: [FileTag: UUID]] = [:]
            
            private static func createFileTag(subdirectory: String?, fileName: String) -> FileTag {
                
                guard let subdirectory = subdirectory else {
                    
                    return fileName
                }
                return (subdirectory as NSString).appendingPathComponent(fileName)
            }
        }
        
        
        // MARK: - StorageMetadata
        
        fileprivate struct StorageMetadata: Codable {
            
            // MARK: FilePrivate
            
            fileprivate var persistentHistoryToken: NSPersistentHistoryToken? {
                
                get {
                    
                    return self.persistentHistoryTokenData.flatMap {
                        
                        return try! NSKeyedUnarchiver.unarchivedObject(
                            ofClass: NSPersistentHistoryToken.self,
                            from: $0
                        )
                    }
                }
                set {
                    
                    self.persistentHistoryTokenData = newValue.map {
                        
                        return try! NSKeyedArchiver.archivedData(
                            withRootObject: $0,
                            requiringSecureCoding: true
                        )
                    }
                }
            }
            
            
            // MARK: Codable
            
            private enum CodingKeys: String, CodingKey {
                
                case persistentHistoryTokenData = "persistent_history_token_data"
            }
            
            
            // MARK: Private
            
            private var persistentHistoryTokenData: Data?
        }
    }
}

