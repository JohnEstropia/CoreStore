//
//  ObjectObserverDemoViewController.swift
//  HardcoreDataDemo
//
//  Created by John Rommel Estropia on 2015/05/06.
//  Copyright (c) 2015 John Rommel Estropia. All rights reserved.
//

import UIKit
import HardcoreData


// MARK: - ObjectObserverDemoViewController

class ObjectObserverDemoViewController: UIViewController, ManagedObjectObserver {
    
    // MARK: NSObject
    
    deinit {
        
        self.objectController.removeObserver(self)
    }
    

    // MARK: UIViewController
    
    required init(coder aDecoder: NSCoder) {
        
        if let palette = HardcoreData.fetchOne(From(Palette), SortedBy(.Ascending("hue"))) {
            
            self.objectController = HardcoreData.observeObject(palette)
        }
        else {
            
            HardcoreData.beginSynchronous { (transaction) -> Void in
                
                let palette = transaction.create(Palette)
                palette.setInitialValues()
                
                transaction.commitAndWait()
            }
            
            let palette = HardcoreData.fetchOne(From(Palette), SortedBy(.Ascending("hue")))!
            self.objectController = HardcoreData.observeObject(palette)
        }
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.objectController.addObserver(self)
        
        if let palette = self.objectController.object {
            
            self.reloadPaletteInfo(palette)
            self.hueSlider?.value = Float(palette.hue)
            self.saturationSlider?.value = palette.saturation
            self.brightnessSlider?.value = palette.brightness
        }
    }
    
    
    // MARK: ManagedObjectObserver
    
    func managedObjectWillUpdate(objectController: ManagedObjectController<Palette>, object: Palette) {
        
    }
    
    func managedObjectWasUpdated(objectController: ManagedObjectController<Palette>, object: Palette) {
        
        self.reloadPaletteInfo(object)
    }
    
    func managedObjectWasDeleted(objectController: ManagedObjectController<Palette>, object: Palette) {
        
        self.colorNameLabel?.alpha = 0.3
        self.colorView?.alpha = 0.3
        self.dateLabel?.text = "Deleted"
        self.dateLabel?.textColor = UIColor.redColor()
        
        self.hueSlider?.enabled = false
        self.saturationSlider?.enabled = false
        self.brightnessSlider?.enabled = false
    }

    
    // MARK: Private
    
    let objectController: ManagedObjectController<Palette>
    
    @IBOutlet weak var colorNameLabel: UILabel?
    @IBOutlet weak var colorView: UIView?
    @IBOutlet weak var hsbLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var hueSlider: UISlider?
    @IBOutlet weak var saturationSlider: UISlider?
    @IBOutlet weak var brightnessSlider: UISlider?
    
    @IBAction dynamic func hueSliderValueDidChange(sender: AnyObject?) {
        
        let hue = self.hueSlider?.value ?? 0
        HardcoreData.beginAsynchronous { [weak self] (transaction) -> Void in
            
            if let palette = transaction.fetch(self?.objectController.object) {
                
                palette.hue = Int32(hue)
                palette.dateAdded = NSDate()
                transaction.commit { (result) -> Void in }
            }
        }
    }
    
    @IBAction dynamic func saturationSliderValueDidChange(sender: AnyObject?) {
        
        let saturation = self.saturationSlider?.value ?? 0
        HardcoreData.beginAsynchronous { [weak self] (transaction) -> Void in
            
            if let palette = transaction.fetch(self?.objectController.object) {
                
                palette.saturation = saturation
                palette.dateAdded = NSDate()
                transaction.commit { (result) -> Void in }
            }
        }
    }
    
    @IBAction dynamic func brightnessSliderValueDidChange(sender: AnyObject?) {
        
        let brightness = self.brightnessSlider?.value ?? 0
        HardcoreData.beginAsynchronous { [weak self] (transaction) -> Void in
            
            if let palette = transaction.fetch(self?.objectController.object) {
                
                palette.brightness = brightness
                palette.dateAdded = NSDate()
                transaction.commit { (result) -> Void in }
            }
        }
    }
    
    @IBAction dynamic func deleteBarButtonTapped(sender: AnyObject?) {
        
        HardcoreData.beginAsynchronous { [weak self] (transaction) -> Void in
            
            transaction.delete(self?.objectController.object)
            transaction.commit { (result) -> Void in }
        }
        
        (sender as? UIBarButtonItem)?.enabled = false
    }
    
    func reloadPaletteInfo(palette: Palette) {
        
        self.colorNameLabel?.text = palette.colorName
        
        let color = palette.color
        self.colorNameLabel?.textColor = color
        self.colorView?.backgroundColor = color
        
        self.hsbLabel?.text = "H: \(palette.hue)˚, S: \(round(palette.saturation * 100.0))%, B: \(round(palette.brightness * 100.0))%"
        
        let dateString = NSDateFormatter.localizedStringFromDate(
            palette.dateAdded,
            dateStyle: .ShortStyle,
            timeStyle: .LongStyle
        )
        self.dateLabel?.text = "Updated: \(dateString)"
    }
}
