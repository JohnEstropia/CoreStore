//
//  CSError.swift
//  CoreStore
//
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


// MARK: - CSError

/**
 All errors thrown from CoreStore are expressed in `CSError`s.
 
 - SeeAlso: `CoreStoreError`
 */
@objc
public final class CSError: NSError {
    
    /**
     The `NSError` error domain for `CSError`.
     
     - SeeAlso: `CoreStoreErrorErrorDomain`
     */
    @objc
    public static let errorDomain = CoreStoreErrorDomain

    public var bridgeToSwift: CoreStoreError {

        if let swift = self.swiftError {

            return swift
        }
        let swift = CoreStoreError(_bridgedNSError: self) ?? .unknown
        self.swiftError = swift
        return swift
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.bridgeToSwift.hashValue
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        guard let object = object as? CSError else {
            
            return false
        }
        return self.bridgeToSwift == object.bridgeToSwift
    }
    
    public override var description: String {
        
        return "(\(String(reflecting: Self.self))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    /**
     Do not call directly!
     */
    public init(_ swiftValue: CoreStoreError) {
        
        self.swiftError = swiftValue
        super.init(domain: CoreStoreError.errorDomain, code: swiftValue.errorCode, userInfo: swiftValue.errorUserInfo)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
    // MARK: Private
    
    private var swiftError: CoreStoreError?
}

@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
extension CSError: CoreStoreObjectiveCType {}


// MARK: - CSErrorCode

/**
 The `NSError` error codes for `CSError.Domain`.
 
 - SeeAlso: `CSError`
 - SeeAlso: `CoreStoreError`
 */
@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
@objc
public enum CSErrorCode: Int {
    
    /**
     A failure occured because of an unknown error.
     */
    case unknownError
    
    /**
     The `NSPersistentStore` could note be initialized because another store existed at the specified `NSURL`.
     */
    case differentStorageExistsAtURL
    
    /**
     An `NSMappingModel` could not be found for a specific source and destination model versions.
     */
    case mappingModelNotFound
    
    /**
     Progressive migrations are disabled for a store, but an `NSMappingModel` could not be found for a specific source and destination model versions.
     */
    case progressiveMigrationRequired
    
    /**
     An internal SDK call failed with the specified "NSError" userInfo key.
     */
    case internalError
    
    /**
     The transaction was terminated by a user-thrown error with the specified "Error" userInfo key.
     */
    case userError
    
    /**
     The transaction was cancelled by the user.
     */
    case userCancelled
}


// MARK: - CoreStoreError

extension CoreStoreError: _ObjectiveCBridgeableError {
    
    // MARK: _ObjectiveCBridgeableError
    
    public init?(_bridgedNSError error: NSError) {
        
        guard error.domain == CoreStoreErrorDomain else {
            
            if error is CSError {
                
                self = .internalError(NSError: error)
                return
            }
            return nil
        }
        
        guard let code = CoreStoreErrorCode(rawValue: error.code) else {
            
            if error is CSError {
                
                self = .unknown
                return
            }
            return nil
        }
        
        let info = error.userInfo
        switch code {
            
        case .unknownError:
            self = .unknown
            
        case .differentStorageExistsAtURL:
            guard case let existingPersistentStoreURL as URL = info["existingPersistentStoreURL"] else {
                
                self = .unknown
                return
            }
            self = .differentStorageExistsAtURL(existingPersistentStoreURL: existingPersistentStoreURL)
            
        case .mappingModelNotFound:
            guard let localStoreURL = info["localStoreURL"] as? URL,
                let targetModel = info["targetModel"] as? NSManagedObjectModel,
                let targetModelVersion = info["targetModelVersion"] as? String else {
                    
                    self = .unknown
                    return
            }
            self = .mappingModelNotFound(localStoreURL: localStoreURL, targetModel: targetModel, targetModelVersion: targetModelVersion)
            
        case .progressiveMigrationRequired:
            guard let localStoreURL = info["localStoreURL"] as? URL else {
                
                self = .unknown
                return
            }
            self = .progressiveMigrationRequired(localStoreURL: localStoreURL)

        case .asynchronousMigrationRequired:
            guard
                let localStoreURL = info["localStoreURL"] as? URL,
                case let nsError as NSError = info["NSError"]
                else {

                    self = .unknown
                    return
            }
            self = .asynchronousMigrationRequired(localStoreURL: localStoreURL, NSError: nsError)
            
        case .internalError:
            guard case let nsError as NSError = info["NSError"] else {
                
                self = .unknown
                return
            }
            self = .internalError(NSError: nsError)
            
        case .userError:
            guard case let error as Error = info["Error"] else {
                
                self = .unknown
                return
            }
            self = .userError(error: error)
            
        case .userCancelled:
            self = .userCancelled

        case .persistentStoreNotFound:
            guard let entity = info["entity"] as? DynamicObject.Type else {

                self = .unknown
                return
            }
            self = .persistentStoreNotFound(entity: entity)
        }
    }
}


// MARK: - Error

extension Error {

    // MARK: Internal
    
    internal var bridgeToSwift: CoreStoreError {
        
        switch self {
            
        case let error as CoreStoreError:
            return error
            
        case let error as CSError:
            return error.bridgeToSwift
            
        case let error as NSError where Self.self is NSError.Type:
            return .internalError(NSError: error)
            
        default:
            return .unknown
        }
    }

    @available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
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


// MARK: - CoreStoreError

@available(*, deprecated, message: "CoreStore Objective-C API will be removed soon.")
extension CoreStoreError: CoreStoreSwiftType {

    // MARK: CoreStoreSwiftType

    public var bridgeToObjectiveC: CSError {

        return CSError(self)
    }
}
