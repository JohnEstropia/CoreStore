//
//  SectionBy.swift
//  CoreStore
//
//  Copyright © 2015 John Rommel Estropia
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


// MARK: - SectionBy

/**
 The `SectionBy` clause indicates the key path to use to group the `ListMonitor` objects into sections. An optional closure can also be provided to transform the value into an appropriate section name:
 ```
 let monitor = CoreStore.monitorSectionedList(
     From(MyPersonEntity),
     SectionBy("age") { "Age \($0)" },
     OrderBy(.Ascending("lastName"))
 )
 ```
 */
@available(OSX, unavailable)
public struct SectionBy {
    
    /**
     Initializes a `SectionBy` clause with the key path to use to group `ListMonitor` objects into sections
     
     - parameter sectionKeyPath: the key path to use to group the objects into sections
     */
    public init(_ sectionKeyPath: KeyPath) {
        
        self.init(sectionKeyPath, { $0 })
    }
    
    /**
     Initializes a `SectionBy` clause with the key path to use to group `ListMonitor` objects into sections, and a closure to transform the value for the key path to an appropriate section name
     
     - parameter sectionKeyPath: the key path to use to group the objects into sections
     - parameter sectionIndexTransformer: a closure to transform the value for the key path to an appropriate section name
     */
    public init(_ sectionKeyPath: KeyPath, _ sectionIndexTransformer: (sectionName: String?) -> String?) {
        
        self.sectionKeyPath = sectionKeyPath
        self.sectionIndexTransformer = sectionIndexTransformer
    }
    
    
    // MARK: Internal
    
    internal let sectionKeyPath: KeyPath
    internal let sectionIndexTransformer: (sectionName: KeyPath?) -> String?
}
