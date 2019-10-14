//
//  ListObserverDemoViewController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/05/02.
//  Copyright © 2018 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreStore


struct ColorsDemo {
    
    enum Filter: String {
        
        case all = "All Colors"
        case light = "Light Colors"
        case dark = "Dark Colors"
        
        func next() -> Filter {
            
            switch self {
                
            case .all: return .light
            case .light: return .dark
            case .dark: return .all
            }
        }
        
        func whereClause() -> Where<Palette> {
            
            switch self {
                
            case .all: return .init()
            case .light: return (\Palette.brightness >= 0.9)
            case .dark: return (\Palette.brightness <= 0.4)
            }
        }
    }
    
    static var filter = Filter.all {
        
        didSet {
            
//            self.palettes.refetch(
//                self.filter.whereClause(),
//                OrderBy<Palette>(.ascending(\.hue))
//            )
        }
    }
    
    static let stack: DataStack = {
     
        let dataStack = DataStack(
            CoreStoreSchema(
                modelVersion: "ColorsDemo",
                entities: [
                    Entity<Palette>("Palette"),
                ],
                versionLock: [
                    "Palette": [0x8c25aa53c7c90a28, 0xa243a34d25f1a3a7, 0x56565b6935b6055a, 0x4f988bb257bf274f]
                ]
            )
        )

        try! dataStack.addStorageAndWait(
            SQLiteStore(
                fileName: "ColorsDemo.sqlite",
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        )
        return dataStack
    }()
    
    static let palettes: LiveList<Palette> = {

        return ColorsDemo.stack.liveList(
            From<Palette>()
                .sectionBy(\.colorName)
                .orderBy(.ascending(\.hue))
        )
    }()
}


// MARK: - ListObserverDemoViewController

class ListObserverDemoViewController: UITableViewController {
    
    // MARK: UIViewController

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let navigationItem = self.navigationItem
        navigationItem.leftBarButtonItems = [
            self.editButtonItem,
            UIBarButtonItem(
                barButtonSystemItem: .trash,
                target: self,
                action: #selector(self.resetBarButtonItemTouched(_:))
            )
        ]
        
        let filterBarButton = UIBarButtonItem(
            title: ColorsDemo.filter.rawValue,
            style: .plain,
            target: self,
            action: #selector(self.filterBarButtonItemTouched(_:))
        )
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(self.addBarButtonItemTouched(_:))
            ),
            UIBarButtonItem(
                barButtonSystemItem: .refresh,
                target: self,
                action: #selector(self.shuffleBarButtonItemTouched(_:))
            ),
            filterBarButton
        ]
        self.filterBarButton = filterBarButton

        self.dataSource = DiffableDataSource.TableView<Palette>(
            tableView: self.tableView,
            dataStack: ColorsDemo.stack,
            cellProvider: { (tableView, indexPath, palette) in
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "PaletteTableViewCell") as! PaletteTableViewCell
                cell.colorView?.backgroundColor = palette.color
                cell.label?.text = palette.colorText
                return cell
            }
        )
        ColorsDemo.palettes.addObserver(self) { [weak self] (liveList) in
            
            guard let self = self else {
                
                return
            }
            self.dataSource?.apply(liveList.snapshot, animatingDifferences: true)
        }
        self.dataSource?.apply(ColorsDemo.palettes.snapshot, animatingDifferences: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier, segue.destination, sender) {
            
        case ("ObjectObserverDemoViewController"?, let destinationViewController as ObjectObserverDemoViewController, let palette as LiveObject<Palette>):
            destinationViewController.setPalette(palette)
            
        default:
            break
        }
    }
    
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.performSegue(
            withIdentifier: "ObjectObserverDemoViewController",
            sender: ColorsDemo.palettes[indexPath: indexPath]
        )
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
            
        case .delete:
            let palette = ColorsDemo.palettes[indexPath: indexPath]
            ColorsDemo.stack.perform(
                asynchronous: { (transaction) in
                    
                    transaction.delete(palette?.object)
                },
                completion: { _ in }
            )
            
        default:
            break
        }
    }
    
    
    // MARK: Private
    
    private var filterBarButton: UIBarButtonItem?
    private var dataSource: DiffableDataSource.TableView<Palette>?
    
    deinit {
        
        ColorsDemo.palettes.removeObserver(self)
    }
    
    @IBAction private dynamic func resetBarButtonItemTouched(_ sender: AnyObject?) {
        
        ColorsDemo.stack.perform(
            asynchronous: { (transaction) in
                
                try transaction.deleteAll(From<Palette>())
            },
            completion: { _ in }
        )
    }
    
    @IBAction private dynamic func filterBarButtonItemTouched(_ sender: AnyObject?) {
        
        ColorsDemo.filter = ColorsDemo.filter.next()
    }
    
    @IBAction private dynamic func addBarButtonItemTouched(_ sender: AnyObject?) {
        
        ColorsDemo.stack.perform(
            asynchronous: { (transaction) in
                
                let palette = transaction.create(Into<Palette>())
                palette.setInitialValues(in: transaction)
            },
            completion: { _ in }
        )
    }

    @IBAction private dynamic func shuffleBarButtonItemTouched(_ sender: AnyObject?) {
        ColorsDemo.stack.perform(
            asynchronous: { (transaction) in

                for palette in try transaction.fetchAll(From<Palette>()) {

                    palette.hue .= Palette.randomHue()
                    palette.colorName .= nil
                }
            },
            completion: { _ in }
        )
    }
}

