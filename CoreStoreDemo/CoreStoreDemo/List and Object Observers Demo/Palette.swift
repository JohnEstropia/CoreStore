//
//  Palette.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/05/05.
//  Copyright © 2018 John Rommel Estropia. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreStore


// MARK: - Palette

final class Palette: CoreStoreObject {
    
    @Field.Stored(
        "hue",
        dynamicInitialValue: { Palette.randomHue() }
    )
    var hue: Int

    @Field.Stored("saturation")
    var saturation: Float = 1
    
    @Field.Stored(
        "brightness",
        dynamicInitialValue: { Palette.randomBrightness() }
    )
    var brightness: Float
    
    @Field.Virtual(
        "colorName",
        customGetter: { object, field in
            if let colorName = field.primitiveValue {
                return colorName
            }
            let colorName: String
            switch object.$hue.value % 360 {
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
            field.primitiveValue = colorName
            return colorName
        }
    )
    var colorName: String!
    
    static func randomHue() -> Int {
        
        return Int.random(in: 0 ..< 360)
    }
    
    static func randomBrightness() -> Float {
        
        return (Float.random(in: 0 ..< 70) + 30) / 100.0
    }
}

extension Palette {
    
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
}
