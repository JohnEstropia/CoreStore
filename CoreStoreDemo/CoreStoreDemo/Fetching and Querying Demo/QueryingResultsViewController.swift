//
//  QueryingResultsViewController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/06/17.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import UIKit

class QueryingResultsViewController: UITableViewController {
    
    // MARK: Public
    
    func setValue(value: AnyObject?, title: String) {
        
        switch value {
            
        case (let array as [AnyObject])?:
            self.values = array.map { (item: AnyObject) -> (title: String, detail: String) in
                (
                    title: item.description,
                    detail: String(reflecting: item.dynamicType)
                )
            }
            
        case let item?:
            self.values = [
                (
                    title: item.description,
                    detail: String(reflecting: item.dynamicType)
                )
            ]
            
        default:
            self.values = []
        }
        
        self.sectionTitle = title
        
        self.tableView?.reloadData()
    }
    
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.values.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
        
        let value = self.values[indexPath.row]
        
        cell.textLabel?.text = value.title
        cell.detailTextLabel?.text = value.detail
        
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.sectionTitle
    }
    
    
    // MARK: Private
    
    var values: [(title: String, detail: String)] = []
    var sectionTitle: String?
}
