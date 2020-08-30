//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import UIKit


// MARK: - Classic.ColorsDemo

extension Classic.ColorsDemo {
    
    // MARK: - Classic.ColorsDemo.ListViewController
    
    final class ListViewController: UITableViewController, ListSectionObserver {
        
        /**
         ⭐️ Sample 1: Once the views are created, we can start observing `ListMonitor` updates. We typically call this at the end of `viewDidLoad`. Note that the `addObserver`'s closure argument will only be called on the succeeding updates, so to immediately display the current values, we need to call `tableView.reloadData()` once.
         */
        private func startObservingList() {
            
            self.listMonitor.addObserver(self)
            self.tableView.reloadData()
        }
        
        /**
         ⭐️ Sample 2: We can end monitoring updates anytime. `removeObserver()` was called here for illustration purposes only. `ListMonitor`s safely remove deallocated observers automatically.
         */
        deinit {
            
            self.listMonitor.removeObserver(self)
        }
        
        
        /**
         ⭐️ Sample 3: `ListSectionObserver` (and inherently, `ListObjectObserver` and `ListObserver`) conformance
         */
        
        // MARK: ListObserver
        
        typealias ListEntityType = Classic.ColorsDemo.Palette
        
        func listMonitorWillChange(_ monitor: ListMonitor<Classic.ColorsDemo.Palette>) {
            
            self.tableView.beginUpdates()
        }
        
        func listMonitorDidChange(_ monitor: ListMonitor<Classic.ColorsDemo.Palette>) {
            
            self.tableView.endUpdates()
        }
        
        func listMonitorDidRefetch(_ monitor: ListMonitor<Classic.ColorsDemo.Palette>) {
            
            self.tableView.reloadData()
        }
        
        
        // MARK: ListObjectObserver
        
        func listMonitor(_ monitor: ListMonitor<ListEntityType>, didInsertObject object: ListEntityType, toIndexPath indexPath: IndexPath) {
            
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
        
        func listMonitor(_ monitor: ListMonitor<ListEntityType>, didDeleteObject object: ListEntityType, fromIndexPath indexPath: IndexPath) {
            
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        func listMonitor(_ monitor: ListMonitor<ListEntityType>, didUpdateObject object: ListEntityType, atIndexPath indexPath: IndexPath) {
            
            if case let cell as Classic.ColorsDemo.ItemCell = self.tableView.cellForRow(at: indexPath) {

                cell.setPalette(object)
            }
        }
        
        func listMonitor(_ monitor: ListMonitor<ListEntityType>, didMoveObject object: ListEntityType, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
            
            self.tableView.deleteRows(at: [fromIndexPath], with: .automatic)
            self.tableView.insertRows(at: [toIndexPath], with: .automatic)
        }
        
        
        // MARK: ListSectionObserver
        
        func listMonitor(_ monitor: ListMonitor<ListEntityType>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
            
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        }
        
        func listMonitor(_ monitor: ListMonitor<ListEntityType>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
            
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        }
        
        
        // MARK: UITableViewDataSource
        
        override func numberOfSections(in tableView: UITableView) -> Int {
            
            return self.listMonitor.numberOfSections()
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return self.listMonitor.numberOfObjects(in: section)
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Classic.ColorsDemo.ItemCell.reuseIdentifier,
                for: indexPath
            ) as! Classic.ColorsDemo.ItemCell
            cell.setPalette(self.listMonitor[indexPath])
            return cell
        }

        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            
            return self.listMonitor.sectionInfo(at: section).name
        }
        
        
        // MARK: UITableViewDelegate

        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

            switch editingStyle {

            case .delete:
                let object = self.listMonitor[indexPath]
                Classic.ColorsDemo.dataStack.perform(
                    asynchronous: { (transaction) in

                        transaction.delete(object)
                    },
                    completion: { _ in }
                )

            default:
                break
            }
        }
        
        
        // MARK: Internal
        
        init(
            listMonitor: ListMonitor<Classic.ColorsDemo.Palette>,
            onPaletteTapped: @escaping (Classic.ColorsDemo.Palette) -> Void
        ) {
            
            self.listMonitor = listMonitor
            self.onPaletteTapped = onPaletteTapped
            
            super.init(style: .plain)
        }

        
        // MARK: UIViewController

        override func viewDidLoad() {
            
            super.viewDidLoad()
            
            self.tableView.register(
                Classic.ColorsDemo.ItemCell.self,
                forCellReuseIdentifier: Classic.ColorsDemo.ItemCell.reuseIdentifier
            )

            self.startObservingList()
        }
        
        
        // MARK: UITableViewDelegate
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            self.onPaletteTapped(
                self.listMonitor[indexPath]
            )
        }
        
        
        // MARK: Private
        
        private let listMonitor: ListMonitor<Classic.ColorsDemo.Palette>
        private let onPaletteTapped: (Classic.ColorsDemo.Palette) -> Void
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            
            fatalError()
        }
    }
}
