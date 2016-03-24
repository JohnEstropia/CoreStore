//
//  CSSaveResult.swift
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


// MARK: - CSSaveResult

/**
 The `CSSaveResult` serves as the Objective-C bridging type for `SaveResult`.
 */
@objc
public final class CSSaveResult: NSObject, CoreStoreBridge {
    
    
    
    // MARK: NSObject
    
    public override var hash: Int {
        
        return self.swift.hashValue
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        
        guard let object = object as? CSSaveResult else {
            
            return false
        }
        return self.swift == object.swift
    }
    
    
    // MARK: CoreStoreBridge
    
    internal let swift: SaveResult
    
    public required init(_ swiftObject: SaveResult) {
        
        self.swift = swiftObject
        super.init()
    }
}


// MARK: - SaveResult

extension SaveResult: CoreStoreBridgeable {
    
    // MARK: CoreStoreBridgeable
    
    internal typealias ObjCType = CSSaveResult
}
