//
//  CSCoreStore+Migrating.swift
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


// MARK: - CSCoreStore

public extension CSCoreStore {
    
    /**
     Asynchronously adds a `CSInMemoryStore` to the `defaultStack`. Migrations are also initiated by default.
     ```
     NSError *error;
     NSProgress *migrationProgress = [dataStack
         addInMemoryStorage:[CSInMemoryStore new]
         completion:^(CSSetupResult *result) {
             if (result.isSuccess) {
                 // ...
             }
         }
         error: &error];
     ```
     - parameter storage: the `CSInMemoryStore` instance
     - parameter completion: the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `CSSetupResult` argument indicates the result. This closure is NOT executed if an error is thrown, but will be executed with a failure `CSSetupResult` result if an error occurs asynchronously.
     */
    public static func addInMemoryStorage(_ storage: CSInMemoryStore, completion: @escaping (CSSetupResult) -> Void) {
        
        self.defaultStack.addInMemoryStorage(storage, completion: completion)
    }
    
    /**
     Asynchronously adds a `CSSQLiteStore` to the `defaultStack`. Migrations are also initiated by default.
     ```
     NSError *error;
     NSProgress *migrationProgress = [dataStack
         addInMemoryStorage:[[CSSQLiteStore alloc]
         initWithFileName:@"core_data.sqlite"
         configuration:@"Config1"]
         completion:^(CSSetupResult *result) {
             if (result.isSuccess) {
                 // ...
             }
         }
         error: &error];
     ```
     - parameter storage: the `CSSQLiteStore` instance
     - parameter completion: the closure to be executed on the main queue when the process completes, either due to success or failure. The closure's `CSSetupResult` argument indicates the result. This closure is NOT executed if an error is thrown, but will be executed with a failure `CSSetupResult` result if an error occurs asynchronously. Note that the `CSLocalStorage` associated to the `-[CSSetupResult storage]` may not always be the same instance as the parameter argument if a previous `CSLocalStorage` was already added at the same URL and with the same configuration.
     - parameter error: the `NSError` pointer that indicates the reason in case of an failure
     - returns: an `NSProgress` instance if a migration has started. `nil` if no migrations are required or if `error` was set.
     */
    public static func addSQLiteStorage(_ storage: CSSQLiteStore, completion: @escaping (CSSetupResult) -> Void, error: NSErrorPointer) -> Progress? {
        
        return self.defaultStack.addSQLiteStorage(storage, completion: completion, error: error)
    }
    
    /**
     Migrates a `CSSQLiteStore` to match the `defaultStack`'s managed object model version. This method does NOT add the migrated store to the data stack.
     
     - parameter storage: the `CSSQLiteStore` instance
     - parameter completion: the closure to be executed on the main queue when the migration completes, either due to success or failure. The closure's `CSMigrationResult` argument indicates the result. This closure is NOT executed if an error is thrown, but will be executed with a failure `CSSetupResult` result if an error occurs asynchronously.
     - parameter error: the `NSError` pointer that indicates the reason in case of an failure
     - returns: an `NSProgress` instance if a migration has started. `nil` if no migrations are required or if `error` was set.
     */
    @objc
    public static func upgradeStorageIfNeeded(_ storage: CSSQLiteStore, completion: @escaping (CSMigrationResult) -> Void, error: NSErrorPointer) -> Progress? {
        
        return self.defaultStack.upgradeStorageIfNeeded(storage, completion: completion, error: error)
    }
    
    /**
     Checks the migration steps required for the `CSSQLiteStore` to match the `defaultStack`'s managed object model version.
     
     - parameter storage: the `CSSQLiteStore` instance
     - parameter error: the `NSError` pointer that indicates the reason in case of an failure
     - returns: a `CSMigrationType` array indicating the migration steps required for the store, or an empty array if the file does not exist yet. Otherwise, `nil` is returned and the `error` argument is set if either inspection of the store failed, or if no mapping model was found/inferred.
     */
    @objc
    public static func requiredMigrationsForSQLiteStore(_ storage: CSSQLiteStore, error: NSErrorPointer) -> [CSMigrationType]? {
        
        return self.defaultStack.requiredMigrationsForSQLiteStore(storage, error: error)
    }
}
