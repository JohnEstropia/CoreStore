//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import UIKit


// MARK: - Modern.PokedexDemo.UIKit

extension Modern.PokedexDemo.UIKit {
    
    // MARK: - Modern.PokedexDemo.ListViewController
    
    final class ListViewController: UICollectionViewController {
        
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
            let cellWidth = min(
                230,
                floor((screenWidth - ((cellsPerRow - 1) * layout.minimumInteritemSpacing)) / cellsPerRow)
            )
            layout.itemSize = .init(
                width: cellWidth,
                height: ceil(cellWidth * (4 / 3))
            )
            super.init(collectionViewLayout: layout)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            
            fatalError()
        }
        
        deinit {
            
            self.listPublisher.removeObserver(self)
        }

        
        // MARK: UIViewController

        override func viewDidLoad() {
            
            super.viewDidLoad()
            
            self.collectionView.backgroundColor = UIColor.systemBackground
            
            self.collectionView.register(
                Modern.PokedexDemo.UIKit.ItemCell.self,
                forCellWithReuseIdentifier: Modern.PokedexDemo.UIKit.ItemCell.reuseIdentifier
            )

            self.startObservingList()
        }
        
        
        // MARK: Private
        
        private let service: Modern.PokedexDemo.Service
        private let listPublisher: ListPublisher<Modern.PokedexDemo.PokedexEntry>
        
        private lazy var dataSource: DiffableDataSource.CollectionViewAdapter<Modern.PokedexDemo.PokedexEntry> = .init(
            collectionView: self.collectionView,
            dataStack: Modern.PokedexDemo.dataStack,
            cellProvider: { (collectionView, indexPath, pokedexEntry) in
                
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: Modern.PokedexDemo.UIKit.ItemCell.reuseIdentifier,
                    for: indexPath
                ) as! Modern.PokedexDemo.UIKit.ItemCell
                cell.setPokedexEntry(pokedexEntry, service: self.service)
                return cell
            }
        )
        
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
        
    }
}
