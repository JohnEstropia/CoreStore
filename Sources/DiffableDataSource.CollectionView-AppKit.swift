//
//  DiffableDataSource.CollectionView-AppKit.swift
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

#if canImport(AppKit) && os(macOS)

import AppKit
import CoreData


// MARK: - DiffableDataSource

extension DiffableDataSource {

    // MARK: - CollectionView
    
    /**
     The `DiffableDataSource.CollectionView` serves as a `NSCollectionViewDataSource` that handles `ListPublisher` snapshots for a `NSCollectionView`. Subclasses of `DiffableDataSource.CollectionView` may override some `NSCollectionViewDataSource` methods as needed.
     The `DiffableDataSource.CollectionView` instance needs to be held on (retained) for as long as the `NSCollectionView`'s lifecycle.
     ```
     self.dataSource = DiffableDataSource.CollectionView<Person>(
         collectionView: self.collectionView,
         dataStack: CoreStoreDefaults.dataStack,
         itemProvider: { (collectionView, indexPath, person) in
             let item = collectionView.makeItem(withIdentifier: .collectionViewItem, for: indexPath) as! PersonItem
             item.setPerson(person)
             return item
         }
     )
     ```
     The dataSource can then apply changes from a `ListPublisher` as shown:
     ```
     listPublisher.addObserver(self) { [weak self] (listPublisher) in
        self?.dataSource?.apply(
            listPublisher.snapshot,
            animatingDifferences: true
        )
     }
     ```
     `DiffableDataSource.CollectionView` fully handles the reload animations.
     - SeeAlso: CoreStore's DiffableDataSource implementation is based on https://github.com/ra1028/DiffableDataSources     
     */
    open class CollectionView<O: DynamicObject>: NSObject, NSCollectionViewDataSource {

        // MARK: Public
        
        /**
         The object type represented by this dataSource
         */
        public typealias ObjectType = O
        
        /**
         Initializes the `DiffableDataSource.CollectionView`. This instance needs to be held on (retained) for as long as the `NSCollectionView`'s lifecycle.
         ```
         self.dataSource = DiffableDataSource.CollectionView<Person>(
             collectionView: self.collectionView,
             dataStack: CoreStoreDefaults.dataStack,
             itemProvider: { (collectionView, indexPath, person) in
                 let item = collectionView.makeItem(withIdentifier: .collectionViewItem, for: indexPath) as! PersonItem
                 item.setPerson(person)
                 return item
             }
         )
         ```
         - parameter collectionView: the `NSCollectionView` to set the `dataSource` of. This instance is not retained by the `DiffableDataSource.CollectionView`.
         - parameter dataStack: the `DataStack` instance that the dataSource will fetch objects from
         - parameter itemProvider: a closure that configures and returns the `NSCollectionViewItem` for the object
         */
        @nonobjc
        public init(collectionView: NSCollectionView, dataStack: DataStack, itemProvider: @escaping (NSCollectionView, IndexPath, O) -> NSCollectionViewItem?, supplementaryViewProvider: @escaping (NSCollectionView, String, IndexPath) -> NSView? = { _, _, _ in nil }) {

            self.collectionView = collectionView
            self.itemProvider = itemProvider
            self.supplementaryViewProvider = supplementaryViewProvider
            self.dataStack = dataStack
            self.dispatcher = Internals.DiffableDataUIDispatcher<O>(dataStack: dataStack)

            super.init()

            collectionView.dataSource = self
        }
        
        /**
         Reloads the `NSCollectionView` using a `ListSnapshot`. This is typically from the `snapshot` property of a `ListPublisher`:
         ```
         listPublisher.addObserver(self) { [weak self] (listPublisher) in
            self?.dataSource?.apply(
                listPublisher.snapshot,
                animatingDifferences: true
            )
         }
         ```
         
         - parameter snapshot: the `ListSnapshot` used to reload the `UITableView` with. This is typically from the `snapshot` property of a `ListPublisher`.
         - parameter animatingDifferences: if `true`, animations will be applied as configured by the `defaultRowAnimation` value. Defaults to `true`.
         */
        public func apply(_ snapshot: ListSnapshot<O>, animatingDifferences: Bool = true) {

            let diffableSnapshot = snapshot.diffableSnapshot
            self.dispatcher.apply(
                diffableSnapshot as! Internals.DiffableDataSourceSnapshot,
                view: self.collectionView,
                animatingDifferences: animatingDifferences,
                performUpdates: { collectionView, changeset, setSections in

                    collectionView.reload(
                        using: changeset,
                        setData: setSections
                    )
                }
            )
        }
        
