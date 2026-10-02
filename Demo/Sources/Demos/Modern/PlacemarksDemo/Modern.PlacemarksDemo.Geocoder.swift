//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import Contacts
import CoreLocation
import CoreStore


// MARK: - Modern.PlacemarksDemo

extension Modern.PlacemarksDemo {
    
    // MARK: Geocoder
    
    @MainActor
    final class Geocoder {
        
        // MARK: Internal
        
        func geocode(
            place: ObjectSnapshot<Modern.PlacemarksDemo.Place>
        ) async -> (title: String?, subtitle: String?) {
            
            self.geocoder?.cancelGeocode()
            
            let geocoder = CLGeocoder()
            self.geocoder = geocoder
            
            defer {
                
                if self.geocoder === geocoder {
                    self.geocoder = nil
                }
            }
            
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(
                    CLLocation(latitude: place.$latitude, longitude: place.$longitude)
                )
                guard let placemark = placemarks.first else {
                    
                    return (nil, nil)
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
                
                return (
                    placemark.name,
                    CNPostalAddressFormatter.string(
                        from: address,
                        style: .mailingAddress
                    )
                )
            }
            catch {
                
                return (nil, nil)
            }
        }
        
        // MARK: Private
        
        private var geocoder: CLGeocoder?
    }
}
