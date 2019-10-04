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

#if canImport(UIKit) || canImport(AppKit)

import CoreData

#if canImport(UIKit)
import UIKit

#elseif canImport(AppKit)
import AppKit

#endif

#if canImport(SwiftUI)
import SwiftUI

#endif


// MARK: - LiveList

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 15.0, *)
public final class LiveList<D: DynamicObject>: Hashable {
    
    // MARK: Public (Accessors)
    
    /**
     The type for the objects contained bye the `ListMonitor`
     */
    public typealias ObjectType = D
    
    public fileprivate(set) var snapshot: Snapshot = .empty {

        didSet {


            #if canImport(Combine)

            let newValue = self.snapshot
            guard newValue != oldValue else {

                return
            }

            #if canImport(SwiftUI)
            withAnimation {

                self.objectWillChange.send()
            }

            #else
            self.objectWillChange.send()

            #endif

            #endif
        }
    }


    // MARK: Equatable

    public static func == (_ lhs: LiveList<D>, _ rhs: LiveList<D>) -> Bool {

        return lhs === rhs
    }


    // MARK: Hashable

    public func hash(into hasher: inout Hasher) {

        hasher.combine(ObjectIdentifier(self))
    }


    // MARK: Internal

    internal convenience init(dataStack: DataStack, from: From<ObjectType>, sectionBy: SectionBy<ObjectType>?, applyFetchClauses: @escaping (_ fetchRequest: Internals.CoreStoreFetchRequest<NSManagedObject>) -> Void) {

        self.init(
            context: dataStack.mainContext,
            from: from,
            sectionBy: sectionBy,
            applyFetchClauses: applyFetchClauses,
            createAsynchronously: nil
        )
    }

    internal convenience init(dataStack: DataStack, from: From<ObjectType>, sectionBy: SectionBy<ObjectType>?, applyFetchClauses: @escaping (_ fetchRequest:  Internals.CoreStoreFetchRequest<NSManagedObject>) -> Void, createAsynchronously: @escaping (LiveList<ObjectType>) -> Void) {

        self.init(
            context: dataStack.mainContext,
            from: from,
            sectionBy: sectionBy,
            applyFetchClauses: applyFetchClauses,
            createAsynchronously: createAsynchronously
        )
    }

    internal convenience init(unsafeTransaction: UnsafeDataTransaction, from: From<ObjectType>, sectionBy: SectionBy<ObjectType>?, applyFetchClauses: @escaping (_ fetchRequest:  Internals.CoreStoreFetchRequest<NSManagedObject>) -> Void) {

        self.init(
            context: unsafeTransaction.context,
            from: from,
            sectionBy: sectionBy,
            applyFetchClauses: applyFetchClauses,
            createAsynchronously: nil
        )
    }

    internal convenience init(unsafeTransaction: UnsafeDataTransaction, from: From<ObjectType>, sectionBy: SectionBy<ObjectType>?, applyFetchClauses: @escaping (_ fetchRequest:  Internals.CoreStoreFetchRequest<NSManagedObject>) -> Void, createAsynchronously: @escaping (LiveList<ObjectType>) -> Void) {

        self.init(
            context: unsafeTransaction.context,
            from: from,
            sectionBy: sectionBy,
            applyFetchClauses: applyFetchClauses,
            createAsynchronously: createAsynchronously
        )
    }


    // MARK: FilePrivate

    fileprivate let rawObjectWillChange: Any?
    
    
    // MARK: Private

    private var fetchedResultsController: Internals.CoreStoreFetchedResultsController
    private var fetchedResultsControllerDelegate: Internals.FetchedDiffableDataSourceSnapshotDelegate
    private var applyFetchClauses: (_ fetchRequest: Internals.CoreStoreFetchRequest<NSManagedObject>) -> Void
    private var observerForWillChangePersistentStore: Internals.NotificationObserver!
    private var observerForDidChangePersistentStore: Internals.NotificationObserver!

    private let from: From<ObjectType>
    private let sectionBy: SectionBy<ObjectType>?

    private static func recreateFetchedResultsController(context: NSManagedObjectContext, from: From<ObjectType>, sectionBy: SectionBy<ObjectType>?, applyFetchClauses: @escaping (_ fetchRequest: Internals.CoreStoreFetchRequest<NSManagedObject>) -> Void) -> (controller: Internals.CoreStoreFetchedResultsController, delegate: Internals.FetchedDiffableDataSourceSnapshotDelegate) {

        let fetchRequest = Internals.CoreStoreFetchRequest<NSManagedObject>()
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .managedObjectResultType
        fetchRequest.includesPendingChanges = false
        fetchRequest.shouldRefreshRefetchedObjects = true

        let fetchedResultsController = Internals.CoreStoreFetchedResultsController(
            context: context,
            fetchRequest: fetchRequest,
            from: from,
            sectionBy: sectionBy,
            applyFetchClauses: applyFetchClauses
        )

        let fetchedResultsControllerDelegate = Internals.FetchedDiffableDataSourceSnapshotDelegate()
        fetchedResultsControllerDelegate.fetchedResultsController = fetchedResultsController

        return (fetchedResultsController, fetchedResultsControllerDelegate)
    }

