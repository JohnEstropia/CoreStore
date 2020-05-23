//
//  CollectionViewDemoViewController.swift
//  CoreStoreDemo
//
//  Created by John Estropia on 2019/10/17.
//  Copyright © 2019 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreStore


// MARK: - CollectionViewDemoViewController

final class CollectionViewDemoViewController: UICollectionViewController {

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

        self.dataSource = DiffableDataSource.CollectionViewAdapter<Palette>(
            collectionView: self.collectionView,
            dataStack: ColorsDemo.stack,
            cellProvider: { (collectionView, indexPath, palette) in

                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaletteCollectionViewCell", for: indexPath) as! PaletteCollectionViewCell
                cell.colorView?.backgroundColor = palette.color
                cell.label?.text = palette.colorText
                return cell
            },
            supplementaryViewProvider: { (collectionView, kind, indexPath) in

                switch kind {

                case UICollectionView.elementKindSectionHeader:
                    let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PaletteCollectionSectionHeaderView", for: indexPath) as! PaletteCollectionSectionHeaderView
                    view.label?.text = ColorsDemo.palettes.snapshot.sectionIDs[indexPath.section]
                    return view

                default:
                    return nil
                }
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


    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        collectionView.deselectItem(at: indexPath, animated: true)

        self.performSegue(
            withIdentifier: "ObjectObserverDemoViewController",
            sender: ColorsDemo.palettes.snapshot[indexPath]
        )
    }


    // MARK: Private

    private var filterBarButton: UIBarButtonItem?
    private var dataSource: DiffableDataSource.CollectionViewAdapter<Palette>?

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