        /**
         Returns the object identifier for the item at the specified `IndexPath`, or `nil` if not found
         
         - parameter indexPath: the `IndexPath` to search for
         - returns: the object identifier for the item at the specified `IndexPath`, or `nil` if not found
         */
        @nonobjc
        public func itemID(for indexPath: IndexPath) -> O.ObjectID? {

            return self.dispatcher.itemIdentifier(for: indexPath)
        }
        
        /**
         Returns the `IndexPath` for the item with the specified object identifier, or `nil` if not found
         
         - parameter itemID: the object identifier to search for
         - returns: the `IndexPath` for the item with the specified object identifier, or `nil` if not found
         */
        @nonobjc
        public func indexPath(for itemID: O.ObjectID) -> IndexPath? {

            return self.dispatcher.indexPath(for: itemID)
        }


        // MARK: - NSCollectionViewDataSource

        @objc
        public dynamic func numberOfSections(in collectionView: NSCollectionView) -> Int {

            return self.dispatcher.numberOfSections()
        }

        @objc
        public dynamic func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {

            return self.dispatcher.numberOfItems(inSection: section)
        }

        @objc
        open dynamic func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {

            guard let objectID = self.dispatcher.itemIdentifier(for: indexPath) else {

                Internals.abort("Object at \(Internals.typeName(IndexPath.self)) \(indexPath) already removed from list")
            }
            guard let object = self.dataStack.fetchExisting(objectID) as O? else {

                Internals.abort("Object at \(Internals.typeName(IndexPath.self)) \(indexPath) has been deleted")
            }
            guard let item = self.itemProvider(collectionView, indexPath, object) else {

                Internals.abort("\(Internals.typeName(NSCollectionViewDataSource.self)) returned a `nil` item for \(Internals.typeName(IndexPath.self)) \(indexPath)")
            }
            return item
        }

        @objc
        open dynamic func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {

            guard let view = self.supplementaryViewProvider(collectionView, kind, indexPath) else {

                return NSView()
            }
            return view
        }


        // MARK: Private

        private weak var collectionView: NSCollectionView?

        private let dataStack: DataStack
        private let itemProvider: (NSCollectionView, IndexPath, O) -> NSCollectionViewItem?
        private let supplementaryViewProvider: (NSCollectionView, String, IndexPath) -> NSView?
        private let dispatcher: Internals.DiffableDataUIDispatcher<O>
    }
}


// MARK: - NSCollectionView

extension NSCollectionView {

    // MARK: FilePrivate
    
    // Implementation based on https://github.com/ra1028/DiffableDataSources
    @nonobjc
    fileprivate func reload<C, O>(
        using stagedChangeset: Internals.DiffableDataUIDispatcher<O>.StagedChangeset<C>,
        interrupt: ((Internals.DiffableDataUIDispatcher<O>.Changeset<C>) -> Bool)? = nil,
        setData: (C) -> Void
    ) {

        if case .none = window, let data = stagedChangeset.last?.data {

            setData(data)
            self.reloadData()
            return
        }
        for changeset in stagedChangeset {

            if let interrupt = interrupt, interrupt(changeset), let data = stagedChangeset.last?.data {

                setData(data)
                self.reloadData()
                return
            }
            self.animator().performBatchUpdates(
                {
                    setData(changeset.data)

                    if !changeset.sectionDeleted.isEmpty {

                        self.deleteSections(IndexSet(changeset.sectionDeleted))
                    }
                    if !changeset.sectionInserted.isEmpty {

                        self.insertSections(IndexSet(changeset.sectionInserted))
                    }
                    if !changeset.sectionUpdated.isEmpty {

                        self.reloadSections(IndexSet(changeset.sectionUpdated))
                    }
                    for (source, target) in changeset.sectionMoved {

                        self.moveSection(source, toSection: target)
                    }
                    if !changeset.elementDeleted.isEmpty {

                        self.deleteItems(
                            at: Set(changeset.elementDeleted.map { IndexPath(item: $0.element, section: $0.section) })
                        )
                    }
                    if !changeset.elementInserted.isEmpty {

                        self.insertItems(
                            at: Set(changeset.elementInserted.map { IndexPath(item: $0.element, section: $0.section) })
                        )
                    }
                    if !changeset.elementUpdated.isEmpty {

                        self.reloadItems(
                            at: Set(changeset.elementUpdated.map { IndexPath(item: $0.element, section: $0.section) })
                        )
                    }
                    for (source, target) in changeset.elementMoved {

                        self.moveItem(
                            at: IndexPath(item: source.element, section: source.section),
                            to: IndexPath(item: target.element, section: target.section)
                        )
                    }
                },
                completionHandler: nil
            )
        }
    }
}


#endif
