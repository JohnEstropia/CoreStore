//
//  CoreStoreError.swift
//  CoreStore
//
//  Copyright © 2014 John Rommel Estropia
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


// MARK: - CoreStoreError

public enum CoreStoreError: ErrorType, CustomStringConvertible, CustomDebugStringConvertible {
    
    /**
     A failure occured because of an unknown error.
     */
    case Unknown
    
    /**
     The `NSPersistentStore` could note be initialized because another store existed at the specified `NSURL`.
     */
    case DifferentStorageExistsAtURL(existingPersistentStoreURL: NSURL)
    
    /**
     An `NSMappingModel` could not be found for a specific source and destination model versions.
     */
    case MappingModelNotFound(storage: LocalStorage, targetModel: NSManagedObjectModel, targetModelVersion: String)
    
    /**
     Progressive migrations are disabled for a store, but an `NSMappingModel` could not be found for a specific source and destination model versions.
     */
    case ProgressiveMigrationRequired(storage: LocalStorage)
    
    /**
     An internal SDK call failed with the specified `NSError`.
     */
    case InternalError(NSError)
    
    
    // MARK: ErrorType
    
    public var _domain: String {
        
        return "com.corestore.error"
    }
    
    public var _code: Int {
    
        switch self {
            
        case .Unknown:                      return 1
        case .DifferentStorageExistsAtURL:  return 2
        case .MappingModelNotFound:         return 3
        case .ProgressiveMigrationRequired: return 4
        case .InternalError:                return 5
        }
    }
    
    
    // MARK: CustomStringConvertible
    
    public var description: String {
        
        // TODO:
        return (self as NSError).description
    }
    
    
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        
        return self.description
    }
    
    
    // MARK: Internal
    
    internal init(_ error: ErrorType?) {
        
        switch error {
            
        case (let error as CoreStoreError)?:
            self = error
            
        case (let error as NSError)?:
            self = .InternalError(error)
            
        default:
            self = .Unknown
        }
    }
}


// MARK: - CoreStoreErrorCode

/**
 The `NSError` error domain for `CoreStore`.
 */
@available(*, deprecated=2.0.0, message="Use CoreStoreError enum values instead.")
public let CoreStoreErrorDomain = "com.corestore.error"

/**
 The `NSError` error codes for `CoreStoreErrorDomain`.
 */
@available(*, deprecated=2.0.0, message="Use CoreStoreError enum values instead.")
public enum CoreStoreErrorCode: Int {
    
    /**
     A failure occured because of an unknown error.
     */
    case UnknownError
    
    /**
     The `NSPersistentStore` could note be initialized because another store existed at the specified `NSURL`.
     */
    case DifferentPersistentStoreExistsAtURL
    
    /**
     An `NSMappingModel` could not be found for a specific source and destination model versions.
     */
    case MappingModelNotFound
    
    /**
     Progressive migrations are disabled for a store, but an `NSMappingModel` could not be found for a specific source and destination model versions.
     */
    case ProgressiveMigrationRequired
}


// MARK: - NSError

public extension NSError {
    
    // MARK: Internal
    
    internal var isCoreDataMigrationError: Bool {
        
        let code = self.code
        return (code == NSPersistentStoreIncompatibleVersionHashError
            || code == NSMigrationMissingSourceModelError
            || code == NSMigrationError)
            && self.domain == NSCocoaErrorDomain
    }
    
    
    // MARK: Deprecated

    /**
     If the error's domain is equal to `CoreStoreErrorDomain`, returns the associated `CoreStoreErrorCode`. For other domains, returns `nil`.
     */
    @available(*, deprecated=2.0.0, message="Use CoreStoreError enum values instead.")
    public var coreStoreErrorCode: CoreStoreErrorCode? {
        
        return (self.domain == CoreStoreErrorDomain
            ? CoreStoreErrorCode(rawValue: self.code)
            : nil)
    }
}
