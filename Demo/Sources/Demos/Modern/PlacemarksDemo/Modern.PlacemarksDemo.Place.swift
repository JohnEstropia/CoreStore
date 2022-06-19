//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import struct CoreLocation.CLLocationCoordinate2D
import protocol MapKit.MKAnnotation

// MARK: - Modern.PlacemarksDemo

extension Modern.PlacemarksDemo {

    // MARK: - Modern.PlacemarksDemo.Place
    
    final class Place: CoreStoreObject {
        
        // MARK: Internal
        
        @Field.Stored("latitude")
        var latitude: Double = 0

        @Field.Stored("longitude")
        var longitude: Double = 0
        
        @Field.Stored("title")
        var title: String?
        
        @Field.Stored("subtitle")
        var subtitle: String?
        
        @Field.Virtual(
            "annotation",
            customGetter: { object, field in
                
                Modern.PlacemarksDemo.Place.Annotation(object)
            },
            customSetter: { object, field, newValue in
                
                object.$latitude.value = newValue.coordinate.latitude
                object.$longitude.value = newValue.coordinate.longitude
                object.$title.value = "\(newValue.coordinate.latitude), \(newValue.coordinate.longitude)"
                object.$subtitle.value = nil
            }
        )
        var annotation: Modern.PlacemarksDemo.Place.Annotation
        
        func setRandomLocation() {
            
            self.latitude = Double(arc4random_uniform(180)) - 90
            self.longitude = Double(arc4random_uniform(360)) - 180
            self.title = "\(self.latitude), \(self.longitude)"
            self.subtitle = nil
        }
        
        // MARK: - Modern.PlacemarksDemo.Place.Annotation
        
        final class Annotation: NSObject, MKAnnotation {
            
            // MARK: Internal
            
            init(coordinate: CLLocationCoordinate2D) {
                
                self.coordinate = coordinate
                self.title = nil
                self.subtitle = nil
            }
            
            
            // MARK: MKAnnotation

            let coordinate: CLLocationCoordinate2D
            let title: String?
            let subtitle: String?
            
            
            // MARK: NSObjectProtocol
            
            override func isEqual(_ object: Any?) -> Bool {
                
                guard case let object as Annotation = object else {
                    
                    return false
                }
                return self.coordinate.latitude == object.coordinate.latitude
                    && self.coordinate.longitude == object.coordinate.longitude
                    && self.title == object.title
                    && self.subtitle == object.subtitle
            }
            
            override var hash: Int {
                
                var hasher = Hasher()
                hasher.combine(self.coordinate.latitude)
                hasher.combine(self.coordinate.longitude)
                hasher.combine(self.title)
                hasher.combine(self.subtitle)
                return hasher.finalize()
            }
            
            
            // MARK: FilePrivate
            
            fileprivate init(
                latitude: Double,
                longitude: Double,
                title: String?,
                subtitle: String?
            ) {
                self.coordinate = .init(latitude: latitude, longitude: longitude)
                self.title = title
                self.subtitle = subtitle
            }
            
            fileprivate init(_ object: ObjectProxy<Modern.PlacemarksDemo.Place>) {
                
                self.coordinate = .init(
                    latitude: object.$latitude.value,
                    longitude: object.$longitude.value
                )
                self.title = object.$title.value
                self.subtitle = object.$subtitle.value
            }
        }
    }
}
