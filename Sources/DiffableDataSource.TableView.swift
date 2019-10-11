//
//  DiffableDataSource.TableView.swift
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

#if canImport(UIKit)

import UIKit
import CoreData


//// MARK: - DiffableDataSource
//
//extension DiffableDataSource {
//
//    // MARK: - TableView
//
//    public open class TableView<D: DynamicObject>: NSObject, UITableViewDataSource {
//
//        // MARK: Public
//
//        public typealias ObjectType = D
//
//        public var defaultRowAnimation: UITableView.RowAnimation = .automatic
//
//        public init(tableView: UITableView, cellProvider: @escaping (UITableView, IndexPath, ObjectType) -> UITableViewCell?) {
//
//            self.tableView = tableView
//            self.cellProvider = cellProvider
//
//            if #available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *) {
//
//                self.rawDataSource = UITableViewDiffableDataSource<String, D.ObjectID>(
//                    tableView: tableView,
//                    cellProvider: { (tableView, indexPath, managedObjectID) -> UITableViewCell? in
//
//                        cellProvider(
//                    }
//                )
//            }
//            else {
//
//                self.rawDataSource = nil
//            }
//
//            super.init()
//
//            tableView.dataSource = self
//        }
//
//        public func apply(_ snapshot: ListSnapshot<ObjectType>, animatingDifferences: Bool = true) {
//
//            let dataSource = UITableViewDiffableDataSource<String, D>.
//            if #available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *) {
//
//                self.rawDataSource! as! UITableViewDiffableDataSource<String, D>
//
//            }
//            else {
//
//            }
//            core.apply(
//                snapshot,
//                view: tableView,
//                animatingDifferences: animatingDifferences,
//                performUpdates: { tableView, changeset, setSections in
//                    tableView.reload(using: changeset, with: self.defaultRowAnimation, setData: setSections)
//            })
//        }
//
//
//        // MARK: Private
//
//        private weak var tableView: UITableView?
//        private let cellProvider: (UITableView, IndexPath, ObjectType) -> UITableViewCell?
//        private let rawDataSource: Any?
//
//        @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
//        private var diffableDataSource: UITableViewDiffableDataSource<String, D.ObjectID> {
//
//            return self.rawDataSource! as! UITableViewDiffableDataSource<String, D.ObjectID>
//        }
//    }
//}


#endif
