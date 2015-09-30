//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Arafat on 9/9/15.
//  Copyright (c) 2015 Arafat Khan. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate,NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var emptyPhotoView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    let reuseIdentifier = "PhotoAlbumCell"
    
    // The selected indexes array keeps all of the indexPaths for cells that are "selected". The array is
    // used inside cellForItemAtIndexPath to lower the alpha of selected cells.  You can see how the array
    // works by searchign through the code for 'selectedIndexes'
    var selectedIndexes = [NSIndexPath]()
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    let removeSelectedPhotoTitle = "Remove Selected Photo"
    let NewCollectionPhotoTitle = "New Collection"
    
    
    var pin : Pin!
    
    var task : NSURLSessionDataTask!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        
        collectionView.allowsMultipleSelection = true;
        self.configureMap()
        
        var error: NSError?
        do {
            // Perform the fetch
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        // Set the delegate to this view controller
        fetchedResultsController.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.fetchFlickrPhotos()
    }
    
    
    // MARK: - Actions
    
    @IBAction func newCollectionPressed(sender: AnyObject) {
        
        /* Cancel previous task */
        task?.cancel()
        
        /* Remove photos */
        self.removePhotos()
    }
    
    
    // MARK: - Helper
    
    func fetchFlickrPhotos(){
        
        if pin.pictures.isEmpty{
            
            task = VTClient.sharedInstance().getImageFromFlickrByLatLong(pin.latitude as Double, longitude:pin.longitude as Double) { success, result, errorString in
                
                if success {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        if  result?.count <= 0 {
                            self.emptyPhotoView.hidden = false
                        }else{
                            self.emptyPhotoView.hidden = true
                        }
                        
                    })
                    
                    /* Parse the array of pictures dictionaries */
                    var pictures = result!.map() { (dictionary: [String : AnyObject]) -> Picture in
                        let picture = Picture(dictionary: dictionary, context: self.sharedContext)
                        
                        picture.pins = self.pin
                        return picture
                    }
                }
                
            }
        }
        
    }
    
    func configureMap(){
        
        dispatch_async(dispatch_get_main_queue(),{
            
            let coordinate : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.pin.latitude as Double, longitude: self.pin.longitude as Double)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            self.mapView.addAnnotation(annotation)
            
            /* Zoom in Pin */
            let location : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.pin.latitude as Double, longitude: self.pin.longitude as Double)
            var region : MKCoordinateRegion;
            region = MKCoordinateRegionMake(location, MKCoordinateSpanMake(1.5, 1.5));
            let adjustedRegion : MKCoordinateRegion = self.mapView.regionThatFits(region);
            self.mapView.setRegion(adjustedRegion, animated: true)
        })
    }
    
    func removePhotos() {
        if selectedIndexes.isEmpty {
            
            for picture in fetchedResultsController.fetchedObjects as! [Picture] {
                sharedContext.deleteObject(picture)
            }
            
            CoreDataStackManager.sharedInstance().saveContext()
            self.fetchFlickrPhotos()
            
        }
        else{
            for indexPath in selectedIndexes {
                let picture = fetchedResultsController.objectAtIndexPath(indexPath) as! Picture
                sharedContext.deleteObject(picture)
            }
            selectedIndexes = [NSIndexPath]()
            updateBottomButton()
            
        }
    }
    
    func updateBottomButton() {
        if selectedIndexes.count > 0{
            
            newCollectionBtn.setTitle(removeSelectedPhotoTitle, forState: UIControlState.Normal)
            
        }
        else{
            newCollectionBtn.setTitle(NewCollectionPhotoTitle, forState: UIControlState.Normal)
        }
    }
    
    // MARK: - Configure Cell
    
    func configureCell(cell: PhotoAlbumCell, picture: Picture) {
        
    
        if picture.imagePath == nil || picture.imagePath == "" {
            print("noimage")
        }
        else if picture.image != nil {
            dispatch_async(dispatch_get_main_queue()) {
                cell.indicatorView.hidden = true
                cell.photoImgView!.image = picture.image
            }
        }
        else {
            
            cell.indicatorView.hidden = false
            
            /* Start the task that will eventually download the image */
            let task = VTClient.sharedInstance().taskForImageWithSize("", filePath: picture.imagePath!) { data, error in
                
                if let error = error {
                    print("Poster download error: \(error.localizedDescription)")
                }
                
                if let data = data {
                    // Craete the image
                    let image = UIImage(data: data)
                    
                    // update the model, so that the information gets cached
                    picture.image = image
                    
                    // update the cell later, on the main thread
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.indicatorView.hidden = true
                        cell.photoImgView!.image = image
                    }
                }
            }
            
            /* This is the custom property on this cell. See TaskCancelingTableViewCell.swift for details. */
            cell.taskToCancelifCellIsReused = task
        }
        
        
    }
    

    
    // MARK: - UITableViewDelegate and UITableViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        let sectionInfo = self.fetchedResultsController.sections![section] 
        
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        // Configure the cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)  as! PhotoAlbumCell
        
        let picture = fetchedResultsController.objectAtIndexPath(indexPath) as! Picture
                
        // This is the new configureCell method
        configureCell(cell, picture: picture)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        
        dispatch_async(dispatch_get_main_queue(),{
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoAlbumCell
            cell.photoImgView.alpha = 0.5
            
            // Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
            self.selectedIndexes.append(indexPath)
            self.updateBottomButton()
        })
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath){
        
        dispatch_async(dispatch_get_main_queue(),{
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoAlbumCell
            cell.photoImgView.alpha = 1.0
            
            // Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
            if let index = self.selectedIndexes.indexOf(indexPath) {
                self.selectedIndexes.removeAtIndex(index)
                self.updateBottomButton()
            }
        })
        
    }
    
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    
    // Mark: - Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Picture")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pins == %@", self.pin);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()
    
    // MARK: - Fetched Results Controller Delegate
    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
    // three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        print("in controllerWillChangeContent")
    }
    
    // The second method may be called multiple times, once for each Color object that is added, deleted, or changed.
    // We store the incex paths into the three arrays.
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            print("Insert an item")
            // Here we are noting that a new Color instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            print("Delete an item")
            // Here we are noting that a Color instance has been deleted from Core Data. We keep remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            print("Update an item.")
            // We don't expect Color instances to change after they are created. But Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an images is downloaded from
            // Flickr in the Virtual Tourist app
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            print("Move an item. We don't expect to see this in this app.")
            break
        default:
            break
        }
    }
    
    // This method is invoked after all of the changed in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
    
}
