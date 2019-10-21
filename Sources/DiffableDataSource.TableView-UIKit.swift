//
//  DiffableDataSource.TableView-UIKit.swift
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

#if canImport(UIKit) && (os(iOS) || os(tvOS))

import UIKit
import CoreData


// MARK: - DiffableDataSource

extension DiffableDataSource {

    // MARK: - TableView

    /**
     The `DiffableDataSource.TableView` serves as a `UITableViewDataSource` that handles `ListPublisher` snapshots for a `UITableView`. Subclasses of `DiffableDataSource.TableView` may override some `UITableViewDataSource` methods as needed.
     The `DiffableDataSource.TableView` instance needs to be held on (retained) for as long as the `UITableView`'s lifecycle.
     ```
     self.dataSource = DiffableDataSource.TableView<Person>(
         tableView: self.tableView,
         dataStack: CoreStoreDefaults.dataStack,
         cellProvider: { (tableView, indexPath, person) in
             let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell") as! PersonCell
             cell.setPerson(person)
             return cell
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
     `DiffableDataSource.TableView` fully handles the reload animations. To turn change the default animation, set the `defaultRowAnimation`.
     - SeeAlso: CoreStore's DiffableDataSource implementation is based on https://github.com/ra1028/DiffableDataSources
     */
    open class TableView<O: DynamicObject>: NSObject, UITableViewDataSource {
        
        // MARK: Open

        /**
         The animation style for row changes
         */
        @nonobjc
        open var defaultRowAnimation: UITableView.RowAnimation = .automatic
        

        // MARK: Public

        /**
         The object type represented by this dataSource
         */
        public typealias ObjectType = O

        /**
         Initializes the `DiffableDataSource.TableView`. This instance needs to be held on (retained) for as long as the `UITableView`'s lifecycle.
         ```
         self.dataSource = DiffableDataSource.TableView<Person>(
             tableView: self.tableView,
             dataStack: CoreStoreDefaults.dataStack,
             cellProvider: { (tableView, indexPath, person) in
                 let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell") as! PersonCell
                 cell.setPerson(person)
                 return cell
             }
         )
         ```
         - parameter tableView: the `UITableView` to set the `dataSource` of. This instance is not retained by the `DiffableDataSource.TableView`.
         - parameter dataStack: the `DataStack` instance that the dataSource will fetch objects from
         - parameter cellProvider: a closure that configures and returns the `UITableViewCell` for the object
         */
        @nonobjc
        public init(tableView: UITableView, dataStack: DataStack, cellProvider: @escaping (UITableView, IndexPath, O) -> UITableViewCell?) {

            self.tableView = tableView
            self.cellProvider = cellProvider
            self.dataStack = dataStack
            self.dispatcher = Internals.DiffableDataUIDispatcher<O>(dataStack: dataStack)

            super.init()

            tableView.dataSource = self
        }
        
        /**
         Reloads the `UITableView` using a `ListSnapshot`. This is typically from the `snapshot` property of a `ListPublisher`:
         ```
         listPublisher.addObserver(self) { [weak self] (listPublisher) in
            self?.dataSource?.apply(
                listPublisher.snapshot,
                animatingDifferences: true
            )
         }
         ```
         If the `defaultRowAnimation` is configured to, animations are also applied accordingly.
         
         - parameter snapshot: the `ListSnapshot` used to reload the `UITableView` with. This is typically from the `snapshot` property of a `ListPublisher`.
         - parameter animatingDifferences: if `true`, animations will be applied as configured by the `defaultRowAnimation` value. Defaults to `true`.
         */
        @nonobjc
        public func apply(_ snapshot: ListSnapshot<O>, animatingDifferences: Bool = true) {

            let diffableSnapshot = snapshot.diffableSnapshot
//            if #available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *) {
//
//                self.modernDataSource.apply(
//                    diffableSnapshot as! NSDiffableDataSourceSnapshot<String, NSManagedObjectID>,
//                    animatingDifferences: animatingDifferences,
//                    completion: nil
//                )
//            }
//            else {
                
                self.dispatcher.apply(
                    diffableSnapshot as! Internals.DiffableDataSourceSnapshot,
                    view: self.tableView,
                    animatingDifferences: animatingDifferences,
                    performUpdates: { tableView, changeset, setSections in
                        
                        tableView.reload(
                            using: changeset,
                            with: self.defaultRowAnimation,
                            setData: setSections
                        )
                    }
                )
//            }
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
        
        
        // MARK: - UITableViewDataSource

        @objc
        public dynamic func numberOfSections(in tableView: UITableView) -> Int {
            
            return self.dispatcher.numberOfSections()
        }

        @objc
        public dynamic func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return self.dispatcher.numberOfItems(inSection: section)
        }

        @objc
        open dynamic func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            
            return self.dispatcher.sectionIdentifier(inSection: section)
        }

