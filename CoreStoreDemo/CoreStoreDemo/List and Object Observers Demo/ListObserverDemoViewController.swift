//
//  ListObserverDemoViewController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/05/02.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreStore


struct ColorsDemo {
    
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
            case .light: return Palette.where({ $0.brightness >= 0.9 })
            case .dark: return Palette.where({ $0.brightness <= 0.4 })
            }
        }
    }
    
    static var filter = Filter.all {
        
        didSet {
            
            self.palettes.refetch(
                self.filter.whereClause(),
                Palette.orderBy(ascending: { $0.hue })
            )
        }
    }
    
    static let stack: DataStack = {
     
        return DataStack(
            CoreStoreSchema(
                modelVersion: "ColorsDemo",
                entities: [
                    Entity<Palette>("Palette"),
                ],
                versionLock: [
                    "Palette": [0x8c25aa53c7c90a28, 0xa243a34d25f1a3a7, 0x56565b6935b6055a, 0x4f988bb257bf274f]
                ]
            )
        )
    }()
    
    static let palettes: ListMonitor<Palette> = {
        
        try! ColorsDemo.stack.addStorageAndWait(
            SQLiteStore(
                fileName: "ColorsDemo.sqlite",
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        )
        return ColorsDemo.stack.monitorSectionedList(
            From<Palette>(),
            SectionBy(Palette.keyPath({ $0.colorName })),
            Palette.orderBy(ascending: { $0.hue })
        )
    }()
}


// MARK: - ListObserverDemoViewController

class ListObserverDemoViewController: UITableViewController, ListSectionObserver {
    
    // MARK: NSObject
    
    deinit {
        
        ColorsDemo.palettes.removeObserver(self)
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
            title: ColorsDemo.filter.rawValue,
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
        
        ColorsDemo.palettes.addObserver(self)
        
        self.setTable(enabled: !ColorsDemo.palettes.isPendingRefetch)
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
        
        return ColorsDemo.palettes.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ColorsDemo.palettes.numberOfObjectsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaletteTableViewCell") as! PaletteTableViewCell
        
        let palette = ColorsDemo.palettes[indexPath]
        cell.colorView?.backgroundColor = palette.color
        cell.label?.text = palette.colorText
        
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.performSegue(
            withIdentifier: "ObjectObserverDemoViewController",
            sender: ColorsDemo.palettes[indexPath]
        )
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
            
        case .delete:
            let palette = ColorsDemo.palettes[indexPath]
            ColorsDemo.stack.perform(
                asynchronous: { (transaction) in
                    
                    transaction.delete(palette)
                },
                completion: { _ in }
            )
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return ColorsDemo.palettes.sectionInfoAtIndex(section).name
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
        
        self.filterBarButton?.title = ColorsDemo.filter.rawValue
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
            
            let palette = ColorsDemo.palettes[indexPath]
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
        
        ColorsDemo.stack.perform(
            asynchronous: { (transaction) in
                
                transaction.deleteAll(From<Palette>())
            },
            completion: { _ in }
        )
    }
    
    @IBAction private dynamic func filterBarButtonItemTouched(_ sender: AnyObject?) {
        
        ColorsDemo.filter = ColorsDemo.filter.next()
    }
    
    @IBAction private dynamic func addBarButtonItemTouched(_ sender: AnyObject?) {
        
        ColorsDemo.stack.perform(
            asynchronous: { (transaction) in
                
                let palette = transaction.create(Into<Palette>())
                palette.setInitialValues(in: transaction)
            },
            completion: { _ in }
        )
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