    private init(context: NSManagedObjectContext, from: From<ObjectType>, sectionBy: SectionBy<ObjectType>?, applyFetchClauses: @escaping (_ fetchRequest: Internals.CoreStoreFetchRequest<NSManagedObject>) -> Void, createAsynchronously: ((LiveList<ObjectType>) -> Void)?) {

        self.from = from
        self.sectionBy = sectionBy
        (self.fetchedResultsController, self.fetchedResultsControllerDelegate) = Self.recreateFetchedResultsController(
            context: context,
            from: from,
            sectionBy: sectionBy,
            applyFetchClauses: applyFetchClauses
        )

        #if canImport(Combine)
        self.rawObjectWillChange = ObservableObjectPublisher()

        #else
        self.rawObjectWillChange = nil

        #endif


//        if let sectionIndexTransformer = sectionBy?.sectionIndexTransformer {
//
//            self.sectionIndexTransformer = sectionIndexTransformer
//        }
//        else {
//
//            self.sectionIndexTransformer = { $0 }
//        }
        self.applyFetchClauses = applyFetchClauses
        self.fetchedResultsControllerDelegate.handler = self

        guard let coordinator = context.parentStack?.coordinator else {

            return
        }

        self.observerForWillChangePersistentStore = Internals.NotificationObserver(
            notificationName: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange,
            object: coordinator,
            queue: OperationQueue.main,
            closure: { [weak self] (note) -> Void in

                guard let `self` = self else {

                    return
                }

//                self.isPersistentStoreChanging = true
//
//                guard let removedStores = (note.userInfo?[NSRemovedPersistentStoresKey] as? [NSPersistentStore]).flatMap(Set.init),
//                    !Set(self.fetchedResultsController.typedFetchRequest.safeAffectedStores() ?? []).intersection(removedStores).isEmpty else {
//
//                        return
//                }
//                self.refetch(self.applyFetchClauses)
            }
        )

        self.observerForDidChangePersistentStore = Internals.NotificationObserver(
            notificationName: NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange,
            object: coordinator,
            queue: OperationQueue.main,
            closure: { [weak self] (note) -> Void in

                guard let `self` = self else {

                    return
                }

//                if !self.isPendingRefetch {
//
//                    let previousStores = Set(self.fetchedResultsController.typedFetchRequest.safeAffectedStores() ?? [])
//                    let currentStores = previousStores
//                        .subtracting(note.userInfo?[NSRemovedPersistentStoresKey] as? [NSPersistentStore] ?? [])
//                        .union(note.userInfo?[NSAddedPersistentStoresKey] as? [NSPersistentStore] ?? [])
//
//                    if previousStores != currentStores {
//
//                        self.refetch(self.applyFetchClauses)
//                    }
//                }
//
//                self.isPersistentStoreChanging = false
            }
        )

        if let createAsynchronously = createAsynchronously {

//            transactionQueue.async {
//
//                try! self.fetchedResultsController.performFetchFromSpecifiedStores()
//                self.taskGroup.notify(queue: .main) {
//
//                    createAsynchronously(self)
//                }
//            }
        }
        else {

            try! self.fetchedResultsController.performFetchFromSpecifiedStores()
        }
    }
    
    
    // MARK: - Snapshot
    
    public struct Snapshot: RandomAccessCollection, Hashable {

        public subscript(indices: IndexSet) -> [ObjectType] {

            let context = self.context!
            let objectIDs = self.snapshotStruct.itemIdentifiers
            return indices.map { position in

                let objectID = objectIDs[position]
                return context.fetchExisting(objectID)!
            }
        }

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


        // MARK: Equatable

        public static func == (_ lhs: Snapshot, _ rhs: Snapshot) -> Bool {

            return lhs.snapshotReference == rhs.snapshotReference
        }


        // MARK: Hashable

        public func hash(into hasher: inout Hasher) {

            hasher.combine(self.snapshotReference)
        }


        // MARK: Internal

        internal static var empty: Snapshot {

            return .init()
        }

        internal init(snapshotReference: NSDiffableDataSourceSnapshotReference, context: NSManagedObjectContext) {

            self.snapshotReference = snapshotReference
            self.snapshotStruct = snapshotReference as NSDiffableDataSourceSnapshot<NSString, NSManagedObjectID>
            self.context = context
        }


        // MARK: Private
        
        private let snapshotReference: NSDiffableDataSourceSnapshotReference
        private let snapshotStruct: NSDiffableDataSourceSnapshot<NSString, NSManagedObjectID>
        private let context: NSManagedObjectContext?

        private init() {

            self.snapshotReference = .init()
            self.snapshotStruct = self.snapshotReference as NSDiffableDataSourceSnapshot<NSString, NSManagedObjectID>
            self.context = nil
        }
    }
}


// MARK: - LiveList: FetchedDiffableDataSourceSnapshotHandler

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 15.0, *)
extension LiveList: FetchedDiffableDataSourceSnapshotHandler {

    // MARK: FetchedDiffableDataSourceSnapshotHandler

    internal func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangContentWith snapshot: NSDiffableDataSourceSnapshotReference) {

        self.snapshot = .init(snapshotReference: snapshot, context: controller.managedObjectContext)
    }
}


#if canImport(Combine)
import Combine

// MARK: - LiveList: ObservableObject

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 15.0, *)
extension LiveList: ObservableObject {

    // MARK: ObservableObject

    public var objectWillChange: ObservableObjectPublisher {

        return self.rawObjectWillChange! as! ObservableObjectPublisher
    }
}

#endif

#endif
