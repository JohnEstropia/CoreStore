//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreLocation
import CoreStore
import MapKit
import UIKit
import SwiftUI

// MARK: - Modern.PlacemarksDemo

extension Modern.PlacemarksDemo {
    
    // MARK: - Modern.PlacemarksDemo.MapView
    
    struct MapView: UIViewRepresentable {
        
        // MARK: Internal

        var place: ObjectSnapshot<Modern.PlacemarksDemo.Place>?
        
        let onTap: (CLLocationCoordinate2D) -> Void
        
        // MARK: UIViewRepresentable
        
        typealias UIViewType = MKMapView
        
        func makeUIView(context: Context) -> UIViewType {
            
            let coordinator = context.coordinator
            
            let mapView = MKMapView()
            mapView.delegate = coordinator
            mapView.addGestureRecognizer(
                UITapGestureRecognizer(
                    target: coordinator,
                    action: #selector(coordinator.tapGestureRecognized(_:))
                )
            )
            return mapView
        }

        func updateUIView(_ view: UIViewType, context: Context) {
            
            let currentAnnotations = view.annotations
            view.removeAnnotations(currentAnnotations)
            
            guard let newAnnotation = self.place?.$annotation else {
                
                return
            }
            view.addAnnotation(newAnnotation)
            view.setCenter(newAnnotation.coordinate, animated: true)
            view.selectAnnotation(newAnnotation, animated: true)
        }

        func makeCoordinator() -> Coordinator {
            
            Coordinator(self)
        }

        final class Coordinator: NSObject, MKMapViewDelegate {
            
            // MARK: Internal
            
            init(_ parent: MapView) {
                
                self.parent = parent
            }
            
            // MARK: MKMapViewDelegate
            
            @objc dynamic func mapView(
                _ mapView: MKMapView,
                viewFor annotation: MKAnnotation
            ) -> MKAnnotationView? {
                
                let identifier = "MKAnnotationView"
                var annotationView: MKPinAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
                if annotationView == nil {
                    
                    annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    annotationView.isEnabled = true
                    annotationView.canShowCallout = true
                    annotationView.animatesDrop = true
                }
                else {
                    
                    annotationView.annotation = annotation
                }
                return annotationView
            }
            
            // MARK: FilePrivate
            
            @objc
            fileprivate dynamic func tapGestureRecognized(_ gesture: UILongPressGestureRecognizer) {
                
                guard
                    case let mapView as MKMapView = gesture.view,
                    gesture.state == .recognized
                else {
                    
                    return
                }
                let coordinate = mapView.convert(
                    gesture.location(in: mapView),
                    toCoordinateFrom: mapView
                )
                self.parent.onTap(coordinate)
            }
            
            // MARK: Private
            
            private var parent: MapView
        }
    }
}
