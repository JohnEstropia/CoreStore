//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import UIKit


// MARK: - Modern.ColorsDemo.UIKit

extension Modern.ColorsDemo.UIKit {
    
    // MARK: - Modern.ColorsDemo.UIKit.DetailViewController
    
    final class DetailViewController: UIViewController, ObjectObserver {
        
        /**
         ⭐️ Sample 1: We can normally use `ObjectPublisher` directly, which is simpler. But for this demo, we will be using `ObjectMonitor` instead because we need to keep track of which properties change to prevent our `UISlider` from stuttering. Refer to the `objectMonitor(_:didUpdateObject:changedPersistentKeys:)` implementation below.
         */
        init(_ palette: ObjectPublisher<Modern.ColorsDemo.Palette>) {
            
            self.palette = Modern.ColorsDemo.dataStack.monitorObject(
                palette.object!
            )
            super.init(nibName: nil, bundle: nil)
        }
        
        /**
         ⭐️ Sample 2: Once the views are created, we can start receiving `ObjectMonitor` updates in our `ObjectObserver` conformance methods. We typically call this at the end of `viewDidLoad`. Note that after the `addObserver` call, only succeeding updates will trigger our `ObjectObserver` methods, so to immediately display the current values, we need to initialize our views once (in this case, using `reloadPaletteInfo(_:changedKeys:)`.
         */
        private func startMonitoringObject() {
            
            self.palette.addObserver(self)
            if let palette = self.palette.object {
                
                self.reloadPaletteInfo(palette, changedKeys: nil)
            }
        }
        
        /**
         ⭐️ Sample 3: We can end monitoring updates anytime. `removeObserver()` was called here for illustration purposes only. `ObjectMonitor`s safely remove deallocated observers automatically.
         */
        var palette: ObjectMonitor<Modern.ColorsDemo.Palette> {
            
            didSet {
                
                oldValue.removeObserver(self)
                self.startMonitoringObject()
            }
        }
        
        deinit {
            
            self.palette.removeObserver(self)
        }
        
        /**
         ⭐️ Sample 4: Our `objectMonitor(_:didUpdateObject:changedPersistentKeys:)` implementation passes a `Set<KeyPathString>` to our reload method. We can then inspect which values were triggered by each `UISlider`, so we can avoid double-updates that can lag the `UISlider` dragging.
         */
        func reloadPaletteInfo(
            _ palette: Modern.ColorsDemo.Palette,
            changedKeys: Set<KeyPathString>?
        ) {
            
            self.view.backgroundColor = palette.color
            
            self.hueLabel.text = "H: \(Int(palette.hue * 359))°"
            self.saturationLabel.text = "S: \(Int(palette.saturation * 100))%"
            self.brightnessLabel.text = "B: \(Int(palette.brightness * 100))%"
            
            if changedKeys == nil
                || changedKeys?.contains(String(keyPath: \Modern.ColorsDemo.Palette.$hue)) == true {
                
                self.hueSlider.value = Float(palette.hue)
            }
            if changedKeys == nil
                || changedKeys?.contains(String(keyPath: \Modern.ColorsDemo.Palette.$saturation)) == true {
                
                self.saturationSlider.value = palette.saturation
            }
            if changedKeys == nil
                || changedKeys?.contains(String(keyPath: \Modern.ColorsDemo.Palette.$brightness)) == true {
                
                self.brightnessSlider.value = palette.brightness
            }
        }
        
        
        // MARK: ObjectObserver
        
        func objectMonitor(
            _ monitor: ObjectMonitor<Modern.ColorsDemo.Palette>,
            didUpdateObject object: Modern.ColorsDemo.Palette,
            changedPersistentKeys: Set<KeyPathString>,
            sourceIdentifier: Any?
        ) {
            
            self.reloadPaletteInfo(object, changedKeys: changedPersistentKeys)
        }
        
        
        // MARK: UIViewController
        
