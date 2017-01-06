//
//  ListObserverDemoViewController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/05/02.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreStore


private struct Static {
    
    enum Filter: String {
        
        case all = "All Colors"
        case light = "Light Colors"
        case dark = "Dark Colors"
        
        func next() -> Filter {
            
            switch self {
                
            case .all: return .light
            case .light: return .dark
            case .dark: return .all
            }
        }
        
        func whereClause() -> Where {
            
            switch self {
                
            case .all: return Where(true)
            case .light: return Where("%K >= %@", #keyPath(Palette.brightness), 0.9)
            case .dark: return Where("%K <= %@", #keyPath(Palette.brightness), 0.4)
            }
        }
    }
    
    static var filter = Filter.all {
        
        didSet {
            
            self.palettes.refetch(self.filter.whereClause())
        }
    }
    
    static let palettes: ListMonitor<Palette> = {
        
        try! CoreStore.addStorageAndWait(
            SQLiteStore(
                fileName: "ColorsDemo.sqlite",
                configuration: "ObservingDemo",
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        )
        
        return CoreStore.monitorSectionedList(
            From<Palette>(),
            SectionBy(#keyPath(Palette.colorName)),
            OrderBy(.ascending(#keyPath(Palette.hue)))
        )
    }()
}


// MARK: - ListObserverDemoViewController

class ListObserverDemoViewController: UITableViewController, ListSectionObserver {
    
    // MARK: NSObject
    
    deinit {
        
        Static.palettes.removeObserver(self)
    }
    
    
    // MARK: UIViewController

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let navigationItem = self.navigationItem
        navigationItem.leftBarButtonItems = [
            self.editButtonItem,
            UIBarButtonItem(
                barButtonSystemItem: .trash,
                target: self,
                action: #selector(self.resetBarButtonItemTouched(_:))
            )
        ]
        
        let filterBarButton = UIBarButtonItem(
            title: Static.filter.rawValue,
            style: .plain,
            target: self,
            action: #selector(self.filterBarButtonItemTouched(_:))
        )
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(self.addBarButtonItemTouched(_:))
            ),
            filterBarButton
        ]
        self.filterBarButton = filterBarButton
        
        Static.palettes.addObserver(self)
        
        self.setTable(enabled: !Static.palettes.isPendingRefetch)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier, segue.destination, sender) {
            
        case ("ObjectObserverDemoViewController"?, let destinationViewController as ObjectObserverDemoViewController, let palette as Palette):
            destinationViewController.palette = palette
            
        default:
            break
        }
    }
    
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return Static.palettes.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Static.palettes.numberOfObjectsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaletteTableViewCell") as! PaletteTableViewCell
        
        let palette = Static.palettes[indexPath]
        cell.colorView?.backgroundColor = palette.color
        cell.label?.text = palette.colorText
        
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.performSegue(
            withIdentifier: "ObjectObserverDemoViewController",
            sender: Static.palettes[indexPath]
        )
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
            
        case .delete:
            let palette = Static.palettes[indexPath]
            CoreStore.beginAsynchronous{ (transaction) -> Void in
                
                transaction.delete(palette)
                transaction.commit { (result) -> Void in }
            }
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return Static.palettes.sectionInfoAtIndex(section).name
    }
    
    
    // MARK: ListObserver
    
    func listMonitorWillChange(_ monitor: ListMonitor<Palette>) {
        
        self.tableView.beginUpdates()
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<Palette>) {
        
        self.tableView.endUpdates()
    }
    
    func listMonitorWillRefetch(_ monitor: ListMonitor<Palette>) {
        
        self.setTable(enabled: false)
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<Palette>) {
        
        self.filterBarButton?.title = Static.filter.rawValue
        self.tableView.reloadData()
        self.setTable(enabled: true)
    }
    
    
    // MARK: ListObjectObserver
    
    func listMonitor(_ monitor: ListMonitor<Palette>, didInsertObject object: Palette, toIndexPath indexPath: IndexPath) {
        
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func listMonitor(_ monitor: ListMonitor<Palette>, didDeleteObject object: Palette, fromIndexPath indexPath: IndexPath) {
        
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func listMonitor(_ monitor: ListMonitor<Palette>, didUpdateObject object: Palette, atIndexPath indexPath: IndexPath) {
        
        if let cell = self.tableView.cellForRow(at: indexPath) as? PaletteTableViewCell {
            
            let palette = Static.palettes[indexPath]
            cell.colorView?.backgroundColor = palette.color
            cell.label?.text = palette.colorText
        }
    }
    
    func listMonitor(_ monitor: ListMonitor<Palette>, didMoveObject object: Palette, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        
        self.tableView.deleteRows(at: [fromIndexPath], with: .automatic)
        self.tableView.insertRows(at: [toIndexPath], with: .automatic)
    }
    
    
    // MARK: ListSectionObserver
    
    func listMonitor(_ monitor: ListMonitor<Palette>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
    }
    
    
    func listMonitor(_ monitor: ListMonitor<Palette>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        
        self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
    }
    
    
    // MARK: Private
    
    private var filterBarButton: UIBarButtonItem?
    
    @IBAction private dynamic func resetBarButtonItemTouched(_ sender: AnyObject?) {
        
        CoreStore.beginAsynchronous { (transaction) -> Void in
            
            transaction.deleteAll(From<Palette>())
            transaction.commit()
        }
    }
    
    @IBAction private dynamic func filterBarButtonItemTouched(_ sender: AnyObject?) {
        
        Static.filter = Static.filter.next()
    }
    
    @IBAction private dynamic func addBarButtonItemTouched(_ sender: AnyObject?) {
        
        CoreStore.beginAsynchronous { (transaction) -> Void in
            
            let palette = transaction.create(Into<Palette>())
            palette.setInitialValues()
            
            transaction.commit()
        }
    }
    
    private func setTable(enabled: Bool) {
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .beginFromCurrentState,
            animations: { () -> Void in
                
                if let tableView = self.tableView {
                    
                    tableView.alpha = enabled ? 1.0 : 0.5
                    tableView.isUserInteractionEnabled = enabled
                }
            },
            completion: nil
        )
    }
}

