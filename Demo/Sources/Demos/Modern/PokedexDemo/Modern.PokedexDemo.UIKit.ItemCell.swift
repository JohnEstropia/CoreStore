//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import Combine
import CoreStore
import UIKit


// MARK: - Modern.PokedexDemo.UIKit

extension Modern.PokedexDemo.UIKit {

    // MARK: - Modern.PokedexDemo.ItemCell
    
    final class ItemCell: UICollectionViewCell {
        
        // MARK: Internal
        
        static let reuseIdentifier: String = NSStringFromClass(Modern.PokedexDemo.UIKit.ItemCell.self)
        
        func setPokedexEntry(
            _ pokedexEntry: Modern.PokedexDemo.PokedexEntry,
            service: Modern.PokedexDemo.Service
        ) {

            guard let pokedexEntry = pokedexEntry.asPublisher() else {
                
                return self.pokedexEntry = nil
            }
            guard self.pokedexEntry != pokedexEntry else {
                
                return
            }
            self.service = service
            self.pokedexEntry = pokedexEntry
            
            self.didUpdateData(animated: false)
            
            if let snapshot = pokedexEntry.snapshot {

                service.fetchDetails(for: snapshot)
            }
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            
            fatalError()
        }
        
        
        // MARK: UITableViewCell
        
        override init(frame: CGRect) {
            
            super.init(frame: frame)
            
            let contentView = self.contentView
            do {
                
                contentView.backgroundColor = UIColor.placeholderText.withAlphaComponent(0.1)
                contentView.layer.cornerRadius = 10
                contentView.layer.cornerCurve = .continuous
                contentView.layer.masksToBounds = true
            }
            
            let typesContainerView = UIStackView()
            do {
                
                typesContainerView.translatesAutoresizingMaskIntoConstraints = false
                typesContainerView.axis = .horizontal
                typesContainerView.alignment = .fill
                typesContainerView.distribution = .fillEqually
                typesContainerView.spacing = 0
                
                typesContainerView.addArrangedSubview(self.type1View)
                typesContainerView.addArrangedSubview(self.type2View)
                
                contentView.addSubview(typesContainerView)
            }
            
            let spriteView = self.spriteView
            do {
                
                spriteView.translatesAutoresizingMaskIntoConstraints = false
                spriteView.contentMode = .scaleAspectFill
                
                contentView.addSubview(spriteView)
            }
            let placeholderLabel = self.placeholderLabel
            do {
                
                placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
                placeholderLabel.textColor = UIColor.placeholderText
                placeholderLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
                placeholderLabel.numberOfLines = 0
                placeholderLabel.textAlignment = .center
                
                contentView.addSubview(placeholderLabel)
            }
            let nameLabel = self.nameLabel
            do {
                
                nameLabel.translatesAutoresizingMaskIntoConstraints = false
                nameLabel.textColor = UIColor.white
                nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
                nameLabel.numberOfLines = 0
                nameLabel.textAlignment = .center
                
                contentView.addSubview(nameLabel)
            }
            
            layout: do {
                
                NSLayoutConstraint.activate(
                    [
                        typesContainerView.topAnchor.constraint(
                            equalTo: contentView.topAnchor
                        ),
                        typesContainerView.leadingAnchor.constraint(
                            equalTo: contentView.leadingAnchor
                        ),
                        typesContainerView.bottomAnchor.constraint(
                            equalTo: contentView.bottomAnchor
                        ),
                        typesContainerView.trailingAnchor.constraint(
                            equalTo: contentView.trailingAnchor
                        ),
                        
                        spriteView.topAnchor.constraint(
                            equalTo: contentView.topAnchor
                        ),
                        spriteView.leadingAnchor.constraint(
                            equalTo: contentView.leadingAnchor
                        ),
                        spriteView.bottomAnchor.constraint(
                            equalTo: contentView.bottomAnchor
                        ),
                        spriteView.trailingAnchor.constraint(
                            equalTo: contentView.trailingAnchor
                        ),
                        
                        placeholderLabel.topAnchor.constraint(
                            equalTo: contentView.topAnchor,
                            constant: 10
                        ),
                        placeholderLabel.leadingAnchor.constraint(
                            equalTo: contentView.leadingAnchor,
                            constant: 10
                        ),
                        placeholderLabel.bottomAnchor.constraint(
                            equalTo: contentView.bottomAnchor,
                            constant: -10
                        ),
                        placeholderLabel.trailingAnchor.constraint(
                            equalTo: contentView.trailingAnchor,
                            constant: -10
                        ),
                        
                        nameLabel.leadingAnchor.constraint(
                            equalTo: contentView.leadingAnchor,
                            constant: 10
                        ),
                        nameLabel.bottomAnchor.constraint(
                            equalTo: contentView.bottomAnchor,
                            constant: -10
                        ),
                        nameLabel.trailingAnchor.constraint(
                            equalTo: contentView.trailingAnchor,
                            constant: -10
                        ),
                    ]
                )
            }
        }
        
