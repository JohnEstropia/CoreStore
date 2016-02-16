//
//  Place.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/05/24.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import Foundation
import CoreData
import MapKit


// MARK: - Place

class Place: NSManagedObject, MKAnnotation {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var title: String?
    @NSManaged var subtitle: String?
    
    func setInitialValues() {
        
        self.latitude = Double(arc4random_uniform(180)) - 90
        self.longitude = Double(arc4random_uniform(360)) - 180
        self.title = "\(self.latitude), \(self.longitude)"
        self.subtitle = nil
    }
    
    // MARK: MKAnnotation
    
    var coordinate: CLLocationCoordinate2D {
    
        get {
            
            return CLLocationCoordinate2DMake(
                self.latitude,
                self.longitude
            )
        }
        set {
            
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
            self.title = "\(self.latitude), \(self.longitude)"
            self.subtitle = nil
        }
    }
}
