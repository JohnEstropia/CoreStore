//
//  Palette.swift
//  HardcoreDataDemo
//
//  Created by John Rommel Estropia on 2015/05/05.
//  Copyright (c) 2015 John Rommel Estropia. All rights reserved.
//

import Foundation
import CoreData

class Palette: NSManagedObject {

    @NSManaged var dateAdded: NSDate
    @NSManaged var hue: Int32
    @NSManaged var saturation: Float
    @NSManaged var brightness: Float
    
    @objc dynamic var colorName: String {
        
        get {
            
            let key = "colorName"
            self.willAccessValueForKey(key)
            let value: AnyObject? = self.primitiveValueForKey(key)
            self.didAccessValueForKey(key)
            
            if let colorName = value as? String {
                
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
            
            self.setPrimitiveValue(colorName, forKey: key)
            return colorName
        }
        set {
            
            let key = "colorName"
            self.willChangeValueForKey(key)
            self.setPrimitiveValue(newValue, forKey: key)
            self.didChangeValueForKey(key)
        }
    }
}
