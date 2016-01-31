//
//  UserAccount.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/05/24.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import Foundation
import CoreData


// MARK: - UserAccount

class UserAccount: NSManagedObject {
    
    @NSManaged var accountType: String?
    @NSManaged var name: String?
    @NSManaged var friends: Int32
}
