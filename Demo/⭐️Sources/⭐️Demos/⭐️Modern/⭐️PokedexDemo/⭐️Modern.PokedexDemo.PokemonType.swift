//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import UIKit

// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {

    // MARK: - Modern.PokedexDemo.PokemonType
    
    /**
     ⭐️ Sample 1: Types that will be used with `@Field.Stored` need to implement both `ImportableAttributeType` and `FieldStorableType`. In this case, `RawRepresentable` types with primitive `RawValue`s have built-in implementations so we only have to declare conformance to `ImportableAttributeType` and `FieldStorableType`.
     */
    enum PokemonType: String, CaseIterable, ImportableAttributeType, FieldStorableType {
        
        // MARK: Internal
        
        case bug
        case dark
        case dragon
        case electric
        case fairy
        case fighting
        case fire
        case flying
        case ghost
        case grass
        case ground
        case ice
        case normal
        case poison
        case psychic
        case rock
        case steel
        case water
        
        var color: UIColor {
            
            switch self {
                
            case .bug:      return #colorLiteral(red: 0.568627450980392, green: 0.749019607843137, blue: 0.231372549019608, alpha: 1.0) // #91BF3B, a: 1.0
            case .dark:     return #colorLiteral(red: 0.392156862745098, green: 0.388235294117647, blue: 0.454901960784314, alpha: 1.0) // #646374, a: 1.0
            case .dragon:   return #colorLiteral(red: 0.0823529411764706, green: 0.423529411764706, blue: 0.741176470588235, alpha: 1.0) // #156CBD, a: 1.0
            case .electric: return #colorLiteral(red: 0.949019607843137, green: 0.819607843137255, blue: 0.298039215686275, alpha: 1.0) // #F2D14C, a: 1.0
            case .fairy:    return #colorLiteral(red: 0.913725490196078, green: 0.56078431372549, blue: 0.882352941176471, alpha: 1.0) // #E98FE1, a: 1.0
            case .fighting: return #colorLiteral(red: 0.8, green: 0.254901960784314, blue: 0.423529411764706, alpha: 1.0) // #CC416C, a: 1.0
            case .fire:     return #colorLiteral(red: 0.992156862745098, green: 0.607843137254902, blue: 0.352941176470588, alpha: 1.0) // #FD9B5A, a: 1.0
            case .flying:   return #colorLiteral(red: 0.619607843137255, green: 0.701960784313725, blue: 0.886274509803922, alpha: 1.0) // #9EB3E2, a: 1.0
            case .ghost:    return #colorLiteral(red: 0.333333333333333, green: 0.419607843137255, blue: 0.670588235294118, alpha: 1.0) // #556BAB, a: 1.0
            case .grass:    return #colorLiteral(red: 0.38823529411764707, green: 0.7215686274509804, blue: 0.3803921568627451, alpha: 1.0) // #63B861, a: 1.0
            case .ground:   return #colorLiteral(red: 0.847058823529412, green: 0.458823529411765, blue: 0.298039215686275, alpha: 1.0) // #D8754C, a: 1.0
            case .ice:      return #colorLiteral(red: 0.466666666666667, green: 0.803921568627451, blue: 0.756862745098039, alpha: 1.0) // #77CDC1, a: 1.0
            case .normal:   return #colorLiteral(red: 0.564705882352941, green: 0.603921568627451, blue: 0.627450980392157, alpha: 1.0) // #909AA0, a: 1.0
            case .poison:   return #colorLiteral(red: 0.647058823529412, green: 0.411764705882353, blue: 0.768627450980392, alpha: 1.0) // #A569C4, a: 1.0
            case .psychic:  return #colorLiteral(red: 0.9764705882, green: 0.5058823529, blue: 0.5019607843, alpha: 1) // #F98180, a: 1.0
            case .rock:     return #colorLiteral(red: 0.776470588235294, green: 0.717647058823529, blue: 0.556862745098039, alpha: 1.0) // #C6B78E, a: 1.0
            case .steel:    return #colorLiteral(red: 0.329411764705882, green: 0.529411764705882, blue: 0.607843137254902, alpha: 1.0) // #54879B, a: 1.0
            case .water:    return #colorLiteral(red: 0.325490196078431, green: 0.576470588235294, blue: 0.823529411764706, alpha: 1.0) // #5393D2, a: 1.0
            }
        }
    }
}
