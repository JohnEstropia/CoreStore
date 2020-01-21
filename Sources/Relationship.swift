//
//  Relationship.swift
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

import CoreData
import Foundation


// MARK: - DynamicObject

extension DynamicObject where Self: CoreStoreObject {
    
    /**
     The containing type for relationships. `Relationship`s can be any `CoreStoreObject` subclass.
     ```
     class Dog: CoreStoreObject {
         let master = Relationship.ToOne<Person>("master")
     }
     class Person: CoreStoreObject {
         let pets = Relationship.ToManyUnordered<Dog>("pets", inverse: { $0.master })
     }
     ```
     - Important: `Relationship` properties are required to be stored properties. Computed properties will be ignored, including `lazy` and `weak` properties.
     */
    public typealias Relationship = RelationshipContainer<Self>
}


// MARK: - RelationshipContainer

/**
 The containing type for relationships. Use the `DynamicObject.Relationship` typealias instead for shorter syntax.
 ```
 class Dog: CoreStoreObject {
     let master = Relationship.ToOne<Person>("master")
 }
 class Person: CoreStoreObject {
     let pets = Relationship.ToManyUnordered<Dog>("pets", inverse: { $0.master })
 }
 ```
 */
public enum RelationshipContainer<O: CoreStoreObject> {
    
    // MARK: - DeleteRule

    /**
     These constants define what happens to relationships when an object is deleted.
     */
    public enum DeleteRule {

        // MARK: Public
        
        case nullify
        case cascade
        case deny


        // MARK: Internal
        
        internal var nativeValue: NSDeleteRule {
            
            switch self {
                
            case .nullify:  return .nullifyDeleteRule
            case .cascade:  return .cascadeDeleteRule
            case .deny:     return .denyDeleteRule
            }
        }
    }
}
