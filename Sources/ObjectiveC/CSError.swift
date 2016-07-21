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

import Foundation
import CoreData


// MARK: - CSError

/**
 All errors thrown from CoreStore are expressed in `CSError`s.
 
 - SeeAlso: `CoreStoreError`
 */
@objc
public final class CSError: NSError, CoreStoreObjectiveCType {
    
    /**
     The `NSError` error domain for `CSError`.
     
     - SeeAlso: `CoreStoreErrorErrorDomain`
     */
    @objc
    public static let errorDomain = CoreStoreErrorDomain
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.bridgeToSwift.hashValue
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        
        guard let object = object as? CSError else {
            
            return false
        }
        return self.bridgeToSwift == object.bridgeToSwift
    }
    
    public override var description: String {
        
        return "(\(String(reflecting: self.dynamicType))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public var bridgeToSwift: CoreStoreError {
        
        if let swift = self.swiftError {
            
            return swift
        }
        
        func createSwiftObject(error: CSError) -> CoreStoreError {
            
            guard error.domain == CoreStoreErrorDomain else {
                
                return .InternalError(NSError: self)
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
        
        let swift = createSwiftObject(self)
        self.swiftError = swift
        return swift
    }
    
    /**
     Do not call directly!
     */
    public init(_ swiftValue: CoreStoreError) {
        
        self.swiftError = swiftValue
        
        let code: CoreStoreErrorCode
        let info: [NSObject: AnyObject]
        switch swiftValue {
            
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
        
        super.init(domain: CoreStoreErrorDomain, code: code.rawValue, userInfo: info)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
    // MARK: Private
    
    private var swiftError: CoreStoreError?
}


// MARK: - CSErrorCode

/**
 The `NSError` error codes for `CSError.Domain`.
 
 - SeeAlso: `CSError`
 - SeeAlso: `CoreStoreError`
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


// MARK: - CoreStoreError

extension CoreStoreError: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSError {
        
        return CSError(self)
    }
}


// MARK: Internal

internal extension ErrorType {
    
    internal var bridgeToSwift: CoreStoreError {
        
        switch self {
            
        case let error as CoreStoreError:
            return error
            
        case let error as CSError:
            return error.bridgeToSwift
            
        case let error as NSError where self.dynamicType is NSError.Type:
            return .InternalError(NSError: error)
            
        default:
            return .Unknown
        }
    }
    
    internal var bridgeToObjectiveC: NSError {
        
        switch self {
            
        case let error as CoreStoreError:
            return error.bridgeToObjectiveC
            
        case let error as CSError:
            return error
            
        default:
            return self as NSError
        }
    }
}
