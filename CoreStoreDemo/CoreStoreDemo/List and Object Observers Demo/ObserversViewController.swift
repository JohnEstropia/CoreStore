//
//  ObserversViewController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/05/24.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import UIKit


// MARK: - ObserversViewController

class ObserversViewController: UIViewController {
    
    // MARK: UIViewController
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let alert = UIAlertController(
            title: "Observers Demo",
            message: "This demo shows how to observe changes to a list of objects. The top and bottom view controllers both observe a single shared \"ListMonitor\" instance.\n\nTap on a row to see how to observe changes made to a single object using a \"ObjectMonitor\".",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
