//
//  TransactionsDemoViewController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/05/24.
//  Copyright (c) 2015 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import AddressBookUI
import CoreStore
import GCDKit


private struct Static {
    
    static let placeController: ObjectMonitor<Place> = {
        
        try! CoreStore.addSQLiteStoreAndWait(
            fileName: "PlaceDemo.sqlite",
            configuration: "TransactionsDemo",
            resetStoreOnModelMismatch: true
        )
        
        var place = CoreStore.fetchOne(From(Place))
        if place == nil {
            
            CoreStore.beginSynchronous { (transaction) -> Void in
                
                let place = transaction.create(Into(Place))
                place.setInitialValues()
                
                transaction.commit()
            }
            place = CoreStore.fetchOne(From(Place))
        }
        
        return CoreStore.monitorObject(place!)
    }()
}


// MARK: - TransactionsDemoViewController

class TransactionsDemoViewController: UIViewController, MKMapViewDelegate, ObjectObserver {
    
    // MARK: NSObject
    
    deinit {
        
        Static.placeController.removeObserver(self)
    }
    
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")
        self.mapView?.addGestureRecognizer(longPressGesture)
        
        Static.placeController.addObserver(self)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Refresh,
            target: self,
            action: "refreshButtonTapped:"
        )
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let alert = UIAlertController(
            title: "Transactions Demo",
            message: "This demo shows how to use the 3 types of transactions to save updates: synchronous, asynchronous, and detached.\n\nTap and hold on the map to change the pin location.",
            preferredStyle: .Alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let mapView = self.mapView, let place = Static.placeController.object {
            
            mapView.addAnnotation(place)
            mapView.setCenterCoordinate(place.coordinate, animated: false)
            mapView.selectAnnotation(place, animated: false)
        }
    }
    
    
    // MARK: MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "MKAnnotationView"
        var annotationView: MKPinAnnotationView! = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
        if annotationView == nil {
            
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.enabled = true
            annotationView.canShowCallout = true
            annotationView.animatesDrop = true
        }
        else {
            
            annotationView.annotation = annotation
        }
        
        return annotationView
    }
    
    
    // MARK: ObjectObserver
    
    func objectMonitor(monitor: ObjectMonitor<Place>, willUpdateObject object: Place) {
        
        // none
    }
    
    func objectMonitor(monitor: ObjectMonitor<Place>, didUpdateObject object: Place, changedPersistentKeys: Set<KeyPath>) {
        
        if let mapView = self.mapView {
            
            mapView.removeAnnotations(mapView.annotations ?? [])
            mapView.addAnnotation(object)
            mapView.setCenterCoordinate(object.coordinate, animated: true)
            mapView.selectAnnotation(object, animated: true)
            
            if changedPersistentKeys.contains("latitude") || changedPersistentKeys.contains("longitude") {
                
                self.geocodePlace(object)
            }
        }
    }
    
    func objectMonitor(monitor: ObjectMonitor<Place>, didDeleteObject object: Place) {
        
        // none
    }

    
    // MARK: Private
    
    var geocoder: CLGeocoder?
    
    @IBOutlet weak var mapView: MKMapView?
    
    @IBAction dynamic func longPressGestureRecognized(sender: AnyObject?) {
        
        if let mapView = self.mapView, let gesture = sender as? UILongPressGestureRecognizer where gesture.state == .Began {
            
            let coordinate = mapView.convertPoint(
                gesture.locationInView(mapView),
                toCoordinateFromView: mapView
            )
            CoreStore.beginAsynchronous { (transaction) -> Void in
                
                let place = transaction.edit(Static.placeController.object)
                place?.coordinate = coordinate
                transaction.commit { (_) -> Void in }
            }
        }
    }
    
    @IBAction dynamic func refreshButtonTapped(sender: AnyObject?) {
        
        CoreStore.beginSynchronous { (transaction) -> Void in
            
            let place = transaction.edit(Static.placeController.object)
            place?.setInitialValues()
            transaction.commit()
        }
    }
    
    func geocodePlace(place: Place) {
        
        let transaction = CoreStore.beginDetached()
        
        self.geocoder?.cancelGeocode()
        
        let geocoder = CLGeocoder()
        self.geocoder = geocoder
        geocoder.reverseGeocodeLocation(
            CLLocation(latitude: place.latitude, longitude: place.longitude),
            completionHandler: { [weak self] (placemarks, error) -> Void in
                
                if let placemark = placemarks?.first, let addressDictionary = placemark.addressDictionary {
                    
                    let place = transaction.edit(Static.placeController.object)
                    place?.title = placemark.name
                    place?.subtitle = ABCreateStringWithAddressDictionary(addressDictionary, true)
                    transaction.commit { (_) -> Void in }
                }
                
                self?.geocoder = nil
            }
        )
    }
}
