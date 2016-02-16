//
//  FetchingResultsViewController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/06/17.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import UIKit

// MARK: - FetchingResultsViewController

class FetchingResultsViewController: UITableViewController {

    // MARK: Public
    
    func setTimeZones(timeZones: [TimeZone]?, title: String) {
        
        self.timeZones += timeZones ?? []
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
        
        return self.timeZones.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
        
        let timeZone = self.timeZones[indexPath.row]
        cell.textLabel?.text = timeZone.name
        cell.detailTextLabel?.text = timeZone.abbreviation
        
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.sectionTitle
    }
    
    
    // MARK: Private
    
    var timeZones = [TimeZone]()
    var sectionTitle: String?
}