        override func viewDidLoad() {
            
            super.viewDidLoad()
            
            let view = self.view!
            let containerView = UIView()
            do {
                containerView.translatesAutoresizingMaskIntoConstraints = false
                containerView.backgroundColor = UIColor.white
                containerView.layer.cornerRadius = 10
                containerView.layer.masksToBounds = true
                containerView.layer.shadowColor = UIColor(white: 0.5, alpha: 0.3).cgColor
                containerView.layer.shadowOffset = .init(width: 1, height: 1)
                containerView.layer.shadowRadius = 2
                
                view.addSubview(containerView)
            }
            
            let vStackView = UIStackView()
            do {
                vStackView.translatesAutoresizingMaskIntoConstraints = false
                vStackView.axis = .vertical
                vStackView.spacing = 10
                vStackView.distribution = .fill
                vStackView.alignment = .fill
                
                containerView.addSubview(vStackView)
            }
            
            let palette = self.palette.object
            let rows: [(label: UILabel, slider: UISlider, initialValue: Float, sliderValueChangedSelector: Selector)] = [
                (
                    self.hueLabel,
                    self.hueSlider,
                    palette?.hue ?? 0,
                    #selector(self.hueSliderValueDidChange(_:))
                ),
                (
                    self.saturationLabel,
                    self.saturationSlider,
                    palette?.saturation ?? 0,
                    #selector(self.saturationSliderValueDidChange(_:))
                ),
                (
                    self.brightnessLabel,
                    self.brightnessSlider,
                    palette?.brightness ?? 0,
                    #selector(self.brightnessSliderValueDidChange(_:))
                )
            ]
            for (label, slider, initialValue, sliderValueChangedSelector) in rows {
                
                let hStackView = UIStackView()
                do {
                    hStackView.translatesAutoresizingMaskIntoConstraints = false
                    hStackView.axis = .horizontal
                    hStackView.spacing = 5
                    hStackView.distribution = .fill
                    hStackView.alignment = .center
                    
                    vStackView.addArrangedSubview(hStackView)
                }
                do {
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.textColor = UIColor(white: 0, alpha: 0.8)
                    label.textAlignment = .center
                    
                    hStackView.addArrangedSubview(label)
                }
                do {
                    slider.translatesAutoresizingMaskIntoConstraints = false
                    slider.minimumValue = 0
                    slider.maximumValue = 1
                    slider.value = initialValue
                    slider.addTarget(
                        self,
                        action: sliderValueChangedSelector,
                        for: .valueChanged
                    )
                    
                    hStackView.addArrangedSubview(slider)
                }
            }
            
            layout: do {
                
                NSLayoutConstraint.activate(
                    [
                        containerView.leadingAnchor.constraint(
                            equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                            constant: 10
                        ),
                        containerView.centerYAnchor.constraint(
                            equalTo: view.safeAreaLayoutGuide.centerYAnchor
                        ),
                        containerView.trailingAnchor.constraint(
                            equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                            constant: -10
                        ),
                        
                        vStackView.topAnchor.constraint(
                            equalTo: containerView.topAnchor,
                            constant: 15
                        ),
                        vStackView.leadingAnchor.constraint(
                            equalTo: containerView.leadingAnchor,
                            constant: 15
                        ),
                        vStackView.bottomAnchor.constraint(
                            equalTo: containerView.bottomAnchor,
                            constant: -15
                        ),
                        vStackView.trailingAnchor.constraint(
                            equalTo: containerView.trailingAnchor,
                            constant: -15
                        )
                    ]
                )
                NSLayoutConstraint.activate(
                    rows.map { label, _, _, _ in
                        label.widthAnchor.constraint(equalToConstant: 80)
                    }
                )
            }
            
            self.startMonitoringObject()
        }
        
        
        // MARK: Private
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            
            fatalError()
        }
        
        private let hueLabel: UILabel = .init()
        private let saturationLabel: UILabel = .init()
        private let brightnessLabel: UILabel = .init()
        private let hueSlider: UISlider = .init()
        private let saturationSlider: UISlider = .init()
        private let brightnessSlider: UISlider = .init()
        
        @objc
        private dynamic func hueSliderValueDidChange(_ sender: UISlider) {
            
            let value = sender.value
            Modern.ColorsDemo.dataStack.perform(
                asynchronous: { [weak self] (transaction) in
                    
                    let palette = transaction.edit(self?.palette.object)
                    palette?.hue = value
                },
                completion: { _ in }
            )
        }
        
        @objc
        private dynamic func saturationSliderValueDidChange(_ sender: UISlider) {
            
            let value = sender.value
            Modern.ColorsDemo.dataStack.perform(
                asynchronous: { [weak self] (transaction) in
                    
                    let palette = transaction.edit(self?.palette.object)
                    palette?.saturation = value
                },
                completion: { _ in }
            )
        }
        
        @objc
        private dynamic func brightnessSliderValueDidChange(_ sender: UISlider) {
            
            let value = sender.value
            Modern.ColorsDemo.dataStack.perform(
                asynchronous: { [weak self] (transaction) in
                    
                    let palette = transaction.edit(self?.palette.object)
                    palette?.brightness = value
                },
                completion: { _ in }
            )
        }
    }
}


