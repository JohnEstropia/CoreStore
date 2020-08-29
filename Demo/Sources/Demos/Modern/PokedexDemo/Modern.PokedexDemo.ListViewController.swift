//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import UIKit


// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {
    
    // MARK: - Modern.PokedexDemo.ListViewController
    
    final class ListViewController: UICollectionViewController {
        
        /**
         ⭐️ Sample 1: Setting up a `DiffableDataSource.TableViewAdapter` that will manage tableView snapshot updates automatically. We can use the built-in `DiffableDataSource.TableViewAdapter` type directly, but in our case we want to enabled `UITableView` cell deletions so we create a custom subclass `DeletionEnabledDataSource` (see declatation below).
         */
        private lazy var dataSource: DiffableDataSource.CollectionViewAdapter<Modern.PokedexDemo.PokedexEntry> = .init(
            collectionView: self.collectionView,
            dataStack: Modern.PokedexDemo.dataStack,
            cellProvider: { (collectionView, indexPath, pokedexEntry) in
                
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: Modern.PokedexDemo.ItemCell.reuseIdentifier,
                    for: indexPath
                ) as! Modern.PokedexDemo.ItemCell
                cell.setPokedexEntry(pokedexEntry, service: self.service)
                return cell
            }
        )
        
        /**
         ⭐️ Sample 2: Once the views are created, we can start binding `ListPublisher` updates to the `DiffableDataSource`. We typically call this at the end of `viewDidLoad`. Note that the `addObserver`'s closure argument will only be called on the succeeding updates, so to immediately display the current values, we need to call `dataSource.apply()` once.
         */
        private func startObservingList() {
            
            self.listPublisher.addObserver(self) { (listPublisher) in
                
                self.dataSource.apply(
                    listPublisher.snapshot,
                    animatingDifferences: true
                )
            }
            self.dataSource.apply(
                self.listPublisher.snapshot,
                animatingDifferences: false
            )
        }
        
        /**
         ⭐️ Sample 3: We can end monitoring updates anytime. `removeObserver()` was called here for illustration purposes only. `ListPublisher`s safely remove deallocated observers automatically.
         */
        deinit {
            
            self.listPublisher.removeObserver(self)
        }
        
        
        // MARK: Internal
        
        init(
            service: Modern.PokedexDemo.Service,
            listPublisher: ListPublisher<Modern.PokedexDemo.PokedexEntry>
        ) {
            
            self.service = service
            self.listPublisher = listPublisher
            
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = .init(
                top: 10, left: 10, bottom: 10, right: 10
            )
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
            
            let screenWidth = UIScreen.main.bounds.inset(by: layout.sectionInset).width
            let cellsPerRow: CGFloat = 3
            let cellWidth = floor((screenWidth - ((cellsPerRow - 1) * layout.minimumInteritemSpacing)) / cellsPerRow)
            layout.itemSize = .init(
                width: cellWidth,
                height: ceil(cellWidth * (4 / 3))
            )
            super.init(collectionViewLayout: layout)
        }

        
        // MARK: UIViewController

        override func viewDidLoad() {
            
            super.viewDidLoad()
            
            self.collectionView.register(
                Modern.PokedexDemo.ItemCell.self,
                forCellWithReuseIdentifier: Modern.PokedexDemo.ItemCell.reuseIdentifier
            )

            self.startObservingList()
        }
        
        
        // MARK: Private
        
        private let service: Modern.PokedexDemo.Service
        private let listPublisher: ListPublisher<Modern.PokedexDemo.PokedexEntry>
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            
            fatalError()
        }
    }
}
