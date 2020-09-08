//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreData
import UIKit


// MARK: - Classic.ColorsDemo.Palette

@objc(Classic_ColorsDemo_Palette)
final class Classic_ColorsDemo_Palette: NSManagedObject {
    
    // MARK: Internal
    
    @NSManaged
    dynamic var hue: Float
    
    @NSManaged
    dynamic var saturation: Float
    
    @NSManaged
    dynamic var brightness: Float
    
    @objc
    dynamic var colorGroup: String! {
        
        let key = #keyPath(colorGroup)
        if case let value as String = self.getValue(forKvcKey: key) {
            
            return value
        }
        let newValue: String
        switch self.hue * 359 {
            
        case 0 ..< 20: newValue = "Lower Reds"
        case 20 ..< 57: newValue = "Oranges and Browns"
        case 57 ..< 90: newValue = "Yellow-Greens"
        case 90 ..< 159: newValue = "Greens"
        case 159 ..< 197: newValue = "Blue-Greens"
        case 197 ..< 241: newValue = "Blues"
        case 241 ..< 297: newValue = "Violets"
        case 297 ..< 331: newValue = "Magentas"
        default: newValue = "Upper Reds"
        }
        self.setPrimitiveValue(newValue, forKey: key)
        return newValue
    }
    
    var color: UIColor {
        
        let newValue = UIColor(
            hue: CGFloat(self.hue),
            saturation: CGFloat(self.saturation),
            brightness: CGFloat(self.brightness),
            alpha: 1.0
        )
        return newValue
    }
    
    var colorText: String {
        
        let newValue: String = "H: \(self.hue * 359)˚, S: \(round(self.saturation * 100.0))%, B: \(round(self.brightness * 100.0))%"
        return newValue
    }
    
    func setRandomHue() {
        
        self.hue = Self.randomHue()
    }
    
    
    // MARK: NSManagedObject
    
    public override func awakeFromInsert() {
        
        super.awakeFromInsert()
        
        self.hue = Self.randomHue()
        self.saturation = Self.randomSaturation()
        self.brightness = Self.randomBrightness()
    }
    
    
    // MARK: Private
    
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
