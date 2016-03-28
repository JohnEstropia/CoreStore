//
//  CSTweak.swift
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


// MARK: - CSTweak

/**
 The `CSTweak` serves as the Objective-C bridging type for `Tweak`.
 */
@objc
public final class CSTweak: NSObject, CSFetchClause, CSQueryClause, CSDeleteClause, CoreStoreObjectiveCType {
    
    /**
     Initializes a `CSTweak` clause with a closure where the `NSFetchRequest` may be configured.
     
     - parameter customization: a list of key path strings to group results with
     - returns: a `CSTweak` clause with a closure where the `NSFetchRequest` may be configured
     */
    @objc
    public static func customization(customization: (fetchRequest: NSFetchRequest) -> Void) -> CSTweak {
        
        return self.init(Tweak(customization))
    }
    
    
    // MARK: CSFetchClause, CSQueryClause, CSDeleteClause
    
    @objc
    public func applyToFetchRequest(fetchRequest: NSFetchRequest) {
        
        self.bridgeToSwift.applyToFetchRequest(fetchRequest)
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: Tweak
    
    public init(_ swiftValue: Tweak) {
        
        self.bridgeToSwift = swiftValue
        super.init()
    }
}


// MARK: - Tweak

extension Tweak: CoreStoreSwiftType {
    
    // MARK: CoreStoreSwiftType
    
    public typealias ObjectiveCType = CSTweak
}
