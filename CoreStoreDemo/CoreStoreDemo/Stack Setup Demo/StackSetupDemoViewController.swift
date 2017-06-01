//
//  StackSetupDemoViewController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/05/24.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreStore


private struct Static {
    
    static let maleConfiguration = "MaleAccounts"
    static let femaleConfiguration = "FemaleAccounts"
    
    static let facebookStack: DataStack = {
        
        let dataStack = DataStack(xcodeModelName: "StackSetupDemo")
        try! dataStack.addStorageAndWait(
            SQLiteStore(
                fileName: "AccountsDemo_FB_Male.sqlite",
                configuration: maleConfiguration,
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        )
        try! dataStack.addStorageAndWait(
            SQLiteStore(
                fileName: "AccountsDemo_FB_Female.sqlite",
                configuration: femaleConfiguration,
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        )
        
        _ = try? dataStack.perform(
            synchronous: { (transaction) in
                
                transaction.deleteAll(From<UserAccount>())
                
                let account1 = transaction.create(Into<MaleAccount>(maleConfiguration))
                account1.accountType = "Facebook"
                account1.name = "John Smith HCD"
                account1.friends = 42
                
                let account2 = transaction.create(Into<FemaleAccount>(femaleConfiguration))
                account2.accountType = "Facebook"
                account2.name = "Jane Doe HCD"
                account2.friends = 314
            }
        )
        
        return dataStack
    }()
    
    static let twitterStack: DataStack = {
        
        let dataStack = DataStack(xcodeModelName: "StackSetupDemo")
        try! dataStack.addStorageAndWait(
            SQLiteStore(
                fileName: "AccountsDemo_TW_Male.sqlite",
                configuration: maleConfiguration,
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        )
        try! dataStack.addStorageAndWait(
            SQLiteStore(
                fileName: "AccountsDemo_TW_Female.sqlite",
                configuration: femaleConfiguration,
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        )
        
        _ = try? dataStack.perform(
            synchronous: { (transaction) in
                
                transaction.deleteAll(From<UserAccount>())
                
                let account1 = transaction.create(Into<MaleAccount>(maleConfiguration))
                account1.accountType = "Twitter"
                account1.name = "#johnsmith_hcd"
                account1.friends = 7
                
                let account2 = transaction.create(Into<FemaleAccount>(femaleConfiguration))
                account2.accountType = "Twitter"
                account2.name = "#janedoe_hcd"
                account2.friends = 100
            }
        )
        return dataStack
    }()
}




// MARK: - StackSetupDemoViewController

class StackSetupDemoViewController: UITableViewController {
    
    let accounts = [
        Static.facebookStack.fetchAll(From(UserAccount.self)) ?? [],
        Static.twitterStack.fetchAll(From(UserAccount.self)) ?? []
    ]
    
    
    // MARK: UIViewController
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
        
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        self.updateDetails(account: self.accounts[indexPath.section][indexPath.row])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let alert = UIAlertController(
            title: "Setup Demo",
            message: "This demo shows how to initialize 2 DataStacks with 2 configurations each, for a total of 4 SQLite files, each with 1 instance of a \"UserAccount\" entity.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.accounts.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.accounts[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
        
        let account = self.accounts[indexPath.section][indexPath.row]
        cell.textLabel?.text = account.name
        cell.detailTextLabel?.text = "\(account.friends) friends"
        
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let account = self.accounts[indexPath.section][indexPath.row]
        self.updateDetails(account: account)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            
        case 0:
            let count = self.accounts[section].count
            return "Facebook Accounts (\(count) users)"
            
        case 1:
            let count = self.accounts[section].count
            return "Twitter Accounts (\(count) users)"
            
        default:
            return nil
        }
    }
    
    
    // MARK: Private
    
    @IBOutlet private dynamic weak var accountTypeLabel: UILabel?
    @IBOutlet private dynamic weak var nameLabel: UILabel?
    @IBOutlet private dynamic weak var friendsLabel: UILabel?
    
    private func updateDetails(account: UserAccount) {
        
        self.accountTypeLabel?.text = account.accountType
        self.nameLabel?.text = account.name
        self.friendsLabel?.text = "\(account.friends) friends"
    }
}
