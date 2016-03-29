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
 */
@objc
public final class CSSetupResult: NSObject {
    
    /**
     `YES` if the `commit` operation for the transaction succeeded, either because the save succeeded or because there were no changes to save. Returns `NO` to indicate failure.
     */
    @objc
    public var isSuccess: Bool {
        
        return self.bridgeToSwift.boolValue
    }
    
    /**
     `YES` if the `commit` operation for the transaction failed, or `NO` otherwise. When `YES`, the `error` property returns the actual `NSError` for the failure.
     */
    @objc
    public var isFailure: Bool {
        
        return !self.bridgeToSwift.boolValue
    }
    
    /**
     A `CSStorageInterface` instance if the `commit` operation for the transaction succeeded. Returns `NO` otherwise.
     */
    @objc
    public var storage: CSStorageInterface? {
        
        guard case .Success(let storage as CoreStoreSwiftType) = self.bridgeToSwift else {
            
            return nil
        }
        return storage.bridgeToObjectiveC
    }
    
    /**
     The `NSError` for a failed `commit` operation, or `nil` if the `commit` succeeded
     */
    @objc
    public var error: NSError? {
        
        guard case .Failure(let error) = self.bridgeToSwift else {
            
            return nil
        }
        return error.bridgeToObjectiveC
    }
    
    /**
     If the result was a success, the `success` block is executed with a `BOOL` argument that indicates if there were any changes made. If the result was a failure, the `failure` block is executed with an `NSError` argument pertaining to the actual error.
     
     The blocks are executed immediately as `@noescape` and will not be retained.
     
     - parameter success: the block to execute on success. The block passes a `BOOL` argument that indicates if there were any changes made.
     - parameter failure: the block to execute on failure. The block passes an `NSError` argument that pertains to the actuall error.
     */
    @objc
    public func handleSuccess(@noescape success: (storage: CSStorageInterface) -> Void, @noescape failure: (error: NSError) -> Void) {
        
        switch self.bridgeToSwift {
            
        case .Success(let storage):
            success(storage: storage.bridgeToObjectiveC)
            
        case .Failure(let error):
            failure(error: error.bridgeToObjectiveC)
        }
    }
    
    /**
     If the result was a success, the `success` block is executed with a `BOOL` argument that indicates if there were any changes made. If the result was a failure, this method does nothing.
     
     The block is executed immediately as `@noescape` and will not be retained.
     
     - parameter success: the block to execute on success. The block passes a `BOOL` argument that indicates if there were any changes made.
     */
    @objc
    public func handleSuccess(@noescape success: (storage: CSStorageInterface) -> Void) {
        
        guard let storageInterface = self.storageInterface else {
            
            return
        }
        success(storage: storage)
    }
    
    /**
     If the result was a failure, the `failure` block is executed with an `NSError` argument pertaining to the actual error. If the result was a success, this method does nothing.
     
     The block is executed immediately as `@noescape` and will not be retained.
     
     - parameter failure: the block to execute on failure. The block passes an `NSError` argument that pertains to the actuall error.
     */
    @objc
    public func handleFailure(@noescape failure: (error: NSError) -> Void) {
        
        guard let coreStoreError = self.coreStoreError else {
            
            return
        }
        failure(error: coreStoreError.bridgeToObjectiveC)
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        if let storageInterface = self.storageInterface {
            
            return self.isSuccess.hashValue ^ ObjectIdentifier(storageInterface).hashValue
        }
        return self.isSuccess.hashValue ^ self.coreStoreError!.hashValue
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        
        guard let object = object as? CSSetupResult else {
            
            return false
        }
        return self.storageInterface === object.storageInterface
            && self.coreStoreError == object.coreStoreError
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public required init<T: StorageInterface>(_ swiftValue: SetupResult<T>) {
        
        switch swiftValue {
            
        case .Success(let storage):
            self.storageInterface = storage
            
        case .Failure(let error):
            self.coreStoreError = error
        }
        super.init()
    }
    
    private var storageInterface: StorageInterface?
    private var coreStoreError: CoreStoreError?
}


// MARK: - SetupResult

extension SetupResult {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSSetupResult {
        
        return CSSetupResult(self)
    }
}
