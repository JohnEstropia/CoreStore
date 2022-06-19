//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import Contacts
import CoreLocation
import CoreStore


// MARK: - Modern.PlacemarksDemo

extension Modern.PlacemarksDemo {
    
    // MARK: Geocoder
    
    final class Geocoder {
        
        // MARK: Internal
        
        func geocode(
            place: ObjectSnapshot<Modern.PlacemarksDemo.Place>,
            completion: @escaping (_ title: String?, _ subtitle: String?) -> Void
        ) {
            
            self.geocoder?.cancelGeocode()
            
            let geocoder = CLGeocoder()
            self.geocoder = geocoder
            geocoder.reverseGeocodeLocation(
                CLLocation(latitude: place.$latitude, longitude: place.$longitude),
                completionHandler: { (placemarks, error) -> Void in
                    
                    defer {
                        
                        self.geocoder = nil
                    }
                    guard let placemark = placemarks?.first else {
                        
                        return
                    }

                    let address = CNMutablePostalAddress()
                    address.street = placemark.thoroughfare ?? ""
                    address.subLocality = placemark.subThoroughfare ?? ""
                    address.city = placemark.locality ?? ""
                    address.subAdministrativeArea = placemark.subAdministrativeArea ?? ""
                    address.state = placemark.administrativeArea ?? ""
                    address.postalCode = placemark.postalCode ?? ""
                    address.country = placemark.country ?? ""
                    address.isoCountryCode = placemark.isoCountryCode ?? ""
                    
                    completion(
                        placemark.name,
                        CNPostalAddressFormatter.string(
                            from: address,
                            style: .mailingAddress
                        )
                    )
                }
            )
        }
        
        // MARK: Private
        
        private var geocoder: CLGeocoder?
    }
}
