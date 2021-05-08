//
//  Internals.PersistentHistoryFetcher.swift
//  CoreStore
//
//  Copyright © 2020 John Rommel Estropia
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


// MARK: - Internals

extension Internals {

    // MARK: - PersistentHistoryFetcher

    internal struct PersistentHistoryFetcher {

        // MARK: Internal

        internal let context: NSManagedObjectContext
        internal let token: NSPersistentHistoryToken?

        internal init(
            context: NSManagedObjectContext,
            token: NSPersistentHistoryToken?
        ) {

            self.context = context
            self.token = token
        }

        internal func fetch() throws -> [NSPersistentHistoryTransaction] {

            let request = self.newFetchRequest()
            let fetchResult = try self.context.execute(request) as! NSPersistentHistoryResult
            return fetchResult.result as! [NSPersistentHistoryTransaction]
        }
        

        // MARK: Private

        private func newFetchRequest() -> NSPersistentHistoryChangeRequest {

            let historyFetchRequest = NSPersistentHistoryChangeRequest.fetchHistory(
                after: self.token
            )
            guard #available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *) else {

                return historyFetchRequest
            }
            guard let transactionFetchRequest = NSPersistentHistoryTransaction.fetchRequest else {

                return historyFetchRequest
            }

            let context = self.context
            transactionFetchRequest.predicate = NSCompoundPredicate(
                type: .and,
                subpredicates: [
                    context.transactionAuthor.map { author in
                        NSPredicate(
                            format: "%K != %@",
                            #keyPath(NSPersistentHistoryTransaction.author),
                            author
                        )
                    },
                    context.name.map { contextName in
                        NSPredicate(
                            format: "%K != %@",
                            #keyPath(NSPersistentHistoryTransaction.contextName),
                            contextName
                        )
                    }
                ]
                .compactMap({ $0 })
            )
            historyFetchRequest.fetchRequest = transactionFetchRequest

            return historyFetchRequest
        }
    }
}
