//
//  DataStackExtension.swift
//  CoreStore iOS
//  Copyright © 2018 John Rommel Estropia
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

public extension DataStack {
   
    @discardableResult
    func dropStorage<T: LocalStorage>(_ storage: T) throws -> T {
        return try self.coordinator.performSynchronously {
            let fileURL = storage.fileURL
            Internals.assert(
                fileURL.isFileURL,
                "The specified store URL for the \"\(Internals.typeName(storage))\" is invalid: \"\(fileURL)\""
            )
            
            guard let persistentStore = self.coordinator.persistentStore(for: fileURL) else {
                return storage
            }
            
            self.dropStore(persistentStore: persistentStore, storeURL: fileURL)
            
            let finalStoreOptions = storage.dictionary(forOptions: storage.localStorageOptions)
            _ = try self.createPersistentStoreFromStorage(
                storage,
                finalURL: fileURL,
                finalStoreOptions: finalStoreOptions
            )
            return storage
        }
    }
    
    private func dropStore(persistentStore: NSPersistentStore, storeURL : URL)
    {
        self.rootSavingContext.performAndWait {
            self.rootSavingContext.reset()
            
            self.mainContext.performAndWait { () -> Void in
                self.mainContext.reset()
                do
                {
                    
                    try self.coordinator.remove(persistentStore)
                    try self.deleteFiles(storeURL: storeURL)
                }
                catch { /*dealing with errors up to the usage*/ }
            }
        }
    }
    
    private func deleteFiles(storeURL: URL, extraFiles: [String] = []) throws {
        
        let fileManager = FileManager.default
        let extraFiles: [String] = [
            storeURL.path.appending("-wal"),
            storeURL.path.appending("-shm")
        ]
        do {
            
            let trashURL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!)
                .appendingPathComponent(Bundle.main.bundleIdentifier ?? "com.CoreStore.DataStack", isDirectory: true)
                .appendingPathComponent("trash", isDirectory: true)
            try fileManager.createDirectory(
                at: trashURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
            
            let temporaryFileURL = trashURL.appendingPathComponent(UUID().uuidString, isDirectory: false)
            try fileManager.moveItem(at: storeURL, to: temporaryFileURL)
            
            let extraTemporaryFiles = extraFiles.map { (extraFile) -> String in
                
                let temporaryFile = trashURL.appendingPathComponent(UUID().uuidString, isDirectory: false).path
                if let _ = try? fileManager.moveItem(atPath: extraFile, toPath: temporaryFile) {
                    
                    return temporaryFile
                }
                return extraFile
            }
            
            _ = try? fileManager.removeItem(at: temporaryFileURL)
            extraTemporaryFiles.forEach({ _ = try? fileManager.removeItem(atPath: $0) })
        }
        catch {
            
            try fileManager.removeItem(at: storeURL)
            extraFiles.forEach({ _ = try? fileManager.removeItem(atPath: $0) })
        }
    }
}
