//
//  MigrationsDemoViewController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/06/21.
//  Copyright (c) 2015 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreStore


private struct Static {
    
    static let migrationStack: DataStack = {
        
        let dataStack = DataStack(
            modelName: "MigrationDemo",
            modelVersions: ["MigrationDemo", "MigrationDemoV2", "MigrationDemoV3"]
        )
        dataStack.addSQLiteStoreAndWait(
            "MigrationsDemo.sqlite",
            automigrating: true, // default is true anyway
            resetStoreOnMigrationFailure: true
        )
        
        dataStack.beginSynchronous { (transaction) -> Void in
            
            transaction.deleteAll(From(OrganismV1))
            
            let organism = transaction.create(Into(OrganismV1))
            organism.hasHead = true
            organism.hasTail = true
            
            transaction.commit()
        }
        
        return dataStack
    }()
}


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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath) as! UITableViewCell
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
    
    private typealias ModelMetadata = (version: String, entityType: AnyClass)
    
    private let models: [ModelMetadata] = [
        (version: "MigrationDemo", entityType: OrganismV1.self),
        (version: "MigrationDemoV2", entityType: OrganismV2.self),
        (version: "MigrationDemoV3", entityType: OrganismV3.self)
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
            modelVersions: ["MigrationDemo", "MigrationDemoV2", "MigrationDemoV3"]
        )
        self.dataStack = dataStack
        
        dataStack.addSQLiteStore(
            "MigrationDemo.sqlite",
            completion: { [weak self] (result) -> Void in
                
                if let strongSelf = self {
                    
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
                            forRow: find(
                                strongSelf.models.map { $0.version },
                                model.version
                            )!,
                            inSection: 0
                        ),
                        animated: false,
                        scrollPosition: .None
                    )
                }
            }
        )
    }
    
    func updateDisplay() {
        
        var lines = [String]()
        var organismType = ""
        if let organism = self.organism {
            
            for property in organism.entity.properties as! [NSPropertyDescription] {
                
                let value: AnyObject = organism.valueForKey(property.name) ?? NSNull()
                lines.append("\(property.name): \(value)")
            }
            organismType = "\(objc_getClass(organism.entity.managedObjectClassName))"
        }
        
        self.titleLabel?.text = organismType
        self.organismLabel?.text = "\n".join(lines)
    }
}
