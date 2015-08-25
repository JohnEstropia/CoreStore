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

class MigrationsDemoViewController: UIViewController {
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let segmentedControl = self.segmentedControl {
            
            for (index, model) in self.models.enumerate() {
                
                segmentedControl.setTitle(
                    model.label,
                    forSegmentAtIndex: index
                )
            }
        }
        self.setDataStack(nil, model: nil, scrollToSelection: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let alert = UIAlertController(
            title: "Migrations Demo",
            message: "This demo shows how to run incremental migrations and how to support multiple model versions in a single project.\n\nThe persistent store contains 10000 organisms, which gain/lose properties when the migration evolves/devolves them.\n\nYou can use the \"mutate\" button to change an organism's properties then migrate to a different model to see how its value gets affected.",
            preferredStyle: .Alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        
        let modelMetadata = withExtendedLifetime(DataStack(modelName: "MigrationDemo")) {
            (dataStack: DataStack) -> ModelMetadata in
            
            let models = self.models
            do {
                
                let migrations = try dataStack.requiredMigrationsForSQLiteStore(
                    fileName: "MigrationDemo.sqlite"
                )
                
                let storeVersion = migrations.first?.sourceVersion ?? dataStack.modelVersion
                for model in models {
                    
                    if model.version == storeVersion {
                        
                        return model
                    }
                }
            }
            catch _ { }
            
            return models.first!
        }
        
        self.selectModelVersion(modelMetadata)
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
    
    private var _listMonitor: ListMonitor<NSManagedObject>?
    private var listMonitor: ListMonitor<NSManagedObject>? {
        
        return self._listMonitor
    }
    
    private var _dataStack: DataStack?
    private var dataStack: DataStack? {
        
        return self._dataStack
    }
    
    private var _lastSelectedIndexPath: NSIndexPath?
    private var lastSelectedIndexPath: NSIndexPath? {
        
        return self._lastSelectedIndexPath
    }
    
    private func setSelectedIndexPath(indexPath: NSIndexPath, scrollToSelection: Bool) {
        
        self._lastSelectedIndexPath = indexPath
        self.updateDisplay(reloadData: false, scrollToSelection: scrollToSelection, animated: true)
    }
    
    @IBOutlet private dynamic weak var headerContainer: UIView?
    @IBOutlet private dynamic weak var titleLabel: UILabel?
    @IBOutlet private dynamic weak var organismLabel: UILabel?
    @IBOutlet private dynamic weak var segmentedControl: UISegmentedControl?
    @IBOutlet private dynamic weak var progressView: UIProgressView?
    @IBOutlet private dynamic weak var tableView: UITableView?
    
    @IBAction private dynamic func segmentedControlValueChanged(sender: AnyObject?) {
        
        guard let index = self.segmentedControl?.selectedSegmentIndex else {
            
            return
        }
        
        self.selectModelVersion(self.models[index])
    }
    
    private func selectModelVersion(model: ModelMetadata) {
        
        if self.dataStack?.modelVersion == model.version {
            
            return
        }
        
        self.setDataStack(nil, model: nil, scrollToSelection: false) // explicitly trigger NSPersistentStore cleanup by deallocating the stack
        
        let dataStack = DataStack(
            modelName: "MigrationDemo",
            migrationChain: model.migrationChain
        )
        
        self.setEnabled(false)
        let progress = try! dataStack.addSQLiteStore(
            fileName: "MigrationDemo.sqlite",
            completion: { [weak self] (result) -> Void in
                
                guard let strongSelf = self else {
                    
                    return
                }
                
                guard case .Success = result else {
                    
                    strongSelf.setEnabled(true)
                    return
                }
                
                strongSelf.setDataStack(dataStack, model: model, scrollToSelection: true)
                
                let count = dataStack.queryValue(From(model.entityType), Select<Int>(.Count("dna")))
                if count > 0 {
                    
                    strongSelf.setEnabled(true)
                }
                else {
                    
                    dataStack.beginAsynchronous { (transaction) -> Void in
                        
                        for i: Int64 in 1 ..< 10000 {
                            
                            let organism = transaction.create(Into(model.entityType)) as! OrganismProtocol
                            organism.dna = i
                            organism.mutate()
                        }
                        
                        transaction.commit { result -> Void in
                            
                            self?.setEnabled(true)
                        }
                    }
                }
            }
        )
        
        if let progress = progress {
            
            progress.setProgressHandler { [weak self] (progress) -> Void in
                
                self?.reloadTableHeaderWithProgress(progress)
            }
        }
    }
    
    private func setEnabled(enabled: Bool) {
        
        UIView.animateWithDuration(
            0.2,
            delay: 0,
            options: .BeginFromCurrentState,
            animations: { () -> Void in
                
                let navigationItem = self.navigationItem
                navigationItem.leftBarButtonItem?.enabled = enabled
                navigationItem.rightBarButtonItem?.enabled = enabled
                navigationItem.hidesBackButton = !enabled
                
                self.segmentedControl?.enabled = enabled
                
                if let tableView = self.tableView {
                    
                    tableView.alpha = enabled ? 1.0 : 0.5
                    tableView.userInteractionEnabled = enabled
                }
            },
            completion: nil
        )
    }
    
    private func setDataStack(dataStack: DataStack?, model: ModelMetadata?, scrollToSelection: Bool) {
        
        if let dataStack = dataStack, let model = model {
            
            self.segmentedControl?.selectedSegmentIndex = self.models.map { $0.version }.indexOf(model.version)!
            
            self._dataStack = dataStack
            let listMonitor = dataStack.monitorList(From(model.entityType), OrderBy(.Descending("dna")))
            listMonitor.addObserver(self)
            self._listMonitor = listMonitor
            
            if self.lastSelectedIndexPath == nil  {
                
                if listMonitor.numberOfObjectsInSection(0) > 0 {
                    
                    self.setSelectedIndexPath(NSIndexPath(forRow: 0, inSection: 0), scrollToSelection: true)
                }
            }
        }
        else {
           
            self.segmentedControl?.selectedSegmentIndex = UISegmentedControlNoSegment
            self._dataStack = nil
            self._listMonitor = nil
        }
        
        self.updateDisplay(reloadData: true, scrollToSelection: scrollToSelection, animated: false)
    }
    
    private func reloadTableHeaderWithProgress(progress: NSProgress) {
        
        self.progressView?.setProgress(Float(progress.fractionCompleted), animated: true)
        self.titleLabel?.text = "Migrating: \(progress.localizedDescription)"
        self.organismLabel?.text = "Incremental step \(progress.localizedAdditionalDescription)"
    }
    
    private func updateDisplay(reloadData reloadData: Bool, scrollToSelection: Bool, animated: Bool) {
        
        var lines = [String]()
        var organismType = ""
        if let indexPath = self.lastSelectedIndexPath, let organism = self.listMonitor?[indexPath] {
            
            for property in organism.entity.properties {
                
                let value: AnyObject = organism.valueForKey(property.name) ?? NSNull()
                lines.append("\(property.name): \(value)")
            }
            organismType = organism.entity.managedObjectClassName
        }
        
        self.titleLabel?.text = organismType
        self.organismLabel?.text = lines.joinWithSeparator("\n")
        self.progressView?.progress = 0
        
        self.headerContainer?.setNeedsLayout()
        
        guard let tableView = self.tableView else {
            
            return
        }
        
        if reloadData {
            
            tableView.reloadData()
        }
        
        tableView.layoutIfNeeded()
        
        if let indexPath = self.lastSelectedIndexPath where indexPath.row < tableView.numberOfRowsInSection(0) {
            
            tableView.selectRowAtIndexPath(indexPath,
                animated: scrollToSelection && animated,
                scrollPosition: scrollToSelection ? .Middle : .None
            )
        }
    }
}


// MARK: - MigrationsDemoViewController: ListObserver

extension MigrationsDemoViewController: ListObserver {
    
    // MARK: ListObserver
    
    func listMonitorWillChange(monitor: ListMonitor<NSManagedObject>) { }
    
    func listMonitorDidChange(monitor: ListMonitor<NSManagedObject>) {
        
        if self.lastSelectedIndexPath == nil && self.listMonitor?.numberOfObjectsInSection(0) > 0 {
            
            self.tableView?.reloadData()
            self.setSelectedIndexPath(NSIndexPath(forRow: 0, inSection: 0), scrollToSelection: false)
        }
        else {
            
            self.updateDisplay(reloadData: true, scrollToSelection: true, animated: true)
        }
    }
}


// MARK: - MigrationsDemoViewController: UITableViewDataSource, UITableViewDelegate

extension MigrationsDemoViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: UITableViewDataSource
    
    @objc dynamic func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.listMonitor?.numberOfObjectsInSection(0) ?? 0
    }
    
    @objc dynamic func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("OrganismTableViewCell", forIndexPath: indexPath) as! OrganismTableViewCell
        
        let dna = (self.listMonitor?[indexPath] as? OrganismProtocol)?.dna.description ?? ""
        cell.dnaLabel?.text = "DNA: \(dna)"
        cell.mutateButtonHandler = { [weak self] _ -> Void in
            
            guard let strongSelf = self,
                let dataStack = strongSelf.dataStack,
                let organism = strongSelf.listMonitor?[indexPath] else {
                    
                    return
            }
            
            strongSelf.setSelectedIndexPath(indexPath, scrollToSelection: false)
            strongSelf.setEnabled(false)
            dataStack.beginAsynchronous { (transaction) -> Void in
                
                let organism = transaction.edit(organism) as! OrganismProtocol
                organism.mutate()
                
                transaction.commit { _ -> Void in
                    
                    self?.setEnabled(true)
                }
            }
        }
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    
    @objc dynamic func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.setSelectedIndexPath(indexPath, scrollToSelection: false)
    }
}
