//
//  SQLiteStore.swift
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

import CoreData


// MARK: - SQLiteStore

public class SQLiteStore: Storage, DefaultInitializableStore {
    
    public static let defaultRootDirectory: NSURL = {
        
        #if os(tvOS)
            let systemDirectorySearchPath = NSSearchPathDirectory.CachesDirectory
        #else
            let systemDirectorySearchPath = NSSearchPathDirectory.ApplicationSupportDirectory
        #endif
        
        let defaultSystemDirectory = NSFileManager
            .defaultManager()
            .URLsForDirectory(systemDirectorySearchPath, inDomains: .UserDomainMask).first!
        
        return defaultSystemDirectory.URLByAppendingPathComponent(
            NSBundle.mainBundle().bundleIdentifier ?? "com.CoreStore.DataStack",
            isDirectory: true
        )
    }()
    
    public static let defaultFileURL: NSURL = {
        
        let applicationName = (NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as? String) ?? "CoreData"
        
        return SQLiteStore.defaultRootDirectory
            .URLByAppendingPathComponent(applicationName, isDirectory: false)
            .URLByAppendingPathExtension("sqlite")
    }()
    
    public required init(fileURL: NSURL, configuration: String? = nil, resetStoreOnModelMismatch: Bool = false) {
        
        self.fileURL = fileURL
        self.configuration = configuration
        self.resetStoreOnModelMismatch = resetStoreOnModelMismatch
    }
    
    public required init(fileName: String, configuration: String? = nil, resetStoreOnModelMismatch: Bool = false) {
        
        self.fileURL = SQLiteStore.defaultRootDirectory
            .URLByAppendingPathComponent(fileName, isDirectory: false)
        self.configuration = configuration
        self.resetStoreOnModelMismatch = resetStoreOnModelMismatch
    }
    
    
    // MARK: DefaultInitializableStore
    
    public required init() {
        
        self.fileURL = SQLiteStore.defaultFileURL
        self.configuration = nil
        self.resetStoreOnModelMismatch = false
    }
    
    
    // MARK: Storage
    
    public static let storeType = NSSQLiteStoreType
    
    public var storeURL: NSURL? {
        
        return self.fileURL
    }
    
    public let configuration: String?
    
    public let storeOptions: [String: AnyObject]? = [NSSQLitePragmasOption: ["journal_mode": "WAL"]]
    
    public var internalStore: NSPersistentStore?
    
    public func addToPersistentStoreCoordinatorSynchronously(coordinator: NSPersistentStoreCoordinator) throws -> NSPersistentStore {
        
        let fileManager = NSFileManager.defaultManager()
        
        do {
            
            let fileURL = self.fileURL
            try fileManager.createDirectoryAtURL(
                fileURL.URLByDeletingLastPathComponent!,
                withIntermediateDirectories: true,
                attributes: nil
            )
            return try coordinator.addPersistentStoreSynchronously(
                self.dynamicType.storeType,
                configuration: self.configuration,
                URL: fileURL,
                options: self.storeOptions
            )
        }
        catch let error as NSError where resetStoreOnModelMismatch && error.isCoreDataMigrationError {
            
            fileManager.removeSQLiteStoreAtURL(fileURL)
            
            return try coordinator.addPersistentStoreSynchronously(
                self.dynamicType.storeType,
                configuration: self.configuration,
                URL: fileURL,
                options: self.storeOptions
            )
        }
    }
    
    
    // MARK: Internal
    
    internal let fileURL: NSURL
    
    internal let resetStoreOnModelMismatch: Bool
}
