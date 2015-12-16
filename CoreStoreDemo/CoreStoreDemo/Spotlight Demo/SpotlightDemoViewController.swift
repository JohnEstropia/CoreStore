//
//  SpotlightDemoViewController.swift
//  CoreStoreDemo
//
//  Created by John Estropia on 2015/12/16.
//  Copyright © 2015年 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreStore
import CoreSpotlight
import MobileCoreServices


private enum Static {
    
    static let palettes: ListMonitor<Palette> = {
        
        try! CoreStore.addSQLiteStoreAndWait(
            fileName: "SpotlightDemo.sqlite",
            configuration: "SpotlightDemo",
            resetStoreOnModelMismatch: true
        )
        
        return CoreStore.monitorSectionedList(
            From(Palette),
            SectionBy("colorName"),
            OrderBy(.Ascending("hue"))
        )
    }()
}


// MARK: - SpotlightDemoViewController

class SpotlightDemoViewController: UITableViewController, ListSectionObserver {
    
    // MARK: NSObject
    
    deinit {
        
        Static.palettes.removeObserver(self)
    }
    
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let navigationItem = self.navigationItem
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Trash,
            target: self,
            action: "resetBarButtonItemTouched:"
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Add,
            target: self,
            action: "addBarButtonItemTouched:"
        )
        
        Static.palettes.addObserver(self)
    }
    
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return Static.palettes.numberOfSections()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Static.palettes.numberOfObjectsInSection(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PaletteTableViewCell") as! PaletteTableViewCell
        
        let palette = Static.palettes[indexPath]
        cell.colorView?.backgroundColor = palette.color
        cell.label?.text = palette.colorText
        
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
            
        case .Delete:
            let palette = Static.palettes[indexPath]
            CoreStore.beginAsynchronous{ (transaction) -> Void in
                
                transaction.delete(palette)
                transaction.commit { (result) -> Void in }
            }
            
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return Static.palettes.sectionInfoAtIndex(section).name
    }
    
    
    // MARK: ListObserver
    
    func listMonitorWillChange(monitor: ListMonitor<Palette>) {
        
        self.tableView.beginUpdates()
    }
    
    func listMonitorDidChange(monitor: ListMonitor<Palette>) {
        
        self.tableView.endUpdates()
    }
    
    
    // MARK: ListObjectObserver
    
    func listMonitor(monitor: ListMonitor<Palette>, didInsertObject object: Palette, toIndexPath indexPath: NSIndexPath) {
        
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<Palette>, didDeleteObject object: Palette, fromIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<Palette>, didUpdateObject object: Palette, atIndexPath indexPath: NSIndexPath) {
        
        if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? PaletteTableViewCell {
            
            let palette = Static.palettes[indexPath]
            cell.colorView?.backgroundColor = palette.color
            cell.label?.text = palette.colorText
        }
    }
    
    func listMonitor(monitor: ListMonitor<Palette>, didMoveObject object: Palette, fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([fromIndexPath], withRowAnimation: .Automatic)
        self.tableView.insertRowsAtIndexPaths([toIndexPath], withRowAnimation: .Automatic)
    }
    
    
    // MARK: ListSectionObserver
    
    func listMonitor(monitor: ListMonitor<Palette>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<Palette>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        
        self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
    }
    
    
    // MARK: Private
    
    @IBAction private dynamic func resetBarButtonItemTouched(sender: AnyObject?) {
        
        CoreStore.beginAsynchronous { (transaction) -> Void in
            
            transaction.deleteAll(From(Palette))
            transaction.commit()
        }
    }
    
    @IBAction private dynamic func addBarButtonItemTouched(sender: AnyObject?) {
        
        CoreStore.beginAsynchronous { (transaction) -> Void in
            
            let palette = transaction.create(Into(Palette))
            palette.setInitialValues()
            
            transaction.commit()
        }
    }

//    private var dataSource = [(String, String)]()
//    
//    // MARK: UITableViewDataSource
//    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        
//        return 1
//    }
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//        return self.dataSource.count
//    }
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        let cell = tableView.dequeueReusableCellWithIdentifier("SpotlightItemCell")!
//        let item = self.dataSource[indexPath.row]
//        cell.textLabel?.text = item.0
//        cell.detailTextLabel?.text = item.1
//        return cell
//    }
//    
//    // MARK: UITableViewDelegate
//    
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        
//        guard case .Delete = editingStyle else {
//            
//            return
//        }
//        
//        let identifier = self.dataSource[indexPath.row].0
//        if #available(iOS 9.0, *) {
//            
//            CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithIdentifiers(
//                [identifier],
//                completionHandler: { error in
//                
//                    // ...
//                }
//            )
//        }
//        
//        tableView.beginUpdates()
//        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//        self.dataSource.removeAtIndex(indexPath.row)
//        tableView.endUpdates()
//    }
//    
//    // MARK: Private
//    
//    @IBAction private dynamic func addBarButtonTapped(sender: UIBarButtonItem) {
//        
//        let items = [
//            ("John", "iOS team"),
//            ("Bob", "Android team"),
//            ("Joe", "Infra team"),
//            ("Ryan", "Director"),
//            ("Jake", "Design team"),
//            ("Mark", "Testing team")
//        ]
//        guard let nextItem = items.filter({ !self.dataSource.map({ $0.0 }).contains($0.0) }).first else {
//            
//            return
//        }
//        
//        if #available(iOS 9.0, *) {
//            
//            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeJSON as String)
//            attributeSet.title = nextItem.0
//            attributeSet.contentDescription = nextItem.1
//            
//            let item = CSSearchableItem(
//                uniqueIdentifier: nextItem.0,
//                domainIdentifier: "jp.eureka.sample",
//                attributeSet: attributeSet
//            )
//            CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(
//                [item],
//                completionHandler: { (error) -> Void in
//                    
//                    //...
//                }
//            )
//        }
//        
//        let tableView = self.tableView
//        tableView.beginUpdates()
//        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.dataSource.count, inSection: 0)], withRowAnimation: .Automatic)
//        self.dataSource.append(nextItem)
//        tableView.endUpdates()
//    }
}
