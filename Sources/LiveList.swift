//
//  LiveList.swift
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

#if canImport(Combine)

import Combine
import CoreData


// MARK: - LiveList

@available(iOS 13.0, *)
public class LiveList<D: DynamicObject>: Hashable, ObservableObject {
    
    // MARK: Public (Accessors)
    
    /**
     The type for the objects contained bye the `ListMonitor`
     */
    public typealias ObjectType = D
    
    public var snapshot: Snapshot = []
    
    
    // MARK: ObservableObject
    
    public var objectWillChange: ObservableObjectPublisher {
        
        return self.cs_toRaw().objectWillChange
    }
    
    
    // MARK: Private
    
    private let observer: Internals.FetchedResultsControllerDelegate
    
    
    // MARK: - Snapshot
    
    public struct Snapshot: RandomAccessCollection {

        // MARK: RandomAccessCollection
        
        public var startIndex: Index {
            
        }

        public var endIndex: Index {
        
        }

        public subscript(position: Index) -> ObjectType {
        
        }
        
        
        // MARK: Sequence

        public typealias Element = ObjectType

        public typealias Index = Int

//        public typealias SubSequence = Slice<Snapshot<ObjectType>>
//
//        /// A type that represents the indices that are valid for subscripting the
//        /// collection, in ascending order.
//        public typealias Indices = Range<Int>
//
//        /// A type that provides the collection's iteration interface and
//        /// encapsulates its iteration state.
//        ///
//        /// By default, a collection conforms to the `Sequence` protocol by
//        /// supplying `IndexingIterator` as its associated `Iterator`
//        /// type.
//        public typealias Iterator = IndexingIterator<FetchedResults<Result>>
        
        private let diffableSource: NSDiffable
    }
}

extension ListMonitor: ObservableObject {

    public var objectWillChange: ObservableObjectPublisher {
        
        return withUnsafePointer(to: &Static.objectWillChange) {
            self.userInfo[
                $0,
                lazyInit: ObservableObjectPublisher.init
            ] as! ObservableObjectPublisher
        }
    }
}

@available(iOS 13.0, *)
extension CoreStoreObject: ObservableObject {
    
    public var objectWillChange: ObservableObjectPublisher {
        
        return self.cs_toRaw().objectWillChange
    }
}

fileprivate enum Static {
    
    static var objectWillChange: Void?
}

#endif
