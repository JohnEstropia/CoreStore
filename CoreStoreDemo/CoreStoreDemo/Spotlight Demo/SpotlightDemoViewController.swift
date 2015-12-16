//
//  SpotlightDemoViewController.swift
//  CoreStoreDemo
//
//  Created by John Estropia on 2015/12/16.
//  Copyright © 2015年 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices


// MARK: - SpotlightDemoViewController

class SpotlightDemoViewController: UITableViewController {

    private var dataSource = [(String, String)]()
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataSource.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SpotlightItemCell")!
        let item = self.dataSource[indexPath.row]
        cell.textLabel?.text = item.0
        cell.detailTextLabel?.text = item.1
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard case .Delete = editingStyle else {
            
            return
        }
        
        let identifier = self.dataSource[indexPath.row].0
        if #available(iOS 9.0, *) {
            
            CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithIdentifiers(
                [identifier],
                completionHandler: { error in
                
                    // ...
                }
            )
        }
        
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        self.dataSource.removeAtIndex(indexPath.row)
        tableView.endUpdates()
    }
    
    // MARK: Private
    
    @IBAction private dynamic func addBarButtonTapped(sender: UIBarButtonItem) {
        
        let items = [
            ("John", "iOS team"),
            ("Bob", "Android team"),
            ("Joe", "Infra team"),
            ("Ryan", "Director"),
            ("Jake", "Design team"),
            ("Mark", "Testing team")
        ]
        guard let nextItem = items.filter({ !self.dataSource.map({ $0.0 }).contains($0.0) }).first else {
            
            return
        }
        
        if #available(iOS 9.0, *) {
            
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeJSON as String)
            attributeSet.title = nextItem.0
            attributeSet.contentDescription = nextItem.1
            
            let item = CSSearchableItem(
                uniqueIdentifier: nextItem.0,
                domainIdentifier: "jp.eureka.sample",
                attributeSet: attributeSet
            )
            CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(
                [item],
                completionHandler: { (error) -> Void in
                    
                    //...
                }
            )
        }
        
        let tableView = self.tableView
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.dataSource.count, inSection: 0)], withRowAnimation: .Automatic)
        self.dataSource.append(nextItem)
        tableView.endUpdates()
    }
}
