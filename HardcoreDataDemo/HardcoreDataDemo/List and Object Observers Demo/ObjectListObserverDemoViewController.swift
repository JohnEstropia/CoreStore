//
//  ObjectListObserverDemoViewController.swift
//  HardcoreDataDemo
//
//  Created by John Rommel Estropia on 2015/05/02.
//  Copyright (c) 2015 John Rommel Estropia. All rights reserved.
//

import UIKit
import HardcoreData


struct Shared {
    
    static let palettes = HardcoreData.observeSectionedList(
        From(Palette),
        SectionedBy("colorName"),
        SortedBy(.Ascending("hue"))
    )
}


// MARK: - ObjectListObserverDemoViewController

class ObjectListObserverDemoViewController: UITableViewController, ManagedObjectListSectionObserver {
    
    // MARK: NSObject
    
    deinit {
        
        Shared.palettes.removeObserver(self)
    }
    
    
    // MARK: UIViewController

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItems = [
            self.editButtonItem(),
            UIBarButtonItem(
                barButtonSystemItem: .Trash,
                target: self,
                action: "resetBarButtonItemTouched:"
            )
        ]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Add,
            target: self,
            action: "addBarButtonItemTouched:"
        )
        
        Shared.palettes.addObserver(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        super.prepareForSegue(segue, sender: sender)
        
        switch (segue.identifier, segue.destinationViewController, sender) {
            
        case (.Some("ObjectObserverDemoViewController"), let destinationViewController as ObjectObserverDemoViewController, let palette as Palette):
            destinationViewController.palette = palette
            
        default:
            break
        }
    }
    
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return Shared.palettes.numberOfSections()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Shared.palettes.numberOfObjectsInSection(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PaletteTableViewCell") as! PaletteTableViewCell
        
        let palette = Shared.palettes[indexPath]
        cell.colorView?.backgroundColor = palette.color
        cell.label?.text = palette.colorText
        
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.performSegueWithIdentifier(
            "ObjectObserverDemoViewController",
            sender: Shared.palettes[indexPath]
        )
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
            
        case .Delete:
            let palette = Shared.palettes[indexPath]
            HardcoreData.beginAsynchronous{ (transaction) -> Void in
                
                transaction.delete(palette)
                transaction.commit { (result) -> Void in }
            }
            
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return Shared.palettes.sectionInfoAtIndex(section).name
    }
    
    
    // MARK: ManagedObjectListChangeObserver
    
    func managedObjectListWillChange(listController: ManagedObjectListController<Palette>) {
        
        self.tableView.beginUpdates()
    }
    
    func managedObjectListDidChange(listController: ManagedObjectListController<Palette>) {
        
        self.tableView.endUpdates()
    }
    
    
    // MARK: ManagedObjectListObjectObserver
    
    func managedObjectList(listController: ManagedObjectListController<Palette>, didInsertObject object: Palette, toIndexPath indexPath: NSIndexPath) {
        
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func managedObjectList(listController: ManagedObjectListController<Palette>, didDeleteObject object: Palette, fromIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func managedObjectList(listController: ManagedObjectListController<Palette>, didUpdateObject object: Palette, atIndexPath indexPath: NSIndexPath) {
        
        if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? PaletteTableViewCell {
            
            let palette = Shared.palettes[indexPath]
            cell.colorView?.backgroundColor = palette.color
            cell.label?.text = palette.colorText
        }
    }
    
    func managedObjectList(listController: ManagedObjectListController<Palette>, didMoveObject object: Palette, fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([fromIndexPath], withRowAnimation: .Automatic)
        self.tableView.insertRowsAtIndexPaths([toIndexPath], withRowAnimation: .Automatic)
    }
    
    
    // MARK: ManagedObjectListSectionObserver
    
    func managedObjectList(listController: ManagedObjectListController<Palette>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
    }
    
    func managedObjectList(listController: ManagedObjectListController<Palette>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        
        self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
    }
    
    
    // MARK: Private
    
    @IBAction dynamic func resetBarButtonItemTouched(sender: AnyObject?) {
        
        HardcoreData.beginAsynchronous { (transaction) -> Void in
            
            transaction.deleteAll(From(Palette))
            transaction.commit()
        }
    }
    
    @IBAction dynamic func addBarButtonItemTouched(sender: AnyObject?) {
        
        HardcoreData.beginAsynchronous { (transaction) -> Void in
            
            let palette = transaction.create(Palette)
            palette.setInitialValues()
            
            transaction.commit()
        }
    }
}

