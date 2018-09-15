//
//  CSSectionBy.swift
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


// MARK: - CSSectionBy

/**
 The `CSSectionBy` serves as the Objective-C bridging type for `SectionBy`.
 
 - SeeAlso: `SectionBy`
 */
@available(macOS 10.12, *)
@objc
public final class CSSectionBy: NSObject {
    
    /**
     Initializes a `CSSectionBy` clause with the key path to use to group `CSListMonitor` objects into sections
     
     - parameter sectionKeyPath: the key path to use to group the objects into sections
     - returns: a `CSSectionBy` clause with the key path to use to group `CSListMonitor` objects into sections
     */
    @objc
    public static func keyPath(_ sectionKeyPath: KeyPathString) -> CSSectionBy {
        
        return self.init(SectionBy<NSManagedObject>(sectionKeyPath))
    }
    
    /**
     Initializes a `CSSectionBy` clause with the key path to use to group `CSListMonitor` objects into sections, and a closure to transform the value for the key path to an appropriate section name
     
     - parameter sectionKeyPath: the key path to use to group the objects into sections
     - parameter sectionIndexTransformer: a closure to transform the value for the key path to an appropriate section name
     - returns: a `CSSectionBy` clause with the key path to use to group `CSListMonitor` objects into sections
     */
    @objc
    public static func keyPath(_ sectionKeyPath: KeyPathString, sectionIndexTransformer: @escaping (_ sectionName: String?) -> String?) -> CSSectionBy {
        
        return self.init(SectionBy<NSManagedObject>(sectionKeyPath, sectionIndexTransformer))
    }
    
    
    // MARK: NSObject
    
    public override var description: String {
        
        return "(\(String(reflecting: type(of: self)))) \(self.bridgeToSwift.coreStoreDumpString)"
    }
    
    
    // MARK: CoreStoreObjectiveCType
    
    public let bridgeToSwift: SectionBy<NSManagedObject>
    
    public init<D>(_ swiftValue: SectionBy<D>) {
        
        self.bridgeToSwift = swiftValue.downcast()
        super.init()
    }
}


// MARK: - SectionBy

@available(macOS 10.12, *)
extension SectionBy {
    
    // MARK: CoreStoreSwiftType
    
    public var bridgeToObjectiveC: CSSectionBy {
        
        return CSSectionBy(self)
    }
    
    
    // MARK: FilePrivate
    
    fileprivate func downcast() -> SectionBy<NSManagedObject> {
        
        return SectionBy<NSManagedObject>(self.sectionKeyPath, self.sectionIndexTransformer)
    }
}
