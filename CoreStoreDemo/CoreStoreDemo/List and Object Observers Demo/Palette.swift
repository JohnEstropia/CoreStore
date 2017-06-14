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

final class Palette: CoreStoreObject {
    
    let hue = Value.Required<Int>("hue")
    let saturation = Value.Required<Float>("saturation")
    let brightness = Value.Required<Float>("brightness")
    
    let colorName = Value.Optional<String>(
        "colorName",
        isTransient: true,
        customGetter: Palette.getCachedColorName
    )
    
    private static func getCachedColorName(_ instance: Palette, _ getValue: () -> String?) -> String? {
        
        if let colorName = getValue() {
            
            return colorName
        }
        
        let colorName: String
        switch instance.hue.value % 360 {
            
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
        
        instance.colorName.primitiveValue = colorName
        return colorName
    }
}

extension Palette {
    
    var color: UIColor {
        
        return UIColor(
            hue: CGFloat(self.hue.value) / 360.0,
            saturation: CGFloat(self.saturation.value),
            brightness: CGFloat(self.brightness.value),
            alpha: 1.0
        )
    }
    
    var colorText: String {
        
        return "H: \(self.hue.value)˚, S: \(round(self.saturation.value * 100.0))%, B: \(round(self.brightness.value * 100.0))%"
    }
    
    func setInitialValues(in transaction: BaseDataTransaction) {
        
        self.hue .= Int(arc4random_uniform(360))
        self.saturation .= Float(1.0)
        self.brightness .= Float(arc4random_uniform(70) + 30) / 100.0
    }
}
