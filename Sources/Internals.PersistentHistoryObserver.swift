//
//  Internals.PersistentHistoryObserver.swift
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

    // MARK: - PersistentHistoryObserver

    internal final class PersistentHistoryObserver {

        // MARK: Internal

        internal init(
            appGroupIdentifier: AppGroupsManager.AppGroupID,
            bundleID: AppGroupsManager.BundleID,
            storageID: AppGroupsManager.StorageID,
            dataStack: DataStack
        ) {

            self.appGroupIdentifier = appGroupIdentifier
            self.bundleID = bundleID
            self.storageID = storageID
            self.dataStack = dataStack
        }

        internal func startObserving() {

            if #available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *) {

                self.observerForRemoteChangeNotification = Internals.NotificationObserver(
                    notificationName: .NSPersistentStoreRemoteChange,
                    object: self,
                    closure: { [weak self] (note) -> Void in

                        guard let `self` = self else {

                            return
                        }
                        self.historyQueue.addOperation { [weak self] in

                            self?.processPersistentHistory()
                        }
                    }
                )
            }
            else {

                #warning("TODO: handle remote changes for iOS 11 & 12")
            }
        }


        // MARK: Private

        private let appGroupIdentifier: AppGroupsManager.AppGroupID
        private let bundleID: AppGroupsManager.BundleID
        private let storageID: AppGroupsManager.StorageID
        private let dataStack: DataStack

        private var observerForRemoteChangeNotification: Internals.NotificationObserver?

        private lazy var historyQueue: OperationQueue = Internals.with {

            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1
            return queue
        }

        private func processPersistentHistory() {

            self.dataStack.perform(
                asynchronous: { transaction -> NSPersistentHistoryToken? in

                    let token = try AppGroupsManager.existingToken(
                        appGroupIdentifier: self.appGroupIdentifier,
                        bundleID: self.bundleID,
                        storageID: self.storageID
                    )

                    let context = transaction.unsafeContext()
                    let fetcher = PersistentHistoryFetcher(
                        context: context,
                        token: token
                    )
                    let history = try fetcher.fetch()
                    guard !history.isEmpty else {

                        return nil
                    }

                    context.merge(fromPersistentHistory: history)

                    return history.last?.token
                },
                success: { token in

                    guard let token = token else {

                        return
                    }
                    do {

                        try AppGroupsManager.setExistingToken(
                            token,
                            appGroupIdentifier: self.appGroupIdentifier,
                            bundleID: self.bundleID,
                            storageID: self.storageID
                        )
                    }
                    catch {

                        #warning("TODO: handle error")
                    }
                },
                failure: { error in

                    #warning("TODO: handle error")
                }
            )
        }
    }
}
