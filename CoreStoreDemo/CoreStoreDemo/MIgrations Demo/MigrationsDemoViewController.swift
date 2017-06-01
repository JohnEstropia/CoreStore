//
//  MigrationsDemoViewController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/06/21.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreStore


// MARK: - MigrationsDemoViewController

class MigrationsDemoViewController: UIViewController, ListObserver, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let segmentedControl = self.segmentedControl {
            
            for (index, model) in self.models.enumerated() {
                
                segmentedControl.setTitle(
                    model.label,
                    forSegmentAt: index
                )
            }
        }
        self.set(dataStack: nil, model: nil, scrollToSelection: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let alert = UIAlertController(
            title: "Migrations Demo",
            message: "This demo shows how to run progressive migrations and how to support multiple model versions in a single project.\n\nThe persistent store contains 10000 organisms, which gain/lose properties when the migration evolves/devolves them.\n\nYou can use the \"mutate\" button to change an organism's properties then migrate to a different model to see how its value gets affected.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        
        let modelMetadata = withExtendedLifetime(DataStack(xcodeModelName: "MigrationDemo")) {
            (dataStack: DataStack) -> ModelMetadata in
            
            let models = self.models
            let migrations = try! dataStack.requiredMigrationsForStorage(
                SQLiteStore(fileName: "MigrationDemo.sqlite")
            )
            
            guard let storeVersion = migrations.first?.sourceVersion else {
            
                return models.first!
            }
            for model in models {
                
                if model.schemaHistory.currentModelVersion == storeVersion {
                    
                    return model
                }
            }
            
            return models.first!
        }
        
        self.selectModelVersion(modelMetadata)
    }
    
    // MARK: ListObserver
    
    func listMonitorWillChange(_ monitor: ListMonitor<NSManagedObject>) { }
    
    func listMonitorDidChange(_ monitor: ListMonitor<NSManagedObject>) {
        
        if self.lastSelectedIndexPath == nil,
            let numberOfObjectsInSection = self.listMonitor?.numberOfObjectsInSection(0),
            numberOfObjectsInSection > 0 {
            
            self.tableView?.reloadData()
            self.setSelectedIndexPath(IndexPath(row: 0, section: 0), scrollToSelection: false)
        }
        else {
            
            self.updateDisplay(reloadData: true, scrollToSelection: true, animated: true)
        }
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<NSManagedObject>) {
        
        self.listMonitorDidChange(monitor)
    }
    
    // MARK: UITableViewDataSource
    
    @objc dynamic func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.listMonitor?.numberOfObjectsInSection(0) ?? 0
    }
    
    @objc dynamic func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrganismTableViewCell", for: indexPath) as! OrganismTableViewCell
        
        let dna = (self.listMonitor?[indexPath] as? OrganismProtocol)?.dna.description ?? ""
        cell.dnaLabel?.text = "DNA: \(dna)"
        cell.mutateButtonHandler = { [weak self] _ -> Void in
            
            guard let `self` = self,
                let dataStack = self.dataStack,
                let organism = self.listMonitor?[indexPath] else {
                    
                    return
            }
            
            self.setSelectedIndexPath(indexPath, scrollToSelection: false)
            self.setEnabled(false)
            dataStack.perform(
                asynchronous: { (transaction) in
                    
                    let organism = transaction.edit(organism) as! OrganismProtocol
                    organism.mutate()
                },
                completion: { [weak self] _ in
                    
                    self?.setEnabled(true)
                }
            )
        }
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    
    @objc dynamic func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.setSelectedIndexPath(indexPath, scrollToSelection: false)
    }
    
    
    // MARK: Private
    
    private typealias ModelMetadata = (label: String, entityType: NSManagedObject.Type, schemaHistory: SchemaHistory)
    
    private let models: [ModelMetadata] = [
        (
            label: "Model V1",
            entityType: OrganismV1.self,
            schemaHistory: SchemaHistory(
                XcodeDataModelSchema.from(
                    modelName: "MigrationDemo",
                    migrationChain: ["MigrationDemoV3", "MigrationDemoV2", "MigrationDemo"]
                ),
                migrationChain: ["MigrationDemoV3", "MigrationDemoV2", "MigrationDemo"]
            )
        ),
        (
            label: "Model V2",
            entityType: OrganismV2.self,
            schemaHistory: SchemaHistory(
                XcodeDataModelSchema.from(
                    modelName: "MigrationDemo",
                    migrationChain: [
                        "MigrationDemo": "MigrationDemoV2",
                        "MigrationDemoV3": "MigrationDemoV2"
                    ]
                ),
                migrationChain: [
                    "MigrationDemo": "MigrationDemoV2",
                    "MigrationDemoV3": "MigrationDemoV2"
                ]
            )
        ),
        (
            label: "Model V3",
            entityType: OrganismV3.self,
            schemaHistory: SchemaHistory(
                XcodeDataModelSchema.from(
                    modelName: "MigrationDemo",
                    migrationChain: ["MigrationDemo", "MigrationDemoV2", "MigrationDemoV3"]
                ),
                migrationChain: ["MigrationDemo", "MigrationDemoV2", "MigrationDemoV3"]
            )
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
    
    private var _lastSelectedIndexPath: IndexPath?
    private var lastSelectedIndexPath: IndexPath? {
        
        return self._lastSelectedIndexPath
    }
    
    private func setSelectedIndexPath(_ indexPath: IndexPath, scrollToSelection: Bool) {
        
        self._lastSelectedIndexPath = indexPath
        self.updateDisplay(reloadData: false, scrollToSelection: scrollToSelection, animated: true)
    }
    
    @IBOutlet private dynamic weak var headerContainer: UIView?
    @IBOutlet private dynamic weak var titleLabel: UILabel?
    @IBOutlet private dynamic weak var organismLabel: UILabel?
    @IBOutlet private dynamic weak var segmentedControl: UISegmentedControl?
    @IBOutlet private dynamic weak var progressView: UIProgressView?
    @IBOutlet private dynamic weak var tableView: UITableView?
    
    @IBAction private dynamic func segmentedControlValueChanged(_ sender: AnyObject?) {
        
        guard let index = self.segmentedControl?.selectedSegmentIndex else {
            
            return
        }
        
        self.selectModelVersion(self.models[index])
    }
    
    private func selectModelVersion(_ model: ModelMetadata) {
        
        if self.dataStack?.modelVersion == model.schemaHistory.currentModelVersion {
            
            return
        }
        
        self.set(dataStack: nil, model: nil, scrollToSelection: false) // explicitly trigger NSPersistentStore cleanup by deallocating the stack
        
        let dataStack = DataStack(schemaHistory: model.schemaHistory)
        
        self.setEnabled(false)
        let progress = dataStack.addStorage(
            SQLiteStore(
                fileName: "MigrationDemo.sqlite",
                migrationMappingProviders: [
                    CustomSchemaMappingProvider(
                        from: "MigrationDemoV3",
                        to: "MigrationDemoV2",
                        entityMappings: [
                            .transformEntity(
                                sourceEntity: "Organism",
                                destinationEntity: "Organism",
                                transformer: { (source, createDestination) in
                                    
                                    let destination = createDestination()
                                    destination.enumerateAttributes { (attribute, sourceAttribute) in
                                        
                                        if let sourceAttribute = sourceAttribute {
                                            
                                            destination[attribute] = source[sourceAttribute]
                                        }
                                    }
                                    destination["numberOfFlippers"] = source["numberOfLimbs"]
                                }
                            )
                        ]
                    )
                ]
            ),
            completion: { [weak self] (result) -> Void in
                
                guard let `self` = self else {
                    
                    return
                }
                
                guard case .success = result else {
                    
                    self.setEnabled(true)
                    return
                }
                
                self.set(dataStack: dataStack, model: model, scrollToSelection: true)
                
                let count = dataStack.queryValue(
                    From(model.entityType),
                    Select<Int>(.count(#keyPath(OrganismV1.dna))))!
                if count > 0 {
                    
                    self.setEnabled(true)
                }
                else {
                    
                    for i: Int64 in 0 ..< 20 {
                        
                        dataStack.perform(
                            asynchronous: { (transaction) in
                                
                                for j: Int64 in 0 ..< 500 {
                                    
                                    let organism = transaction.create(Into(model.entityType)) as! OrganismProtocol
                                    organism.dna = (i * 500) + j + 1
                                    organism.mutate()
                                }
                            },
                            completion: { _ in }
                        )
                    }
                    dataStack.perform(
                        asynchronous: { _ in },
                        completion: { [weak self] _ in
                    
                            self?.setEnabled(true)
                        }
                    )
                }
            }
        )
        
        if let progress = progress {
            
            progress.setProgressHandler { [weak self] (progress) -> Void in
                
                self?.reloadTableHeaderWithProgress(progress)
            }
        }
    }
    
    private func setEnabled(_ enabled: Bool) {
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .beginFromCurrentState,
            animations: { () -> Void in
                
                let navigationItem = self.navigationItem
                navigationItem.leftBarButtonItem?.isEnabled = enabled
                navigationItem.rightBarButtonItem?.isEnabled = enabled
                navigationItem.hidesBackButton = !enabled
                
                self.segmentedControl?.isEnabled = enabled
                
                if let tableView = self.tableView {
                    
                    tableView.alpha = enabled ? 1.0 : 0.5
                    tableView.isUserInteractionEnabled = enabled
                }
            },
            completion: nil
        )
    }
    
    private func set(dataStack: DataStack?, model: ModelMetadata?, scrollToSelection: Bool) {
        
        if let dataStack = dataStack, let model = model {
            
            self.segmentedControl?.selectedSegmentIndex = self.models
                .index(
                    where: { (_, _, schemaHistory) -> Bool in
                        
                        schemaHistory.currentModelVersion == model.schemaHistory.currentModelVersion
                    }
                )!
            
            self._dataStack = dataStack
            let listMonitor = dataStack.monitorList(From(model.entityType), OrderBy(.descending("dna")))
            listMonitor.addObserver(self)
            self._listMonitor = listMonitor
            
            if self.lastSelectedIndexPath == nil  {
                
                if listMonitor.numberOfObjectsInSection(0) > 0 {
                    
                    self.setSelectedIndexPath(IndexPath(row: 0, section: 0), scrollToSelection: true)
                }
            }
        }
        else {
           
            self.segmentedControl?.selectedSegmentIndex = UISegmentedControlNoSegment
            self._listMonitor = nil
            self._dataStack = nil
        }
        
        self.updateDisplay(reloadData: true, scrollToSelection: scrollToSelection, animated: false)
    }
    
    private func reloadTableHeaderWithProgress(_ progress: Progress) {
        
        self.progressView?.setProgress(Float(progress.fractionCompleted), animated: true)
        self.titleLabel?.text = "Migrating: \(progress.localizedDescription ?? "")"
        self.organismLabel?.text = "Progressive step \(progress.localizedAdditionalDescription ?? "")"
    }
    
    private func updateDisplay(reloadData: Bool, scrollToSelection: Bool, animated: Bool) {
        
        var lines = [String]()
        var organismType = ""
        if let indexPath = self.lastSelectedIndexPath, let organism = self.listMonitor?[indexPath] {
            
            for property in organism.entity.properties {
                
                let value = organism.value(forKey: property.name) ?? NSNull()
                lines.append("\(property.name): \(value)")
            }
            organismType = organism.entity.managedObjectClassName
        }
        
        self.titleLabel?.text = organismType
        self.organismLabel?.text = lines.joined(separator: "\n")
        self.progressView?.progress = 0
        
        self.headerContainer?.setNeedsLayout()
        
        guard let tableView = self.tableView else {
            
            return
        }
        
        if reloadData {
            
            tableView.reloadData()
        }
        
        tableView.layoutIfNeeded()
        
        if let indexPath = self.lastSelectedIndexPath,
            indexPath.row < tableView.numberOfRows(inSection: 0) {
            
            tableView.selectRow(at: indexPath,
                animated: scrollToSelection && animated,
                scrollPosition: scrollToSelection ? .middle : .none
            )
        }
    }
}
