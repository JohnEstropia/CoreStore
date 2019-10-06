//
//  ListSnapshot.swift
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

#if canImport(UIKit) || canImport(AppKit)

import CoreData

#if canImport(UIKit)
import UIKit

#elseif canImport(AppKit)
import AppKit

#endif


// MARK: - LiveList

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 15.0, *)
public struct ListSnapshot<D: DynamicObject>: SnapshotResult, RandomAccessCollection, Hashable {

    // MARK: Public
    
    public subscript<S: Sequence>(indices: S) -> [ObjectType] where S.Element == Index {
        
        let context = self.context!
        let objectIDs = self.snapshotStruct.itemIdentifiers
        return indices.map { position in
            
            let objectID = objectIDs[position]
            return context.fetchExisting(objectID)!
        }
    }
    
    
    // MARK: SnapshotResult
    
    public typealias ObjectType = D
    
    
    // MARK: RandomAccessCollection
    
    public var startIndex: Index {
        
        return 0
    }
    
    public var endIndex: Index {
        
        return self.snapshotStruct.numberOfItems
    }
    
    public subscript(position: Index) -> ObjectType {
        
        let context = self.context!
        let objectID = self.snapshotStruct.itemIdentifiers[position]
        return context.fetchExisting(objectID)!
    }
    
    
    // MARK: Sequence
    
    public typealias Element = ObjectType
    
    public typealias Index = Int
    
    
    // MARK: Equatable
    
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        
        return lhs.id == rhs.id
    }
    
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher) {
        
        hasher.combine(self.id)
    }
    
    
    // MARK: Internal
    
    internal init() {
        
        self.snapshotReference = .init()
        self.snapshotStruct = self.snapshotReference as NSDiffableDataSourceSnapshot<NSString, NSManagedObjectID>
        self.context = nil
    }
    
    internal init(snapshotReference: NSDiffableDataSourceSnapshotReference, context: NSManagedObjectContext) {
        
        self.snapshotReference = snapshotReference
        self.snapshotStruct = snapshotReference as NSDiffableDataSourceSnapshot<NSString, NSManagedObjectID>
        self.context = context
    }
    
    
    // MARK: Private
    
    private let id: UUID = .init()
    private let snapshotReference: NSDiffableDataSourceSnapshotReference
    private let snapshotStruct: NSDiffableDataSourceSnapshot<NSString, NSManagedObjectID>
    private let context: NSManagedObjectContext?
}

#endif
