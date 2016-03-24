//
//  CSError.swift
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


// MARK: - CSError

/**
 The `CSError` provides a facade for CoreStore Objective-C constants.
 */
public final class CSError: NSObject {
    
    /**
     The `NSError` error domain for `CSCoreStore`.
     */
    @objc
    public static let domain = CoreStoreErrorDomain
    
    
    // MARK: Private
    
    private override init() {
        
        fatalError()
    }
}


// MARK: - CSErrorCode

/**
 The `NSError` error codes for `CSError.Domain`.
 */
@objc
public enum CSErrorCode: Int {
    
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
    
    /**
     An internal SDK call failed with the specified "NSError" userInfo key.
     */
    case InternalError
}


// MARK: Internal

internal extension ErrorType {
    
    internal var swift: CoreStoreError {
        
        if case let error as CoreStoreError = self {
            
            return error
        }
        
        guard let error = (self as Any) as? NSError else {
            
            return .Unknown
        }
        
        guard error.domain == CoreStoreErrorDomain else {
            
            return .InternalError(NSError: error)
        }
        
        guard let code = CoreStoreErrorCode(rawValue: error.code) else {
            
            return .Unknown
        }
        
        let info = error.userInfo
        switch code {
            
        case .UnknownError:
            return .Unknown
            
        case .DifferentPersistentStoreExistsAtURL:
            guard case let existingPersistentStoreURL as NSURL = info["existingPersistentStoreURL"] else {
                
                return .Unknown
            }
            return .DifferentStorageExistsAtURL(existingPersistentStoreURL: existingPersistentStoreURL)
            
        case .MappingModelNotFound:
            guard let localStoreURL = info["localStoreURL"] as? NSURL,
                let targetModel = info["targetModel"] as? NSManagedObjectModel,
                let targetModelVersion = info["targetModelVersion"] as? String else {
                    
                    return .Unknown
            }
            return .MappingModelNotFound(localStoreURL: localStoreURL, targetModel: targetModel, targetModelVersion: targetModelVersion)
            
        case .ProgressiveMigrationRequired:
            guard let localStoreURL = info["localStoreURL"] as? NSURL else {
                
                return .Unknown
            }
            return .ProgressiveMigrationRequired(localStoreURL: localStoreURL)
            
        case .InternalError:
            guard case let NSError as NSError = info["NSError"] else {
                
                return .Unknown
            }
            return .InternalError(NSError: NSError)
        }
    }
    
    internal var objc: NSError {
        
        guard let error = self as? CoreStoreError else {
            
            return ((self as Any) as? NSError) ?? self as NSError
        }
        
        let code: CoreStoreErrorCode
        let info: [NSObject: AnyObject]
        switch error {
            
        case .Unknown:
            code = .UnknownError
            info = [:]
            
        case .DifferentStorageExistsAtURL(let existingPersistentStoreURL):
            code = .DifferentPersistentStoreExistsAtURL
            info = [
                "existingPersistentStoreURL": existingPersistentStoreURL
            ]
            
        case .MappingModelNotFound(let localStoreURL, let targetModel, let targetModelVersion):
            code = .MappingModelNotFound
            info = [
                "localStoreURL": localStoreURL,
                "targetModel": targetModel,
                "targetModelVersion": targetModelVersion
            ]
            
        case .ProgressiveMigrationRequired(let localStoreURL):
            code = .ProgressiveMigrationRequired
            info = [
                "localStoreURL": localStoreURL
            ]
            
        case .InternalError(let NSError):
            code = .InternalError
            info = [
                "NSError": NSError
            ]
        }
        
        return NSError(domain: CoreStoreErrorDomain, code: code.rawValue, userInfo: info)
    }
}
