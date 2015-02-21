//
//  SortedBy.swift
//  HardcoreData
//
//  Copyright (c) 2015 John Rommel Estropia
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


public func +(left: SortedBy, right: SortedBy) -> SortedBy {
    
    return SortedBy(left.sortDescriptors + right.sortDescriptors)
}


// MARK: - AttributeName
    
public typealias AttributeName = Selector


// MARK: - SortOrder

public enum SortOrder {
    
    case Ascending(AttributeName)
    case Descending(AttributeName)
}


// MARK: - SortedBy

public struct SortedBy: FetchClause {
    
    // MARK: Public
    
    public init(_ sortDescriptors: [NSSortDescriptor]) {
        
        self.sortDescriptors = sortDescriptors
    }
    
    public init() {
        
        self.init([NSSortDescriptor]())
    }
    
    public init(_ sortDescriptor: NSSortDescriptor) {
        
        self.init([sortDescriptor])
    }
    
    public init(_ order: [SortOrder]) {
        
        self.init(order.map { sortOrder -> NSSortDescriptor in
            
            switch sortOrder {
                
            case .Ascending(let attributeName):
                return NSSortDescriptor(
                    key: NSStringFromSelector(attributeName),
                    ascending: true)
                
            case .Descending(let attributeName):
                return NSSortDescriptor(
                    key: NSStringFromSelector(attributeName),
                    ascending: false)
            }
            })
    }
    
    public init(_ order: SortOrder, _ subOrder: SortOrder...) {
        
        self.init([order] + subOrder)
    }
    
    public let sortDescriptors: [NSSortDescriptor]
    
    
    // MARK: QueryClause
    
    public func applyToFetchRequest(fetchRequest: NSFetchRequest) {
        
        if fetchRequest.sortDescriptors != nil {
            
            HardcoreData.log(.Warning, message: "Existing sortDescriptors for the NSFetchRequest was overwritten by SortedBy query clause.")
        }
        
        fetchRequest.sortDescriptors = self.sortDescriptors
    }
}
