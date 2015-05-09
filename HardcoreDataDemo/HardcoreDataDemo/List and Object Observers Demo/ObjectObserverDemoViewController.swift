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
    
    var palette: Palette? {
        
        get {
            
            return self.objectController?.object
        }
        set {
            
            if let palette = newValue {
                
                self.objectController = HardcoreData.observeObject(palette)
            }
            else {
                
                self.objectController = nil
            }
        }
    }
    
    // MARK: NSObject
    
    deinit {
        
        self.objectController?.removeObserver(self)
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
        self.objectController?.addObserver(self)
        
        if let palette = self.objectController?.object {
            
            self.reloadPaletteInfo(palette)
        }
    }
    
    
    // MARK: ManagedObjectObserver
    
    func managedObjectWillUpdate(objectController: ManagedObjectController<Palette>, object: Palette) {
        
        // none
    }
    
    func managedObjectWasUpdated(objectController: ManagedObjectController<Palette>, object: Palette) {
        
        self.reloadPaletteInfo(object)
    }
    
    func managedObjectWasDeleted(objectController: ManagedObjectController<Palette>, object: Palette) {
        
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        self.colorNameLabel?.alpha = 0.3
        self.colorView?.alpha = 0.3
        
        self.hsbLabel?.text = "Deleted"
        self.hsbLabel?.textColor = UIColor.redColor()
        
        self.hueSlider?.enabled = false
        self.saturationSlider?.enabled = false
        self.brightnessSlider?.enabled = false
    }

    
    // MARK: Private
    
    var objectController: ManagedObjectController<Palette>?
    
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
            
            if let palette = transaction.fetch(self?.objectController?.object) {
                
                palette.hue = Int32(hue)
                palette.dateAdded = NSDate()
                transaction.commit { (result) -> Void in }
            }
        }
    }
    
    @IBAction dynamic func saturationSliderValueDidChange(sender: AnyObject?) {
        
        let saturation = self.saturationSlider?.value ?? 0
        HardcoreData.beginAsynchronous { [weak self] (transaction) -> Void in
            
            if let palette = transaction.fetch(self?.objectController?.object) {
                
                palette.saturation = saturation
                palette.dateAdded = NSDate()
                transaction.commit { (result) -> Void in }
            }
        }
    }
    
    @IBAction dynamic func brightnessSliderValueDidChange(sender: AnyObject?) {
        
        let brightness = self.brightnessSlider?.value ?? 0
        HardcoreData.beginAsynchronous { [weak self] (transaction) -> Void in
            
            if let palette = transaction.fetch(self?.objectController?.object) {
                
                palette.brightness = brightness
                palette.dateAdded = NSDate()
                transaction.commit { (result) -> Void in }
            }
        }
    }
    
    @IBAction dynamic func deleteBarButtonTapped(sender: AnyObject?) {
        
        HardcoreData.beginAsynchronous { [weak self] (transaction) -> Void in
            
            transaction.delete(self?.objectController?.object)
            transaction.commit { (result) -> Void in }
        }
    }
    
    func reloadPaletteInfo(palette: Palette) {
        
        self.colorNameLabel?.text = palette.colorName
        
        let color = palette.color
        self.colorNameLabel?.textColor = color
        self.colorView?.backgroundColor = color
        
        let hue = palette.hue
        let saturation = palette.saturation
        let brightness = palette.brightness
        
        self.hsbLabel?.text = "H: \(hue)˚, S: \(Int(saturation * 100))%, B: \(Int(brightness * 100))%"
        
        if Int32(self.hueSlider?.value ?? 0) != hue {
            
            self.hueSlider?.value = Float(hue)
        }
        if self.saturationSlider?.value != saturation {
            
            self.saturationSlider?.value = saturation
        }
        if self.brightnessSlider?.value != brightness {
            
            self.brightnessSlider?.value = brightness
        }
    }
}
