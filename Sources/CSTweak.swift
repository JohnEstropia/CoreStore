//
//  CSTweak.swift
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


// MARK: - CSTweak

/**
 The `CSTweak` serves as the Objective-C bridging type for `Tweak`.
 
 - SeeAlso: `Tweak`
 */
@objc
public final class CSTweak: NSObject, CSFetchClause, CSQueryClause, CSDeleteClause, CoreStoreObjectiveCType {
    
    /**
     The block to customize the `NSFetchRequest`
     */
    @objc
    public var block: (_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> Void {
        
        return self.bridgeToSwift.closure
    }
    
    /**
     Initializes a `CSTweak` clause with a closure where the `NSFetchRequest` may be configured.
     
     - Important: `CSTweak`'s closure is executed only just before the fetch occurs, so make sure that any values captured by the closure is not prone to race conditions. Also, some utilities (such as `CSListMonitor`s) may keep `CSFetchClause`s in memory and may thus introduce retain cycles if reference captures are not handled properly.
     - parameter block: the block to customize the `NSFetchRequest`
     */
    @objc
    public convenience init(block: @escaping (_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> Void) {
        
        self.init(Tweak(block))
    }
    
    
    // MARK: NSObject
    
    public override var description: String {
        
        return "(\(String(reflecting: type(of: self)))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CSFetchClause, CSQueryClause, CSDeleteClause
    
    @objc
    public func applyToFetchRequest(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        
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
    
    public var bridgeToObjectiveC: CSTweak {
        
        return CSTweak(self)
    }
}
