//
//  MasterViewController.swift
//  HardcoreDataDemo
//
//  Created by John Rommel Estropia on 2015/05/02.
//  Copyright (c) 2015 John Rommel Estropia. All rights reserved.
//

import UIKit
import HardcoreData


// MARK: - MasterViewController

class MasterViewController: UITableViewController, ManagedObjectListObserver {
    
    // MARK: UIViewController

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addBarButtonItemTouched:")
        
        self.list.addObserver(self)
    }
    
    
    // MARK: UITableViewController

    required init!(coder aDecoder: NSCoder!) {
        
        HardcoreData.defaultStack.addSQLiteStore()
        self.list = HardcoreData.defaultStack.observeObjectList(
            From(Event),
            SortedBy(.Ascending("timeStamp"))
        )
        super.init(coder: aDecoder)
    }
    
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return self.list.numberOfSections()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.list.numberOfItemsInSection(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell") as! UITableViewCell
        cell.textLabel?.text = "\(self.list[indexPath].timeStamp)"
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        
//        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
//    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
            
        case .Delete:
            let event = self.list[indexPath]
            HardcoreData.beginAsynchronous{ (transaction) -> Void in
                
                transaction.delete(transaction.fetch(event)!)
                transaction.commit { (result) -> Void in }
            }
            
        default:
            break
        }
    }
    
//    optional func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
    
    
    // MARK: ManagedObjectListObserver
    
    func managedObjectListWillChange(listController: ManagedObjectListController<Event>) {
        
        self.tableView.beginUpdates()
    }
    
    func managedObjectList(listController: ManagedObjectListController<Event>, didInsertObject object: Event, toIndexPath indexPath: NSIndexPath) {
        
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func managedObjectList(listController: ManagedObjectListController<Event>, didDeleteObject object: Event, fromIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func managedObjectList(listController: ManagedObjectListController<Event>, didUpdateObject object: Event, atIndexPath indexPath: NSIndexPath) {
        
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func managedObjectList(listController: ManagedObjectListController<Event>, didMoveObject object: Event, fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        self.tableView.moveRowAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
    }
    
    func managedObjectListDidChange(listController: ManagedObjectListController<Event>) {
        
        self.tableView.endUpdates()
    }
    
    // MARK: Private
    
    let list: ManagedObjectListController<Event>
    
    @objc dynamic func addBarButtonItemTouched(sender: AnyObject!) {
        
        HardcoreData.beginAsynchronous { (transaction) -> Void in
            
            let event = transaction.create(Event)
            event.timeStamp = NSDate()
            
            transaction.commit { (result) -> Void in }
        }
    }
}

