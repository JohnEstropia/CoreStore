//
//  ObserversViewController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/05/24.
//  Copyright © 2018 John Rommel Estropia. All rights reserved.
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
    
    
    // MARK: Private

    @IBOutlet private dynamic weak var toggleTopBarButtonItem: UIBarButtonItem?
    @IBOutlet private dynamic weak var toggleBottomBarButtonItem: UIBarButtonItem?
    @IBOutlet private dynamic weak var stackView: UIStackView?
    @IBOutlet private dynamic weak var topContainerView: UIView?
    @IBOutlet private dynamic weak var bottomContainerView: UIView?
    
    @IBAction private dynamic func toggleTopContainerView() {

        UIView.animate(withDuration: 0.2) {

            self.topContainerView!.isHidden.toggle()
        }
        self.toggleTopBarButtonItem!.isEnabled = !self.bottomContainerView!.isHidden
        self.toggleBottomBarButtonItem!.isEnabled = !self.topContainerView!.isHidden
    }
    
    @IBAction private dynamic func toggleBottomContainerView() {

        UIView.animate(withDuration: 0.2) {

            self.bottomContainerView!.isHidden.toggle()
        }
        self.toggleTopBarButtonItem!.isEnabled = !self.bottomContainerView!.isHidden
        self.toggleBottomBarButtonItem!.isEnabled = !self.topContainerView!.isHidden
    }
}
