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
        
        let models = self.models
        if let segmentedControl = self.segmentedControl {
            
            for (index, model) in models.enumerate() {
                
                segmentedControl.setTitle(
                    model.label,
                    forSegmentAtIndex: index
                )
            }
        }
        
        let dataStack = DataStack(modelName: "MigrationDemo")
        do {
            
            let migrations = try dataStack.requiredMigrationsForSQLiteStore(
                fileName: "MigrationDemo.sqlite"
            )
            
            let storeVersion = migrations.first?.sourceVersion ?? dataStack.modelVersion
            for model in models {
                
                if model.version == storeVersion {
                    
                    self.selectModelVersion(model, animated: false)
                    return
                }
            }
        }
        catch _ { }
        
        self.selectModelVersion(self.models.first!, animated: false)
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
        
        self.selectModelVersion(self.models[indexPath.row], animated: true)
    }
    
    
    // MARK: Private
    
    private typealias ModelMetadata = (label: String, version: String, entityType: AnyClass, migrationChain: MigrationChain)
    
    private let models: [ModelMetadata] = [
        (
            label: "Model V1",
            version: "MigrationDemo",
            entityType: OrganismV1.self,
            migrationChain: ["MigrationDemoV3", "MigrationDemoV2", "MigrationDemo"]
        ),
        (
            label: "Model V2",
            version: "MigrationDemoV2",
            entityType: OrganismV2.self,
            migrationChain: [
                "MigrationDemo": "MigrationDemoV2",
                "MigrationDemoV3": "MigrationDemoV2"
            ]
        ),
        (
            label: "Model V3",
            version: "MigrationDemoV3",
            entityType: OrganismV3.self,
            migrationChain: ["MigrationDemo", "MigrationDemoV2", "MigrationDemoV3"]
        )
    ]
    
    private var dataStack: DataStack?
    private var organism: NSManagedObject?
    
    @IBOutlet private dynamic weak var titleLabel: UILabel?
    @IBOutlet private dynamic weak var organismLabel: UILabel?
    @IBOutlet private dynamic weak var segmentedControl: UISegmentedControl?
    @IBOutlet private dynamic weak var progressView: UIProgressView?
    
    @IBAction private dynamic func mutateBarButtonTapped(sender: AnyObject?) {
        
        if let dataStack = self.dataStack, let organism = self.organism {
            
            dataStack.beginSynchronous { (transaction) -> Void in
                
                let organism = transaction.edit(organism)
                (organism as! OrganismProtocol).mutate()
                
                transaction.commit()
            }
            self.updateDisplayWithCompletion()
        }
    }
    
    @IBAction private dynamic func segmentedControlValueChanged(sender: AnyObject?) {
        
        guard let index = self.segmentedControl?.selectedSegmentIndex else {
            
            return
        }
        
        self.selectModelVersion(self.models[index], animated: true)
    }
    
    private func selectModelVersion(model: ModelMetadata, animated: Bool) {
        
        if self.organism?.entity.managedObjectClassName == "\(model.entityType)" {
            
            return
        }
        
        self.organism = nil
        self.dataStack = nil
        
        let dataStack = DataStack(
            modelName: "MigrationDemo",
            migrationChain: model.migrationChain
        )
        
        self.setEnabled(false, animated: animated)
        let progress = try! dataStack.addSQLiteStore(
            fileName: "MigrationDemo.sqlite",
            completion: { [weak self] (result) -> Void in
                
                guard let strongSelf = self else {
                    
                    return
                }
                
                guard case .Success = result else {
                    
                    strongSelf.setEnabled(true, animated: animated)
                    return
                }
                
                strongSelf.dataStack = dataStack
                if let organism = dataStack.fetchOne(From(model.entityType)) {
                    
                    strongSelf.organism = organism
                }
                else {
                    
                    dataStack.beginSynchronous { (transaction) -> Void in
                        
                        for _ in 0 ..< 100000 {
                            
                            let organism = transaction.create(Into(model.entityType))
                            (organism as! OrganismProtocol).mutate()
                        }
                        
                        transaction.commit()
                    }
                    strongSelf.organism = dataStack.fetchOne(From(model.entityType))!
                }
                
                strongSelf.updateDisplayWithCompletion()
                
                let indexOfModel = strongSelf.models.map { $0.version }.indexOf(model.version)!
                strongSelf.tableView.selectRowAtIndexPath(
                    NSIndexPath(forRow: indexOfModel, inSection: 0),
                    animated: false,
                    scrollPosition: .None
                )
                strongSelf.segmentedControl?.selectedSegmentIndex = indexOfModel
                strongSelf.setEnabled(true, animated: animated)
            }
        )
        
        if let progress = progress {
            
            self.updateDisplayWithProgress(progress)
            progress.setProgressHandler { [weak self] (progress) -> Void in
                
                self?.updateDisplayWithProgress(progress)
            }
        }
    }
    
    func setEnabled(enabled: Bool, animated: Bool) {
        
        UIView.animateKeyframesWithDuration(
            animated ? 0.2 : 0,
            delay: 0,
            options: .BeginFromCurrentState,
            animations: { () -> Void in
                
                let navigationItem = self.navigationItem
                navigationItem.leftBarButtonItem?.enabled = enabled
                navigationItem.rightBarButtonItem?.enabled = enabled
                navigationItem.hidesBackButton = !enabled
                
                if let tableView = self.tableView {
                    
                    tableView.alpha = enabled ? 1.0 : 0.5
                    tableView.userInteractionEnabled = enabled
                }
            },
            completion: nil
        )
    }
    
    func updateDisplayWithProgress(progress: NSProgress) {
        
        self.progressView?.setProgress(Float(progress.fractionCompleted), animated: true)
        self.titleLabel?.text = "Migrating: \(progress.localizedDescription)"
        self.organismLabel?.text = "Incremental step \(progress.localizedAdditionalDescription)"
    }
    
    func updateDisplayWithCompletion() {
        
        var lines = [String]()
        var organismType = ""
        if let organism = self.organism {
            
            for property in organism.entity.properties {
                
                let value: AnyObject = organism.valueForKey(property.name) ?? NSNull()
                lines.append("\(property.name): \(value)")
            }
            organismType = organism.entity.managedObjectClassName
        }
        
        self.titleLabel?.text = organismType
        self.organismLabel?.text = "\n".join(lines)
        self.progressView?.progress = 0
        self.tableView.tableHeaderView?.setNeedsLayout()
    }
}