        @objc
        open dynamic func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
            
            return nil
        }
        
        @objc
        open dynamic func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            guard let objectID = self.dispatcher.itemIdentifier(for: indexPath) else {
                
                Internals.abort("Object at \(Internals.typeName(IndexPath.self)) \(indexPath) already removed from list")
            }
            guard let object = self.dataStack.fetchExisting(objectID) as O? else {
                
                Internals.abort("Object at \(Internals.typeName(IndexPath.self)) \(indexPath) has been deleted")
            }
            guard let cell = self.cellProvider(tableView, indexPath, object) else {
                
                Internals.abort("\(Internals.typeName(UITableViewDataSource.self)) returned a `nil` cell for \(Internals.typeName(IndexPath.self)) \(indexPath)")
            }
            return cell
        }

        @objc
        open dynamic func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

            return true
        }

        @objc
        open dynamic func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {

            return .delete
        }

        @objc
        open dynamic func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {}


        // MARK: Private
        
        @nonobjc
        private weak var tableView: UITableView?
        
        @nonobjc
        private let dataStack: DataStack
        
        @nonobjc
        private let cellProvider: (UITableView, IndexPath, O) -> UITableViewCell?
        
        @nonobjc
        private let dispatcher: Internals.DiffableDataUIDispatcher<O>
    }
}


// MARK: - UITableView

extension UITableView {

    // MARK: FilePrivate
    
    // Implementation based on https://github.com/ra1028/DiffableDataSources
    @nonobjc
    fileprivate func reload<C, O>(
        using stagedChangeset: Internals.DiffableDataUIDispatcher<O>.StagedChangeset<C>,
        with animation: @autoclosure () -> RowAnimation,
        interrupt: ((Internals.DiffableDataUIDispatcher<O>.Changeset<C>) -> Bool)? = nil,
        setData: (C) -> Void
    ) {
        
        self.reload(
            using: stagedChangeset,
            deleteSectionsAnimation: animation(),
            insertSectionsAnimation: animation(),
            reloadSectionsAnimation: animation(),
            deleteRowsAnimation: animation(),
            insertRowsAnimation: animation(),
            reloadRowsAnimation: animation(),
            interrupt: interrupt,
            setData: setData
        )
    }
    
    // Implementation based on https://github.com/ra1028/DiffableDataSources
    @nonobjc
    fileprivate func reload<C, O>(
        using stagedChangeset: Internals.DiffableDataUIDispatcher<O>.StagedChangeset<C>,
        deleteSectionsAnimation: @autoclosure () -> RowAnimation,
        insertSectionsAnimation: @autoclosure () -> RowAnimation,
        reloadSectionsAnimation: @autoclosure () -> RowAnimation,
        deleteRowsAnimation: @autoclosure () -> RowAnimation,
        insertRowsAnimation: @autoclosure () -> RowAnimation,
        reloadRowsAnimation: @autoclosure () -> RowAnimation,
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
            self.cs_performBatchUpdates {
                
                setData(changeset.data)

                if !changeset.sectionDeleted.isEmpty {
                    
                    self.deleteSections(IndexSet(changeset.sectionDeleted), with: deleteSectionsAnimation())
                }
                if !changeset.sectionInserted.isEmpty {
                    
                    self.insertSections(IndexSet(changeset.sectionInserted), with: insertSectionsAnimation())
                }
                if !changeset.sectionUpdated.isEmpty {
                    
                    self.reloadSections(IndexSet(changeset.sectionUpdated), with: reloadSectionsAnimation())
                }
                for (source, target) in changeset.sectionMoved {
                    
                    self.moveSection(source, toSection: target)
                }
                if !changeset.elementDeleted.isEmpty {
                    
                    self.deleteRows(at: changeset.elementDeleted.map { IndexPath(row: $0.element, section: $0.section) }, with: deleteRowsAnimation())
                }
                if !changeset.elementInserted.isEmpty {
                    
                    self.insertRows(at: changeset.elementInserted.map { IndexPath(row: $0.element, section: $0.section) }, with: insertRowsAnimation())
                }
                if !changeset.elementUpdated.isEmpty {
                    
                    self.reloadRows(at: changeset.elementUpdated.map { IndexPath(row: $0.element, section: $0.section) }, with: reloadRowsAnimation())
                }
                for (source, target) in changeset.elementMoved {
                    
                    self.moveRow(at: IndexPath(row: source.element, section: source.section), to: IndexPath(row: target.element, section: target.section))
                }
            }
        }
    }

    @nonobjc
    private func cs_performBatchUpdates(_ updates: () -> Void) {
        
        if #available(iOS 11.0, tvOS 11.0, *) {
            
            self.performBatchUpdates(updates)
        }
        else {
            
            self.beginUpdates()
            updates()
            self.endUpdates()
        }
    }
}


#endif
