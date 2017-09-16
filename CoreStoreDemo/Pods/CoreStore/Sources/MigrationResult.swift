//
//  MigrationResult.swift
//  CoreStore
//
//  Copyright © 2015 John Rommel Estropia
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


// MARK: - MigrationResult

/**
 The `MigrationResult` indicates the result of a migration.
 The `MigrationResult` can be treated as a boolean:
 ```
 CoreStore.upgradeStorageIfNeeded(SQLiteStorage(fileName: "data.sqlite")) { (result) in
     switch result {
     case .success(let migrationSteps):
         // ...
     case .failure(let error):
         // ...
     }
 }
 ```
 */
public enum MigrationResult: Hashable {
    
    /**
     `MigrationResult.success` indicates either the migration succeeded, or there were no migrations needed. The associated value is an array of `MigrationType`s reflecting the migration steps completed.
     */
    case success([MigrationType])
    
    /**
     `SaveResult.failure` indicates that the migration failed. The associated object for this value is the a `CoreStoreError` enum value.
     */
    case failure(CoreStoreError)
    
    
    /**
     Returns `true` if the result indicates `.success`, `false` if the result is `.failure`.
     */
    public var isSuccess: Bool {
        
        switch self {
            
        case .success: return true
        case .failure: return false
        }
    }
    
    
    // MARK: Equatable
    
    public static func == (lhs: MigrationResult, rhs: MigrationResult) -> Bool {
        
        switch (lhs, rhs) {
            
        case (.success(let migrationTypes1), .success(let migrationTypes2)):
            return migrationTypes1 == migrationTypes2
            
        case (.failure(let error1), .failure(let error2)):
            return error1 == error2
            
        default:
            return false
        }
    }
    
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        switch self {
            
        case .success(let migrationTypes):
            return true.hashValue
                ^ migrationTypes.map { $0.hashValue }.reduce(0, ^).hashValue
            
        case .failure(let error):
            return false.hashValue ^ error.hashValue
        }
    }
    
    
    // MARK: Internal
    
    internal init(_ migrationTypes: [MigrationType]) {
        
        self = .success(migrationTypes)
    }
    
    internal init(_ error: CoreStoreError) {
        
        self = .failure(error)
    }
    
    internal init(_ error: Error) {
        
        self = .failure(CoreStoreError(error))
    }
}
