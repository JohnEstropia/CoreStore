//
//  FetchingAndQueryingDemoViewController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/06/12.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreStore


private struct Static {
    
    static let timeZonesStack: DataStack = {
        
        let dataStack = DataStack()
        try! dataStack.addStorageAndWait(
            SQLiteStore(
                fileName: "TimeZoneDemo.sqlite",
                configuration: "FetchingAndQueryingDemo",
                localStorageOptions: .RecreateStoreOnModelMismatch
            )
        )
    
        dataStack.beginSynchronous { (transaction) -> Void in
            
            transaction.deleteAll(From(TimeZone))
            
            for name in NSTimeZone.knownTimeZoneNames() {
                
                let rawTimeZone = NSTimeZone(name: name)!
                let cachedTimeZone = transaction.create(Into(TimeZone))
                
                cachedTimeZone.name = rawTimeZone.name
                cachedTimeZone.abbreviation = rawTimeZone.abbreviation ?? ""
                cachedTimeZone.secondsFromGMT = Int32(rawTimeZone.secondsFromGMT)
                cachedTimeZone.hasDaylightSavingTime = rawTimeZone.daylightSavingTime
                cachedTimeZone.daylightSavingTimeOffset = rawTimeZone.daylightSavingTimeOffset
            }
            
            transaction.commitAndWait()
        }
        
        return dataStack
    }()
}


// MARK: - FetchingAndQueryingDemoViewController

class FetchingAndQueryingDemoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: UIViewController
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if self.didAppearOnce {
            
            return
        }
        
        self.didAppearOnce = true
        
        let alert = UIAlertController(
            title: "Fetch and Query Demo",
            message: "This demo shows how to execute fetches and queries.\n\nEach menu item executes and displays a preconfigured fetch/query.",
            preferredStyle: .Alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        super.prepareForSegue(segue, sender: sender)
        
        if let indexPath = sender as? NSIndexPath {
            
            switch segue.destinationViewController {
                
            case let controller as FetchingResultsViewController:
                let item = self.fetchingItems[indexPath.row]
                controller.setTimeZones(item.fetch(), title: item.title)
                
            case let controller as QueryingResultsViewController:
                let item = self.queryingItems[indexPath.row]
                controller.setValue(item.query(), title: item.title)
                
            default:
                break
            }
        }
    }
    
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch self.segmentedControl?.selectedSegmentIndex {
            
        case Section.Fetching.rawValue?:
            return self.fetchingItems.count
            
        case Section.Querying.rawValue?:
            return self.queryingItems.count
            
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell")!
        
        switch self.segmentedControl?.selectedSegmentIndex {
            
        case Section.Fetching.rawValue?:
            cell.textLabel?.text = self.fetchingItems[indexPath.row].title
            
        case Section.Querying.rawValue?:
            cell.textLabel?.text = self.queryingItems[indexPath.row].title
            
        default:
            cell.textLabel?.text = nil
        }
        
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch self.segmentedControl?.selectedSegmentIndex {
            
        case Section.Fetching.rawValue?:
            self.performSegueWithIdentifier("FetchingResultsViewController", sender: indexPath)
            
        case Section.Querying.rawValue?:
            self.performSegueWithIdentifier("QueryingResultsViewController", sender: indexPath)
            
        default:
            break
        }
    }
    
    
    // MARK: Private
    
    private enum Section: Int {
        
        case Fetching
        case Querying
    }
    
    private let fetchingItems = [
        (
            title: "All Time Zones",
            fetch: { () -> [TimeZone] in
                
                return Static.timeZonesStack.fetchAll(
                    From(TimeZone),
                    OrderBy(.Ascending("name"))
                )!
            }
        ),
        (
            title: "Time Zones in Asia",
            fetch: { () -> [TimeZone] in
                
                return Static.timeZonesStack.fetchAll(
                    From(TimeZone),
                    Where("%K BEGINSWITH[c] %@", "name", "Asia"),
                    OrderBy(.Ascending("secondsFromGMT"))
                )!
            }
        ),
        (
            title: "Time Zones in America and Europe",
            fetch: { () -> [TimeZone] in
                
                return Static.timeZonesStack.fetchAll(
                    From(TimeZone),
                    Where("%K BEGINSWITH[c] %@", "name", "America")
                        || Where("%K BEGINSWITH[c] %@", "name", "Europe"),
                    OrderBy(.Ascending("secondsFromGMT"))
                )!
            }
        ),
        (
            title: "All Time Zones Except America",
            fetch: { () -> [TimeZone] in
                
                return Static.timeZonesStack.fetchAll(
                    From(TimeZone),
                    !Where("%K BEGINSWITH[c] %@", "name", "America"),
                    OrderBy(.Ascending("secondsFromGMT"))
                    )!
            }
        ),
        (
            title: "Time Zones with Summer Time",
            fetch: { () -> [TimeZone] in
                
                return Static.timeZonesStack.fetchAll(
                    From(TimeZone),
                    Where("hasDaylightSavingTime", isEqualTo: true),
                    OrderBy(.Ascending("name"))
                )!
            }
        )
    ]
    
    private let queryingItems = [
        (
            title: "Number of Time Zones",
            query: { () -> AnyObject in
                
                return Static.timeZonesStack.queryValue(
                    From(TimeZone),
                    Select<NSNumber>(.Count("name"))
                )!
            }
        ),
        (
            title: "Abbreviation For Tokyo's Time Zone",
            query: { () -> AnyObject in
                
                return Static.timeZonesStack.queryValue(
                    From(TimeZone),
                    Select<String>("abbreviation"),
                    Where("%K ENDSWITH[c] %@", "name", "Tokyo")
                )!
            }
        ),
        (
            title: "All Abbreviations",
            query: { () -> AnyObject in
                
                return Static.timeZonesStack.queryAttributes(
                    From(TimeZone),
                    Select<NSDictionary>("name", "abbreviation"),
                    OrderBy(.Ascending("name"))
                )!
            }
        ),
        (
            title: "Number of Countries per Time Zone",
            query: { () -> AnyObject in
                
                return Static.timeZonesStack.queryAttributes(
                    From(TimeZone),
                    Select<NSDictionary>(.Count("abbreviation"), "abbreviation"),
                    GroupBy("abbreviation"),
                    OrderBy(.Ascending("secondsFromGMT"), .Ascending("name"))
                )!
            }
        ),
        (
            title: "Number of Countries with Summer Time",
            query: { () -> AnyObject in
                
                return Static.timeZonesStack.queryAttributes(
                    From(TimeZone),
                    Select<NSDictionary>(
                        .Count("hasDaylightSavingTime", As: "numberOfCountries"),
                        "hasDaylightSavingTime"
                    ),
                    GroupBy("hasDaylightSavingTime"),
                    OrderBy(.Descending("hasDaylightSavingTime"))
                )!
            }
        )
    ]
    
    var didAppearOnce = false
    
    @IBOutlet dynamic weak var segmentedControl: UISegmentedControl?
    @IBOutlet dynamic weak var tableView: UITableView?
    
    @IBAction dynamic func segmentedControlValueChanged(sender: AnyObject?) {
        
        self.tableView?.reloadData()
    }
}
