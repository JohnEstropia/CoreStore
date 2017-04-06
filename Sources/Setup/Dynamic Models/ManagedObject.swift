//
//  ManagedObject.swift
//  CoreStore
//
//  Copyright © 2017 John Rommel Estropia
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

import CoreData
import Foundation


// MARK: - ManagedObject

open class ManagedObject: ManagedObjectProtocol, Hashable {
    
    public required init(_ object: NSManagedObject) {
        
        self.isMeta = false
        self.rawObject = object
        self.initializeAttributes(Mirror(reflecting: self), { [unowned object] in object })
    }
    
    public required init(asMeta: Void) {
        
        self.isMeta = true
        self.rawObject = nil
    }
    
    
    // MARK: Equatable
    
    public static func == (lhs: ManagedObject, rhs: ManagedObject) -> Bool {
        
        guard lhs.isMeta == rhs.isMeta else {
            
            return false
        }
        if lhs.isMeta {
            
            return type(of: lhs) == type(of: rhs)
        }
        return lhs.rawObject!.isEqual(rhs.rawObject!)
    }
    
    
    // MARK: Hashable
    
    public var hashValue: Int {
    
        return ObjectIdentifier(self).hashValue
            ^ (self.isMeta ? 0 : self.rawObject!.hashValue)
    }
    
    
    // MARK: Internal
    
    internal let rawObject: NSManagedObject?
    internal let isMeta: Bool
    
    
    // MARK: Private
    
    private func initializeAttributes(_ mirror: Mirror, _ accessRawObject: @escaping () -> NSManagedObject) {
        
        _ = mirror.superclassMirror.flatMap({ self.initializeAttributes($0, accessRawObject) })
        for child in mirror.children {
            
            switch child.value {
                
            case let property as AttributeProtocol:
                property.accessRawObject = accessRawObject
                    
            case let property as RelationshipProtocol:
                property.accessRawObject = accessRawObject
                
            default:
                continue
            }
        }
    }
}
