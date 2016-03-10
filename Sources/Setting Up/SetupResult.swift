//
//  PersistentStoreResult.swift
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


// MARK: - SetupResult

/**
 The `SetupResult` indicates the result of an asynchronous initialization of a persistent store.
 The `SetupResult` can be treated as a boolean:
 ```
 try! CoreStore.addStorage(
     SQLiteStore(),
     completion: { (result: SetupResult) -> Void in
         if result {
             // succeeded
         }
         else {
             // failed
         }
     }
 )
 ```
 or as an `enum`, where the resulting associated object can also be inspected:
 ```
 try! CoreStore.addStorage(
     SQLiteStore(),
     completion: { (result: SetupResult) -> Void in
         switch result {
         case .Success(let storage):
             // storage is the related StorageInterface instance
         case .Failure(let error):
             // error is the NSError instance for the failure
         }
     }
 )
 ```
 */
public enum SetupResult<T: StorageInterface>: BooleanType {
    
    /**
     `SetupResult.Success` indicates that the storage setup succeeded. The associated object for this `enum` value is the related `StorageInterface` instance.
     */
    case Success(T)
    
    /**
     `SetupResult.Failure` indicates that the storage setup failed. The associated object for this value is the related `NSError` instance.
     */
    case Failure(NSError)
    
    
    // MARK: BooleanType
    
    public var boolValue: Bool {
        
        switch self {
            
        case .Success: return true
        case .Failure: return false
        }
    }
    
    
    // MARK: Internal
    
    internal init(_ storage: T) {
        
        self = .Success(storage)
    }
    
    internal init(_ error: NSError) {
        
        self = .Failure(error)
    }
    
    internal init(_ errorCode: CoreStoreErrorCode) {
        
        self.init(errorCode, userInfo: nil)
    }
    
    internal init(_ errorCode: CoreStoreErrorCode, userInfo: [NSObject: AnyObject]?) {
        
        self.init(NSError(coreStoreErrorCode: errorCode, userInfo: userInfo))
    }
}


// MARK: - Deprecated


/**
 Deprecated. Replaced by `SetupResult<T>` when using the new `addStorage(_:completion:)` method variants.
 */
@available(*, deprecated=2.0.0, message="Replaced by SetupResult by using the new addStorage(_:completion:) method variants.")
public enum PersistentStoreResult: BooleanType {
    
    /**
     Deprecated. Replaced by `SetupResult.Success` when using the new `addStorage(_:completion:)` method variants.
     */
    case Success(NSPersistentStore)
    
    /**
     Deprecated. Replaced by `SetupResult.Failure` when using the new `addStorage(_:completion:)` method variants.
     */
    case Failure(NSError)
    
    
    // MARK: BooleanType
    
    public var boolValue: Bool {
        
        switch self {
            
        case .Success: return true
        case .Failure: return false
        }
    }
    
    
    // MARK: Internal
    
    internal init(_ store: NSPersistentStore) {
        
        self = .Success(store)
    }
    
    internal init(_ error: NSError) {
        
        self = .Failure(error)
    }
    
    internal init(_ errorCode: CoreStoreErrorCode) {
        
        self.init(errorCode, userInfo: nil)
    }
    
    internal init(_ errorCode: CoreStoreErrorCode, userInfo: [NSObject: AnyObject]?) {
        
        self.init(NSError(coreStoreErrorCode: errorCode, userInfo: userInfo))
    }
}
