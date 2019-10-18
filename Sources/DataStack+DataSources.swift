//
//  DataStack+DataSources.swift
//  CoreStore iOS
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

import Foundation
import CoreData


// MARK: - DataStack

extension DataStack {
    
    /**
     Creates a `ObjectPublisher` for the specified `DynamicObject`. Multiple objects may then register themselves to be notified when changes are made to the `DynamicObject`.
     
     - parameter object: the `DynamicObject` to observe changes from
     - returns: a `ObjectPublisher` that broadcasts changes to `object`
     */
    public func objectPublisher<O: DynamicObject>(_ object: O) -> ObjectPublisher<O> {

        return ObjectPublisher<O>(objectID: object.cs_id(), context: self.unsafeContext())
    }

    public func listPublisher<D>(_ from: From<D>, _ fetchClauses: FetchClause...) -> ListPublisher<D> {

        return self.listPublisher(from, fetchClauses)
    }

    public func listPublisher<D>(_ from: From<D>, _ fetchClauses: [FetchClause]) -> ListPublisher<D> {

        return ListPublisher(
            dataStack: self,
            from: from,
            sectionBy: nil,
            applyFetchClauses: { fetchRequest in

                fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }

                Internals.assert(
                    fetchRequest.sortDescriptors?.isEmpty == false,
                    "An \(Internals.typeName(ListPublisher<D>.self)) requires a sort information. Specify from a \(Internals.typeName(OrderBy<D>.self)) clause or any custom \(Internals.typeName(FetchClause.self)) that provides a sort descriptor."
                )
            }
        )
    }

    public func listPublisher<B: FetchChainableBuilderType>(_ clauseChain: B) -> ListPublisher<B.ObjectType> {

        return self.listPublisher(
            clauseChain.from,
            clauseChain.fetchClauses
        )
    }

    public func listPublisher<D>(createAsynchronously: @escaping (ListPublisher<D>) -> Void, _ from: From<D>, _ fetchClauses: FetchClause...) {

        self.listPublisher(
            createAsynchronously: createAsynchronously,
            from, fetchClauses
        )
    }

    public func listPublisher<D>(createAsynchronously: @escaping (ListPublisher<D>) -> Void, _ from: From<D>, _ fetchClauses: [FetchClause])  {

        _ = ListPublisher(
            dataStack: self,
            from: from,
            sectionBy: nil,
            applyFetchClauses: { fetchRequest in

                fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }

                Internals.assert(
                    fetchRequest.sortDescriptors?.isEmpty == false,
                    "An \(Internals.typeName(ListPublisher<D>.self)) requires a sort information. Specify from a \(Internals.typeName(OrderBy<D>.self)) clause or any custom \(Internals.typeName(FetchClause.self)) that provides a sort descriptor."
                )
            },
            createAsynchronously: createAsynchronously
        )
    }

    public func listPublisher<D>(_ from: From<D>, _ sectionBy: SectionBy<D>, _ fetchClauses: FetchClause...) -> ListPublisher<D> {

        return self.listPublisher(
            from,
            sectionBy,
            fetchClauses
        )
    }

    public func listPublisher<D>(_ from: From<D>, _ sectionBy: SectionBy<D>, _ fetchClauses: [FetchClause]) -> ListPublisher<D> {

        return ListPublisher(
            dataStack: self,
            from: from,
            sectionBy: sectionBy,
            applyFetchClauses: { fetchRequest in

                fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }

                Internals.assert(
                    fetchRequest.sortDescriptors?.isEmpty == false,
                    "An \(Internals.typeName(ListPublisher<D>.self)) requires a sort information. Specify from a \(Internals.typeName(OrderBy<D>.self)) clause or any custom \(Internals.typeName(FetchClause.self)) that provides a sort descriptor."
                )
            }
        )
    }

    public func listPublisher<B: SectionMonitorBuilderType>(_ clauseChain: B) -> ListPublisher<B.ObjectType> {

        return self.listPublisher(
            clauseChain.from,
            clauseChain.sectionBy,
            clauseChain.fetchClauses
        )
    }

    public func listPublisher<D>(createAsynchronously: @escaping (ListPublisher<D>) -> Void, _ from: From<D>, _ sectionBy: SectionBy<D>, _ fetchClauses: FetchClause...) {

        self.listPublisher(
            createAsynchronously: createAsynchronously,
            from,
            sectionBy,
            fetchClauses
        )
    }

    public func listPublisher<D>(createAsynchronously: @escaping (ListPublisher<D>) -> Void, _ from: From<D>, _ sectionBy: SectionBy<D>, _ fetchClauses: [FetchClause]) {

        _ = ListPublisher(
            dataStack: self,
            from: from,
            sectionBy: sectionBy,
            applyFetchClauses: { fetchRequest in

                fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }

                Internals.assert(
                    fetchRequest.sortDescriptors?.isEmpty == false,
                    "An \(Internals.typeName(ListPublisher<D>.self)) requires a sort information. Specify from a \(Internals.typeName(OrderBy<D>.self)) clause or any custom \(Internals.typeName(FetchClause.self)) that provides a sort descriptor."
                )
            },
            createAsynchronously: createAsynchronously
        )
    }

    public func listPublisher<B: SectionMonitorBuilderType>(createAsynchronously: @escaping (ListPublisher<B.ObjectType>) -> Void, _ clauseChain: B) {

        self.listPublisher(
            createAsynchronously: createAsynchronously,
            clauseChain.from,
            clauseChain.sectionBy,
            clauseChain.fetchClauses
        )
    }
}

#endif