        override func prepareForReuse() {
            
            super.prepareForReuse()
            
            self.service = nil
            self.pokedexEntry = nil
            self.didUpdateData(animated: false)
        }
        
        
        // MARK: Private
        
        private let spriteView: UIImageView = .init()
        private let placeholderLabel: UILabel = .init()
        private let nameLabel: UILabel = .init()
        private let type1View: UIView = .init()
        private let type2View: UIView = .init()
        
        private var service: Modern.PokedexDemo.Service?
        
        private var imageURL: URL? {
            
            didSet {
                
                let newValue = self.imageURL
                guard newValue != oldValue else {
                    
                    return
                }
                self.imageDownloader = ImageDownloader(url: newValue)
            }
        }
        
        private var imageDownloader: ImageDownloader = .init(url: nil) {
            
            didSet {
                
                let url = self.imageDownloader.url
                if url == nil {
                    
                    self.spriteView.image = nil
                    return
                }
                self.imageDownloader.fetchImage { [weak self] in
                    
                    guard let self = self, url == self.imageURL else {
                        
                        return
                    }
                    self.spriteView.image = $0
                    self.spriteView.layer.add(CATransition(), forKey: nil)
                }
            }
        }
        
        private var pokedexEntry: ObjectPublisher<Modern.PokedexDemo.PokedexEntry>? {
            
            didSet {
                
                let newValue = self.pokedexEntry
                guard newValue != oldValue else {
                    
                    return
                }
                oldValue?.removeObserver(self)
                newValue?.addObserver(self) { [weak self] newValue in
                    
                    guard let self = self else {
                        
                        return
                    }
                    self.details = newValue.snapshot?.$details
                    
                    self.didUpdateData(animated: true)
                }
                
                self.details = newValue?.snapshot?.$details
            }
        }
        
        private var details: ObjectPublisher<Modern.PokedexDemo.Details>? {
            
            didSet {
                
                let newValue = self.details
                guard newValue != oldValue else {
                    
                    return
                }
                oldValue?.removeObserver(self)
                newValue?.addObserver(self) { [weak self] newValue in
                    
                    guard let self = self else {
                        
                        return
                    }
                    let details = newValue.snapshot
                    self.species = details?.$species
                    self.forms = details?.$forms
                    
                    self.didUpdateData(animated: true)
                }
                
                let details = newValue?.snapshot
                self.species = details?.$species
                self.forms = details?.$forms
            }
        }
        
        private var species: ObjectPublisher<Modern.PokedexDemo.Species>? {
            
            didSet {
                
                let newValue = self.species
                guard newValue != oldValue else {
                    
                    return
                }
                oldValue?.removeObserver(self)
                newValue?.addObserver(self) { [weak self] _ in
                    
                    self?.didUpdateData(animated: true)
                }
            }
        }
        
        private var formsRotationCancellable: AnyCancellable?
        private var forms: [ObjectPublisher<Modern.PokedexDemo.Form>]? {
            
            didSet {
                
                let newValue = self.forms
                guard newValue != oldValue else {
                    
                    return
                }
                self.currentForm = newValue?.first
                
                self.formsRotationCancellable = newValue.flatMap { newValue in
                    
                    guard !newValue.isEmpty else {
                        
                        return nil
                    }
                    return Timer
                        .publish(every: 0.5, on: .main, in: .common)
                        .autoconnect()
                        .scan(1, { (index, _) in index + 1 })
                        .sink(
                            receiveValue: { [weak self] (index) in
                                
                                guard let self = self else {
                                    
                                    return
                                }
                                self.currentForm = newValue[index % newValue.count]
                                self.didUpdateData(animated: true)
                            }
                        )
                }
            }
        }
        
        private var currentForm: ObjectPublisher<Modern.PokedexDemo.Form>? {
            
            didSet {
                
                let newValue = self.currentForm
                guard newValue != oldValue else {
                    
                    return
                }
                oldValue?.removeObserver(self)
                newValue?.addObserver(self) { [weak self] _ in
                    
                    self?.didUpdateData(animated: true)
                }
            }
        }
        
        private func didUpdateData(animated: Bool) {
            
            let pokedexEntry = self.pokedexEntry?.snapshot
            let species = self.species?.snapshot
            let currentForm = self.currentForm?.snapshot
            
            self.placeholderLabel.text = pokedexEntry?.$id
            self.placeholderLabel.isHidden = species != nil
            
            self.type1View.backgroundColor = species?.$pokemonType1.color
                ?? UIColor.clear
            self.type1View.isHidden = species == nil
            
            self.type2View.backgroundColor = species?.$pokemonType2?.color
                ?? species?.$pokemonType1.color
                ?? UIColor.clear
            self.type2View.isHidden = species == nil
            
            self.nameLabel.text = currentForm?.$name ?? species?.$name
            self.nameLabel.isHidden = currentForm == nil && species == nil
            
            self.imageURL = currentForm?.$spriteURL
            
            guard animated else {
                
                return
            }
            self.contentView.layer.add(CATransition(), forKey: nil)
        }
    }
}
