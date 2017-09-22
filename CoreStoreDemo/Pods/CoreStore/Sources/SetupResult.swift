//
//  SetupResult.swift
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
         case .success(let storage):
             // storage is the related StorageInterface instance
         case .failure(let error):
             // error is the CoreStoreError enum value for the failure
         }
     }
 )
 ```
 */
public enum SetupResult<T: StorageInterface>: Hashable {
    
    /**
     `SetupResult.success` indicates that the storage setup succeeded. The associated object for this `enum` value is the related `StorageInterface` instance.
     */
    case success(T)
    
    /**
     `SetupResult.failure` indicates that the storage setup failed. The associated object for this value is the related `CoreStoreError` enum value.
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
    
    public static func == <T: StorageInterface, U: StorageInterface>(lhs: SetupResult<T>, rhs: SetupResult<U>) -> Bool {
        
        switch (lhs, rhs) {
            
        case (.success(let storage1), .success(let storage2)):
            return storage1 === storage2
            
        case (.failure(let error1), .failure(let error2)):
            return error1 == error2
            
        default:
            return false
        }
    }
    
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        switch self {
            
        case .success(let storage):
            return true.hashValue ^ ObjectIdentifier(storage).hashValue
            
        case .failure(let error):
            return false.hashValue ^ error.hashValue
        }
    }
    
    
    // MARK: Internal
    
    internal init(_ storage: T) {
        
        self = .success(storage)
    }
    
    internal init(_ error: CoreStoreError) {
        
        self = .failure(error)
    }
    
    internal init(_ error: Error) {
        
        self = .failure(CoreStoreError(error))
    }
}
