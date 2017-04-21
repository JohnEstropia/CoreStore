//
//  Palette.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/05/05.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreStore


// MARK: - Palette

class Palette: NSManagedObject {

    @NSManaged var hue: Int32
    @NSManaged var saturation: Float
    @NSManaged var brightness: Float
    
    @objc dynamic var colorName: String {
        
        get {
            
            let KVCKey = #keyPath(Palette.colorName)
            if let colorName = self.getValue(forKvcKey: KVCKey) as? String {
                
                return colorName
            }
            
            let colorName: String
            switch self.hue % 360 {
                
            case 0 ..< 20: colorName = "Lower Reds"
            case 20 ..< 57: colorName = "Oranges and Browns"
            case 57 ..< 90: colorName = "Yellow-Greens"
            case 90 ..< 159: colorName = "Greens"
            case 159 ..< 197: colorName = "Blue-Greens"
            case 197 ..< 241: colorName = "Blues"
            case 241 ..< 297: colorName = "Violets"
            case 297 ..< 331: colorName = "Magentas"
            default: colorName = "Upper Reds"
            }
            
            self.setPrimitiveValue(colorName, forKey: KVCKey)
            return colorName
        }
        set {
            
            self.setValue(newValue.cs_toImportableNativeType(), forKvcKey: #keyPath(Palette.colorName))
        }
    }
    
    var color: UIColor {
        
        return UIColor(
            hue: CGFloat(self.hue) / 360.0,
            saturation: CGFloat(self.saturation),
            brightness: CGFloat(self.brightness),
            alpha: 1.0
        )
    }
    
    var colorText: String {
        
        return "H: \(self.hue)˚, S: \(round(self.saturation * 100.0))%, B: \(round(self.brightness * 100.0))%"
    }
    
    func setInitialValues() {
        
        self.hue = Int32(arc4random_uniform(360))
        self.saturation = 1.0
        self.brightness = Float(arc4random_uniform(70) + 30) / 100.0
    }
}
