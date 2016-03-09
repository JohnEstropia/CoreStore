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
     case .Success(let hasChanges):
        // hasChanges indicates if there were changes or not
     case .Failure(let error):
        // error is the NSError instance for the failure
     }
 }
 ```
 */
public enum SaveResult {
    
    /**
     `SaveResult.Success` indicates that the `commit()` for the transaction succeeded, either because the save succeeded or because there were no changes to save. The associated value `hasChanges` indicates if there were saved changes or not.
     */
    case Success(hasChanges: Bool)
    
    /**
     `SaveResult.Failure` indicates that the `commit()` for the transaction failed. The associated object for this value is the related `NSError` instance.
     */
    case Failure(NSError)
    
    
    // MARK: Internal
    
    internal init(hasChanges: Bool) {
        
        self = .Success(hasChanges: hasChanges)
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


// MARK: - SaveResult: BooleanType

extension SaveResult: BooleanType {
    
    public var boolValue: Bool {
        
        switch self {
            
        case .Success: return true
        case .Failure: return false
        }
    }
}
