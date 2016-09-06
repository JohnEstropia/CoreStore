//
//  SaveResult.swift
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


// MARK: - SaveResult

/**
 The `SaveResult` indicates the result of a `commit(...)` for a transaction.
 The `SaveResult` can be treated as a boolean:
 ```
 CoreStore.beginAsynchronous { transaction in
     // ...
     let result = transaction.commit()
     if result {
        // succeeded
     }
     else {
        // failed
     }
 }
 ```
 or as an `enum`, where the resulting associated object can also be inspected:
 ```
 CoreStore.beginAsynchronous { transaction in
     // ...
     let result = transaction.commit()
     switch result {
     case .success(let hasChanges):
        // hasChanges indicates if there were changes or not
     case .failure(let error):
        // error is a CoreStoreError enum value
     }
 }
 ```
 */
public enum SaveResult: Hashable {
    
    /**
     `SaveResult.success` indicates that the `commit()` for the transaction succeeded, either because the save succeeded or because there were no changes to save. The associated value `hasChanges` indicates if there were saved changes or not.
     */
    case success(hasChanges: Bool)
    
    /**
     `SaveResult.failure` indicates that the `commit()` for the transaction failed. The associated object for this value is a `CoreStoreError` enum value.
     */
    case failure(CoreStoreError)
    
    
    /**
     Returns `true` if the result indicates `.success`, `false` if the result is `.failure`.
     */
    public var boolValue: Bool {
        
        switch self {
            
        case .success: return true
        case .failure: return false
        }
    }
    
    
    // MARK: Hashable
    
    public var hashValue: Int {
        
        switch self {
            
        case .success(let hasChanges):
            return self.boolValue.hashValue ^ hasChanges.hashValue
            
        case .failure(let error):
            return self.boolValue.hashValue ^ error.hashValue
        }
    }
    
    
    // MARK: Internal
    
    internal init(hasChanges: Bool) {
        
        self = .success(hasChanges: hasChanges)
    }
    
    internal init(_ error: CoreStoreError) {
        
        self = .failure(error)
    }
}


// MARK: - SaveResult: Equatable

public func == (lhs: SaveResult, rhs: SaveResult) -> Bool {
    
    switch (lhs, rhs) {
        
    case (.success(let hasChanges1), .success(let hasChanges2)):
        return hasChanges1 == hasChanges2
        
    case (.failure(let error1), .failure(let error2)):
        return error1 == error2
        
    default:
        return false
    }
}
