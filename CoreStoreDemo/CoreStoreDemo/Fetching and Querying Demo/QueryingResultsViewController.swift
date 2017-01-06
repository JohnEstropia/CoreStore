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
    
    func set(value: Any?, title: String) {
        
        switch value {
            
        case (let array as [Any])?:
            self.values = array.map { (item: Any) -> (title: String, detail: String) in
                (
                    title: String(describing: item),
                    detail: String(reflecting: type(of: item))
                )
            }
            
        case let item?:
            self.values = [
                (
                    title: String(describing: item),
                    detail: String(reflecting: type(of: item))
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.values.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        let value = self.values[indexPath.row]
        
        cell.textLabel?.text = value.title
        cell.detailTextLabel?.text = value.detail
        
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.sectionTitle
    }
    
    
    // MARK: Private
    
    var values: [(title: String, detail: String)] = []
    var sectionTitle: String?
}
