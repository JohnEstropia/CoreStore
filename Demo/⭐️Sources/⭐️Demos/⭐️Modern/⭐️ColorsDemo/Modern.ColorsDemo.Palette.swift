//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import UIKit
import CoreStore

// MARK: - Modern.ColorsDemo

extension Modern.ColorsDemo {

    // MARK: - Modern.ColorsDemo.Palette
    
    final class Palette: CoreStoreObject {
        
        // MARK: Internal
        
        @Field.Stored(
            "hue",
            customSetter: { object, field, value in
                
                Palette.resetVirtualProperties(object)
                field.primitiveValue = value
            },
            dynamicInitialValue: { Palette.randomHue() }
        )
        var hue: Float

        @Field.Stored(
            "saturation",
            customSetter: { object, field, value in
                
                Palette.resetVirtualProperties(object)
                field.primitiveValue = value
            },
            dynamicInitialValue: { Palette.randomSaturation() }
        )
        var saturation: Float
        
        @Field.Stored(
            "brightness",
            customSetter: { object, field, value in
                
                Palette.resetVirtualProperties(object)
                field.primitiveValue = value
            },
            dynamicInitialValue: { Palette.randomBrightness() }
        )
        var brightness: Float
        
        @Field.Virtual(
            "colorGroup",
            customGetter: { object, field in
                
                if let colorGroup = field.primitiveValue {
                    
                    return colorGroup
                }
                let colorGroup: String
                switch object.$hue.value * 359 {
                    
                case 0 ..< 20: colorGroup = "Lower Reds"
                case 20 ..< 57: colorGroup = "Oranges and Browns"
                case 57 ..< 90: colorGroup = "Yellow-Greens"
                case 90 ..< 159: colorGroup = "Greens"
                case 159 ..< 197: colorGroup = "Blue-Greens"
                case 197 ..< 241: colorGroup = "Blues"
                case 241 ..< 297: colorGroup = "Violets"
                case 297 ..< 331: colorGroup = "Magentas"
                default: colorGroup = "Upper Reds"
                }
                field.primitiveValue = colorGroup
                return colorGroup
            }
        )
        var colorGroup: String
        
        @Field.Virtual(
            "color",
            customGetter: { object, field in
                
                if let color = field.primitiveValue {
                    
                    return color
                }
                let color = UIColor(
                    hue: CGFloat(object.$hue.value),
                    saturation: CGFloat(object.$saturation.value),
                    brightness: CGFloat(object.$brightness.value),
                    alpha: 1.0
                )
                field.primitiveValue = color
                return color
            }
        )
        var color: UIColor
        
        @Field.Virtual(
            "colorText",
            customGetter: { object, field in
                
                if let colorText = field.primitiveValue {
                    
                    return colorText
                }
                let colorText = "H: \(object.$hue.value * 359)˚, S: \(round(object.$saturation.value * 100.0))%, B: \(round(object.$brightness.value * 100.0))%"
                field.primitiveValue = colorText
                return colorText
            }
        )
        var colorText: String
        
        func setRandomHue() {
            
            self.hue = Self.randomHue()
        }
        
        
        // MARK: Private
        
        private static func resetVirtualProperties(_ object: ObjectProxy<Modern.ColorsDemo.Palette>) {

            object.$colorGroup.primitiveValue = nil
            object.$color.primitiveValue = nil
            object.$colorText.primitiveValue = nil
        }
        
        private static func randomHue() -> Float {
            
            return Float.random(in: 0.0 ... 1.0)
        }
        
        private static func randomSaturation() -> Float {
            
            return Float.random(in: 0.4 ... 1.0)
        }
        
        private static func randomBrightness() -> Float {
            
            return Float.random(in: 0.1 ... 0.9)
        }
    }
}
