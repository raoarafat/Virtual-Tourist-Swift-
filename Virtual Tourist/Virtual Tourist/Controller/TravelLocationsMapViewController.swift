//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Arafat on 9/7/15.
//  Copyright (c) 2015 Arafat Khan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    var shouldPinRemove : Bool = false
    
    var pins = [Pin]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    let viewFramePoint : CGFloat = 50
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        /* Left Bar Button with image */
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style:.Plain, target: self, action: "Edit")
        
        mapView.delegate = self
        
        /* This sets up the long tap to drop the pin. */
        let longTap = UILongPressGestureRecognizer(target: self, action: "didLongTapMap:")
        longTap.delegate = self
        longTap.numberOfTapsRequired = 0
        longTap.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longTap)
        
        self.configureMap()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = ""
    }
    
    // MARK: - Helper
    
    func configureMap(){
        
        var error: NSError?
        do {
            // Perform the fetch
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        // Set the delegate to this view controller
        fetchedResultsController.delegate = self
        
        let sectionInfo = self.fetchedResultsController.sections![0] 
        
        for var i = 0; i < sectionInfo.numberOfObjects ; i++
        {
            let indexPath : NSIndexPath = NSIndexPath(forRow: i, inSection: 0)
            
            /* Here is how to replace the pin array using objectAtIndexPath */
            let pin = fetchedResultsController.objectAtIndexPath(indexPath) as! Pin
            
            let latitude  : Double = pin.latitude as Double
            let longitude : Double = pin.longitude as Double
            let coordinates = CLLocationCoordinate2D (latitude: latitude, longitude: longitude)
            self.addPinOnTheMap(coordinates: coordinates, pin: pin)
            
        }
        
    }
    
    func Edit(){
        
        dispatch_async(dispatch_get_main_queue(),{
            
            if  (self.navigationItem.rightBarButtonItem?.title == "Edit"){
                self.animateBottonView(-self.viewFramePoint)
                self.shouldPinRemove = true;
                self.navigationItem.rightBarButtonItem?.title = "Done"
            }else{
                
                self.animateBottonView(self.viewFramePoint)
                self.shouldPinRemove = false;
                self.navigationItem.rightBarButtonItem?.title = "Edit"
            }
            
        })
    }
    
    /* Aninate's bottom View */
    func animateBottonView(viewFramePoint : CGFloat){
        
        UIView.animateWithDuration(0.2, delay: 0, options: [], animations: {
            self.view.frame.origin.y =  self.view.frame.origin.y + viewFramePoint
            
            }, completion: {finished in
        })
    }
    
    func addPinOnTheMap (coordinates coordinates : CLLocationCoordinate2D, pin: Pin){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
        
        /* Add associated pin to annotation */
        annotation.pin = pin
        
    }
    
    func getPinCoordinates (coordinates coordinates : CLLocationCoordinate2D){
        
        // Now we create a new Pin, using the shared Context
        let pintoBeAdded = Pin(location: coordinates, context: sharedContext)
        self.addPinOnTheMap(coordinates: coordinates, pin: pintoBeAdded)
        
    }
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
     // MARK: UIStoryboardSegue methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        /* Check Segue identifier */
        if(segue.identifier == "PhotoAlbum"){
            
            self.title = "OK"
            
            let photo: PhotoAlbumViewController = segue.destinationViewController as! PhotoAlbumViewController
            photo.pin = sender as! Pin
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        // Create the fetch request
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        // Add a sort descriptor.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "longitude", ascending: false)]
        
        // Create the Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Return the fetched results controller. It will be the value of the lazy variable
        return fetchedResultsController
        } ()
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            updatedIndexPaths.append(indexPath!)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    
}
