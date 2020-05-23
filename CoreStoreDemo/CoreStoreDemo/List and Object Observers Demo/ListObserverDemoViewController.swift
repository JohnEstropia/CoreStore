//
//  ListObserverDemoViewController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/05/02.
//  Copyright © 2018 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreStore


// MARK: - ListObserverDemoViewController

final class ListObserverDemoViewController: UITableViewController {

    // MARK: - EditableDataSource

    final class EditableDataSource: DiffableDataSource.TableViewAdapter<Palette> {

        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

            switch editingStyle {

            case .delete:
                let palette = ColorsDemo.palettes.snapshot[indexPath]
                ColorsDemo.stack.perform(
                    asynchronous: { (transaction) in

                        transaction.delete(palette)
                    },
                    completion: { _ in }
                )

            default:
                break
            }
        }
    }

    
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

        self.dataSource = EditableDataSource(
            tableView: self.tableView,
            dataStack: ColorsDemo.stack,
            cellProvider: { (tableView, indexPath, palette) in
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "PaletteTableViewCell") as! PaletteTableViewCell
                cell.colorView?.backgroundColor = palette.color
                cell.label?.text = palette.colorText
                return cell
            }
        )
        ColorsDemo.palettes.addObserver(self) { [weak self] (listPublisher) in
            
            guard let self = self else {
                
                return
            }
            self.filterBarButton?.title = ColorsDemo.filter.rawValue
            self.dataSource?.apply(listPublisher.snapshot, animatingDifferences: true)
        }
        self.dataSource?.apply(ColorsDemo.palettes.snapshot, animatingDifferences: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier, segue.destination, sender) {
            
        case ("ObjectObserverDemoViewController"?, let destinationViewController as ObjectObserverDemoViewController, let palette as ObjectPublisher<Palette>):
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
            sender: ColorsDemo.palettes.snapshot[indexPath]
        )
    }
    
    
    // MARK: Private
    
    private var filterBarButton: UIBarButtonItem?
    private var dataSource: DiffableDataSource.TableViewAdapter<Palette>?
    
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
                
                _ = transaction.create(Into<Palette>())
            },
            completion: { _ in }
        )
    }

    @IBAction private dynamic func shuffleBarButtonItemTouched(_ sender: AnyObject?) {
        ColorsDemo.stack.perform(
            asynchronous: { (transaction) in

                for palette in try transaction.fetchAll(From<Palette>()) {

                    palette.hue = Palette.randomHue()
                    palette.colorName = nil
                }
            },
            completion: { _ in }
        )
    }
}

