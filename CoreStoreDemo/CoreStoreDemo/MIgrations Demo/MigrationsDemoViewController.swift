//
//  MigrationsDemoViewController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/06/21.
//  Copyright (c) 2015 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreStore


// MARK: - MigrationsDemoViewController

class MigrationsDemoViewController: UITableViewController {
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.selectModelVersion(self.models.first!)
    }
    

    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.models.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
        cell.textLabel?.text = self.models[indexPath.row].version
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Model Versions"
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.selectModelVersion(self.models[indexPath.row])
    }
    
    
    // MARK: Private
    
    private typealias ModelMetadata = (version: String, entityType: AnyClass, migrationChain: MigrationChain)
    
    private let models: [ModelMetadata] = [
        (
            version: "MigrationDemo",
            entityType: OrganismV1.self,
            migrationChain: ["MigrationDemoV3", "MigrationDemoV2", "MigrationDemo"]
        ),
        (
            version: "MigrationDemoV2",
            entityType: OrganismV2.self,
            migrationChain: [
                "MigrationDemo": "MigrationDemoV2",
                "MigrationDemoV3": "MigrationDemoV2"
            ]
        ),
        (
            version: "MigrationDemoV3",
            entityType: OrganismV3.self,
            migrationChain: ["MigrationDemo", "MigrationDemoV2", "MigrationDemoV3"]
        )
    ]
    
    private var dataStack: DataStack?
    private var organism: NSManagedObject?
    
    @IBOutlet private dynamic weak var titleLabel: UILabel?
    @IBOutlet private dynamic weak var organismLabel: UILabel?
    
    @IBAction private dynamic func mutateBarButtonTapped(sender: AnyObject?) {
        
        if let dataStack = self.dataStack, let organism = self.organism {
            
            dataStack.beginSynchronous { (transaction) -> Void in
                
                let organism = transaction.edit(organism)
                (organism as! OrganismProtocol).mutate()
                
                transaction.commit()
            }
            self.updateDisplay()
        }
    }
    
    private func selectModelVersion(model: ModelMetadata) {
        
        if self.organism?.entity.managedObjectClassName == "\(model.entityType)" {
            
            return
        }
        
        self.organism = nil
        self.dataStack = nil
        
        let dataStack = DataStack(
            modelName: "MigrationDemo",
            migrationChain: model.migrationChain
        )
        
        self.setEnabled(false)
        dataStack.addSQLiteStore(
            "MigrationDemo.sqlite",
            completion: { [weak self] (result) -> Void in
                
                guard let strongSelf = self else {
                    
                    return
                }
                
                guard case .Success = result else {
                    
                    strongSelf.setEnabled(true)
                    return
                }
                
                strongSelf.dataStack = dataStack
                if let organism = dataStack.fetchOne(From(model.entityType)) {
                    
                    strongSelf.organism = organism
                }
                else {
                    
                    dataStack.beginSynchronous { (transaction) -> Void in
                        
                        let organism = transaction.create(Into(model.entityType))
                        (organism as! OrganismProtocol).mutate()
                        
                        transaction.commit()
                    }
                    strongSelf.organism = dataStack.fetchOne(From(model.entityType))!
                }
                
                strongSelf.updateDisplay()
                strongSelf.tableView.selectRowAtIndexPath(
                    NSIndexPath(
                        forRow: strongSelf.models.map { $0.version }.indexOf(model.version)!,
                        inSection: 0
                    ),
                    animated: false,
                    scrollPosition: .None
                )
                strongSelf.setEnabled(true)
            }
        )
    }
    
    func setEnabled(enabled: Bool) {
        
        UIView.animateKeyframesWithDuration(
            0.2,
            delay: 0,
            options: .BeginFromCurrentState,
            animations: { () -> Void in
                
                let navigationItem = self.navigationItem
                navigationItem.leftBarButtonItem?.enabled = enabled
                navigationItem.rightBarButtonItem?.enabled = enabled
                navigationItem.backBarButtonItem?.enabled = enabled
                
                if let tableView = self.tableView {
                    
                    tableView.alpha = enabled ? 1.0 : 0.5
                    tableView.userInteractionEnabled = enabled
                }
            },
            completion: nil
        )
    }
    
    func updateDisplay() {
        
        var lines = [String]()
        var organismType = ""
        if let organism = self.organism {
            
            for property in organism.entity.properties {
                
                let value: AnyObject = organism.valueForKey(property.name) ?? NSNull()
                lines.append("\(property.name): \(value)")
            }
            organismType = "\(objc_getClass(organism.entity.managedObjectClassName))"
        }
        
        self.titleLabel?.text = organismType
        self.organismLabel?.text = "\n".join(lines)
    }
}
