//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import UIKit


// MARK: - Modern.ColorsDemo.UIKit

extension Modern.ColorsDemo.UIKit {

    // MARK: - Modern.ColorsDemo.UIKit.ItemCell
    
    final class ItemCell: UITableViewCell {
        
        // MARK: Internal
        
        static let reuseIdentifier: String = NSStringFromClass(Modern.ColorsDemo.UIKit.ItemCell.self)
        
        func setPalette(_ palette: Modern.ColorsDemo.Palette) {

            self.contentView.backgroundColor = palette.color
            self.textLabel?.text = palette.colorText
            self.textLabel?.textColor = palette.brightness > 0.6 ? .black : .white
        }
    }
}
