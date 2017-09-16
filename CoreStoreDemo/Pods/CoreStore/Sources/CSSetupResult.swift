//
//  CSSetupResult.swift
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


// MARK: - CSSetupResult

/**
 The `CSSetupResult` serves as the Objective-C bridging type for `SetupResult`.
 
 - SeeAlso: `SetupResult`
 */
@objc
public final class CSSetupResult: NSObject {
    
    /**
     `YES` if adding the `CSStorageInterface` to the `CSDataStack` succeeded, `NO` otherwise.
     */
    @objc
    public var isSuccess: Bool {
        
        return self.storage != nil
    }
    
    /**
     `YES` if adding the `CSStorageInterface` to the `CSDataStack` failed, `NO` otherwise. When `YES`, the `error` property returns the actual `NSError` for the failure.
     */
    @objc
    public var isFailure: Bool {
        
        return self.storage == nil
    }
    
    /**
     A `CSStorageInterface` instance if the `commit` operation for the transaction succeeded. Returns `nil` otherwise.
     */
    @objc
    public let storage: CSStorageInterface?
    
    /**
     The `NSError` for a failed `commit` operation, or `nil` if the `commit` succeeded
     */
    @objc
    public let error: NSError?
    
    /**
     If the result was a success, the `success` block is executed with the `CSStorageInterface` instance that was added to the `CSDataStack`. If the result was a failure, the `failure` block is executed with an `NSError` argument pertaining to the actual error.
     
     The blocks are executed immediately as `@noescape` and will not be retained.
     
     - parameter success: the block to execute on success. The block passes a `CSStorageInterface` instance that was added to the `CSDataStack`.
     - parameter failure: the block to execute on failure. The block passes an `NSError` argument that pertains to the actual error.
     */
    @objc
    public func handleSuccess(_ success: (_ storage: CSStorageInterface) -> Void, failure: (_ error: NSError) -> Void) {
        
        if let storage = self.storage {
            
            success(storage)
        }
        else {
            
            failure(self.error!)
        }
    }
    
    /**
     If the result was a success, the `success` block is executed with a `BOOL` argument that indicates if there were any changes made. If the result was a failure, this method does nothing.
     
     The block is executed immediately as `@noescape` and will not be retained.
     
     - parameter success: the block to execute on success. The block passes a `BOOL` argument that indicates if there were any changes made.
     */
    @objc
    public func handleSuccess(_ success: (_ storage: CSStorageInterface) -> Void) {
        
        guard let storage = self.storage else {
            
            return
        }
        success(storage)
    }
    
    /**
     If the result was a failure, the `failure` block is executed with an `NSError` argument pertaining to the actual error. If the result was a success, this method does nothing.
     
     The block is executed immediately as `@noescape` and will not be retained.
     
     - parameter failure: the block to execute on failure. The block passes an `NSError` argument that pertains to the actual error.
     */
    @objc
    public func handleFailure(_ failure: (_ error: NSError) -> Void) {
        
        guard let error = self.error else {
            
            return
        }
        failure(error)
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        if let storage = self.storage {
            
            return self.isSuccess.hashValue ^ ObjectIdentifier(storage).hashValue
        }
        return self.isSuccess.hashValue ^ self.error!.hashValue
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        guard let object = object as? CSSetupResult else {
            
            return false
        }
        return self.storage === object.storage
            && self.error == object.error
    }

    public override var description: String {
        
        return "(\(String(reflecting: type(of: self)))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public required init<T: StorageInterface>(_ swiftValue: SetupResult<T>) where T: CoreStoreSwiftType, T.ObjectiveCType: CSStorageInterface {
        
        switch swiftValue {
            
        case .success(let storage):
            self.storage = storage.bridgeToObjectiveC
            self.error = nil
            
        case .failure(let error):
            self.storage = nil
            self.error = error.bridgeToObjectiveC
        }
        self.bridgeToSwift = swiftValue
        super.init()
    }
    
    
    // MARK: Private
    
    private let bridgeToSwift: CoreStoreDebugStringConvertible
}


// MARK: - SetupResult

extension SetupResult where T: CoreStoreSwiftType, T.ObjectiveCType: CSStorageInterface {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSSetupResult {
        
        return CSSetupResult(self)
    }
}
