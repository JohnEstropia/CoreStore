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

#if canImport(Combine)
import Combine

#endif

#if canImport(SwiftUI)
import SwiftUI

#endif


// MARK: - LiveList

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 15.0, *)
public final class LiveList<D: DynamicObject> {
    
    // MARK: Public

    public fileprivate(set) var snapshot: ListSnapshot<ObjectType> = .init() {

        willSet {
            
            #if canImport(Combine)
            
            let oldValue = self.snapshot
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
    
    
    // MARK: LiveResult
    
    public typealias ObjectType = D
    
    public typealias SnapshotType = ListSnapshot<D>


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
//                try!internal self.fetchedResultsController.performFetchFromSpecifiedStores()
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

// MARK: - LiveList: LiveResult

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 15.0, *)
extension LiveList: LiveResult {

    // MARK: ObservableObject

    public var objectWillChange: ObservableObjectPublisher {

        return self.rawObjectWillChange! as! ObservableObjectPublisher
    }
}

#endif

#endif
