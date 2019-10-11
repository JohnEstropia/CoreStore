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

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
extension DataStack {

    public func liveList<D>(_ from: From<D>, _ fetchClauses: FetchClause...) -> LiveList<D> {

        return self.liveList(from, fetchClauses)
    }

    public func liveList<D>(_ from: From<D>, _ fetchClauses: [FetchClause]) -> LiveList<D> {

        return LiveList(
            dataStack: self,
            from: from,
            sectionBy: nil,
            applyFetchClauses: { fetchRequest in

                fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }

                Internals.assert(
                    fetchRequest.sortDescriptors?.isEmpty == false,
                    "An \(Internals.typeName(LiveList<D>.self)) requires a sort information. Specify from a \(Internals.typeName(OrderBy<D>.self)) clause or any custom \(Internals.typeName(FetchClause.self)) that provides a sort descriptor."
                )
            }
        )
    }

    public func liveList<B: FetchChainableBuilderType>(_ clauseChain: B) -> LiveList<B.ObjectType> {

        return self.liveList(
            clauseChain.from,
            clauseChain.fetchClauses
        )
    }

    public func liveList<D>(createAsynchronously: @escaping (LiveList<D>) -> Void, _ from: From<D>, _ fetchClauses: FetchClause...) {

        self.liveList(
            createAsynchronously: createAsynchronously,
            from, fetchClauses
        )
    }

    public func liveList<D>(createAsynchronously: @escaping (LiveList<D>) -> Void, _ from: From<D>, _ fetchClauses: [FetchClause])  {

        _ = LiveList(
            dataStack: self,
            from: from,
            sectionBy: nil,
            applyFetchClauses: { fetchRequest in

                fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }

                Internals.assert(
                    fetchRequest.sortDescriptors?.isEmpty == false,
                    "An \(Internals.typeName(LiveList<D>.self)) requires a sort information. Specify from a \(Internals.typeName(OrderBy<D>.self)) clause or any custom \(Internals.typeName(FetchClause.self)) that provides a sort descriptor."
                )
            },
            createAsynchronously: createAsynchronously
        )
    }

    public func liveList<D>(_ from: From<D>, _ sectionBy: SectionBy<D>, _ fetchClauses: FetchClause...) -> LiveList<D> {

        return self.liveList(
            from,
            sectionBy,
            fetchClauses
        )
    }

    public func liveList<D>(_ from: From<D>, _ sectionBy: SectionBy<D>, _ fetchClauses: [FetchClause]) -> LiveList<D> {

        return LiveList(
            dataStack: self,
            from: from,
            sectionBy: sectionBy,
            applyFetchClauses: { fetchRequest in

                fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }

                Internals.assert(
                    fetchRequest.sortDescriptors?.isEmpty == false,
                    "An \(Internals.typeName(LiveList<D>.self)) requires a sort information. Specify from a \(Internals.typeName(OrderBy<D>.self)) clause or any custom \(Internals.typeName(FetchClause.self)) that provides a sort descriptor."
                )
            }
        )
    }

    public func liveList<B: SectionMonitorBuilderType>(_ clauseChain: B) -> LiveList<B.ObjectType> {

        return self.liveList(
            clauseChain.from,
            clauseChain.sectionBy,
            clauseChain.fetchClauses
        )
    }

    public func liveList<D>(createAsynchronously: @escaping (LiveList<D>) -> Void, _ from: From<D>, _ sectionBy: SectionBy<D>, _ fetchClauses: FetchClause...) {

        self.liveList(
            createAsynchronously: createAsynchronously,
            from,
            sectionBy,
            fetchClauses
        )
    }

    public func liveList<D>(createAsynchronously: @escaping (LiveList<D>) -> Void, _ from: From<D>, _ sectionBy: SectionBy<D>, _ fetchClauses: [FetchClause]) {

        _ = LiveList(
            dataStack: self,
            from: from,
            sectionBy: sectionBy,
            applyFetchClauses: { fetchRequest in

                fetchClauses.forEach { $0.applyToFetchRequest(fetchRequest) }

                Internals.assert(
                    fetchRequest.sortDescriptors?.isEmpty == false,
                    "An \(Internals.typeName(LiveList<D>.self)) requires a sort information. Specify from a \(Internals.typeName(OrderBy<D>.self)) clause or any custom \(Internals.typeName(FetchClause.self)) that provides a sort descriptor."
                )
            },
            createAsynchronously: createAsynchronously
        )
    }

    public func liveList<B: SectionMonitorBuilderType>(createAsynchronously: @escaping (LiveList<B.ObjectType>) -> Void, _ clauseChain: B) {

        self.liveList(
            createAsynchronously: createAsynchronously,
            clauseChain.from,
            clauseChain.sectionBy,
            clauseChain.fetchClauses
        )
    }
}

#endif
