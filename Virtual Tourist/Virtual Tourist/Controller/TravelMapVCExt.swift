//
//  TravelMapVCExt.swift
//  Virtual Tourist
//
//  Created by Arafat on 9/7/15.
//  Copyright (c) 2015 Arafat Khan. All rights reserved.
//

import Foundation
import MapKit

extension TravelLocationsMapViewController : MKMapViewDelegate {
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView){
        
        /* get associated pin */
        let pin = (view.annotation as! MKPointAnnotation).pin
        
        if(shouldPinRemove){
            self.mapView.removeAnnotation(view.annotation!)
            
            sharedContext.deleteObject(pin)
            //CoreDataStackManager.sharedInstance().saveContext()
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), {
                
                /* perform segue with identifier */
                self.performSegueWithIdentifier("PhotoAlbum", sender:pin)
                self.mapView.deselectAnnotation(view.annotation, animated: false)
            })
        }
    }
    
    
    func didLongTapMap(gestureRecognizer: UIGestureRecognizer) {
        
        // Get the spot that was tapped.
        
        if(!shouldPinRemove){
            let tapPoint: CGPoint = gestureRecognizer.locationInView(mapView)
            let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
            
            if .Ended == gestureRecognizer.state {
                self.getPinCoordinates(coordinates: touchMapCoordinate)
                return;
            }
            
        }
    }
    
    func mapView(mapView: MKMapView,viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView!
    {
        // 1
        if let student = annotation as? MKPointAnnotation {
            // 2
            var view = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as! MKPinAnnotationView!
            if view == nil {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                view.canShowCallout = false
                view.animatesDrop = true
            }
            else
            {
                // 4
                view.annotation = annotation
            }
            // 5
            
            return view
        }
        return nil
        
    }
    
}

// MARK: Property extension

private var associationKey: UInt8 = 0

extension MKPointAnnotation {
    var pin: Pin! {
        get {
            return objc_getAssociatedObject(self, &associationKey) as! Pin
        }
        set(newValue) {
            objc_setAssociatedObject(self, &associationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
}
}
