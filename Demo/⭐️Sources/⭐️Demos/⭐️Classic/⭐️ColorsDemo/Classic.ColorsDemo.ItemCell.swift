//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import UIKit


// MARK: - Classic.ColorsDemo

extension Classic.ColorsDemo {

    // MARK: - Classic.ColorsDemo.ItemCell
    
    final class ItemCell: UITableViewCell {
        
        // MARK: Internal
        
        static let reuseIdentifier: String = NSStringFromClass(Classic.ColorsDemo.ItemCell.self)
        
        func setPalette(_ palette: Classic.ColorsDemo.Palette) {

            self.contentView.backgroundColor = palette.color
            self.textLabel?.text = palette.colorText
            self.textLabel?.textColor = palette.brightness > 0.6 ? .black : .white
        }
    }
}
