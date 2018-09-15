//
//  CSSaveResult.swift
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


// MARK: - CSSaveResult

@available(*, deprecated, message: "Use APIs that report failures with `CSError`s instead.")
@objc
public final class CSSaveResult: NSObject, CoreStoreObjectiveCType {
    
    @objc
    public var isSuccess: Bool {
        
        return self.bridgeToSwift.boolValue
    }
    
    @objc
    public var isFailure: Bool {
        
        return !self.bridgeToSwift.boolValue
    }
    
    @objc
    public var hasChanges: Bool {
        
        guard case .success(let hasChanges) = self.bridgeToSwift else {
            
            return false
        }
        return hasChanges
    }
    
    @objc
    public var error: NSError? {
        
        guard case .failure(let error) = self.bridgeToSwift else {
            
            return nil
        }
        return error.bridgeToObjectiveC
    }
    
    @objc
    public func handleSuccess(_ success: (_ hasChanges: Bool) -> Void, failure: (_ error: NSError) -> Void) {
        
        switch self.bridgeToSwift {
            
        case .success(let hasChanges):
            success(hasChanges)
            
        case .failure(let error):
            failure(error.bridgeToObjectiveC)
        }
    }
    
    @objc
    public func handleSuccess(_ success: (_ hasChanges: Bool) -> Void) {
        
        guard case .success(let hasChanges) = self.bridgeToSwift else {
            
            return
        }
        success(hasChanges)
    }
    
    @objc
    public func handleFailure(_ failure: (_ error: NSError) -> Void) {
        
        guard case .failure(let error) = self.bridgeToSwift else {
                
            return
        }
        failure(error.bridgeToObjectiveC)
    }
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.bridgeToSwift.hashValue
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        guard let object = object as? CSSaveResult else {
            
            return false
        }
        return self.bridgeToSwift == object.bridgeToSwift
    }
    
    public override var description: String {
        
        return "(\(String(reflecting: type(of: self)))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: SaveResult
    
    public required init(_ swiftValue: SaveResult) {
        
        self.bridgeToSwift = swiftValue
        super.init()
    }
}


// MARK: - SaveResult

@available(*, deprecated, message: "Use the new DataStack.perform(asynchronous:...) and DataStack.perform(synchronous:...) family of APIs")
extension SaveResult: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSSaveResult {
        
        return CSSaveResult(self)
    }
}
