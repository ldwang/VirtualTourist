//
//  PhotoCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Daniel Wang on 2016-05-16.
//  Copyright © 2016 Long Wang. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class PhotoCollectionViewController: UIViewController, MKMapViewDelegate,  UICollectionViewDelegate, UICollectionViewDataSource,NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var bottomButtonItem: UIButton!
    
    var pin : Pin!
    
    var isRemovingImage : Bool = false
    var selectedImagesToRemove : [NSIndexPath] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.'
        
        mapView.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        
        // Set the fetchedResultsController.delegate = self
        fetchedResultsController.delegate = self
        
        if pin != nil {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            
            //Setup the region
            let span = MKCoordinateSpanMake(0.5, 0.5)
            let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            mapView.addAnnotation(annotation)
            
        }
        
        // Set the fetchedResultsController.delegate = self
        fetchedResultsController.delegate = self
        
        // Invoke fetchedResultsController.performFetch(nil) here
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
            }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if pin.photos!.isEmpty {
            getPhotos(pin)
        }
    }
    
    @IBAction func OKButtonTouch(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func BottomButtonTouch(sender: AnyObject) {
        
        //print("isRemovingImage" + isRemovingImage.description)
        
        if isRemovingImage {
            for index in selectedImagesToRemove {
                self.sharedContext.deleteObject(self.fetchedResultsController.objectAtIndexPath(index) as! NSManagedObject)
            }
            
            CoreDataStackManager.sharedInstance().saveContext()
            
            selectedImagesToRemove.removeAll()
            
            updateBottomButton()
            
            // Invoke fetchedResultsController.performFetch(nil) here
            do {
                try fetchedResultsController.performFetch()
            } catch {}
            
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView.reloadData()
            }

            
        } else {
            for photo in fetchedResultsController.fetchedObjects! {
                self.sharedContext.deleteObject(photo as! NSManagedObject)
            }
            
            
            CoreDataStackManager.sharedInstance().saveContext()
            
            
            //print("Print Fetched ResultsController Objects counts:")
            //print(fetchedResultsController.fetchedObjects)
            
            getPhotos(pin)
            
            
        }
    }
   
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    let moc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    
    
    // Add the lazy fetchedResultsController property. See the reference sheet in the lesson if you
    // want additional help creating this property.
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photoURL", ascending: true)]
        
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()

    
    //Get Photos Array from Flickr and Save to CoreData
    
    func getPhotos(pin: Pin) {
        
        VTDB.sharedInstance.getPhotosByPin(pin) { result, error in
            if let error = error {
                print(error)
        } else {
                if let photoArray = result as? [[String: AnyObject]] {
                    
                    //print(photoArray)
        
                    let _ = photoArray.map() { (dictionary: [String : AnyObject]) -> Photo in
                        let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                        photo.pin = self.pin
                        return photo
                    }
                }
                
                CoreDataStackManager.sharedInstance().saveContext()
                
                do {
                    try self.fetchedResultsController.performFetch()
                } catch {}

        
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView.reloadData()
                }
            }
        }

    }
    
    //MARK: Collection View
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo

        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Photo", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        configureCell(cell, photo: photo)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell!.alpha = 0.5
        self.selectedImagesToRemove.append(indexPath)
        updateBottomButton()
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell!.alpha = 1.0
        self.selectedImagesToRemove.removeAtIndex(selectedImagesToRemove.indexOf(indexPath)!)
        updateBottomButton()
    }
    
    // MARK: - Configure Cell
    func configureCell(cell: PhotoCollectionViewCell, photo: Photo) {
        
        var image = UIImage(named: "placeholder")
    
        cell.imageView!.image = nil
        
        //Set the Photo Image
        if photo.photoURL == nil || photo.photoURL == "" {
            image = UIImage(named: "noImage")
        } else if photo.image != nil {
            image = photo.image
        } else {
            
            cell.activityIndicator.hidden = false
            cell.activityIndicator.startAnimating()
            
            VTDB.sharedInstance.taskForGetImage(photo.photoURL!) { imageData, error in
                
                if let error = error {
                    print("Flickr Photo Download Error:\(error.localizedDescription)")
                }
                
                if let data=imageData {
                    //Create the image
                    
                    let downloadImage = UIImage(data: data)
                    
                    //Update the model, so that the information get cached
                    photo.image = downloadImage
                    
                    
                    //Update the cell later, on the main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.imageView!.image = downloadImage
                        cell.alpha = 1.0
                        cell.activityIndicator.stopAnimating()
                        cell.activityIndicator.hidden = true
                    }
                }
            }
            
            
        }
        
        cell.imageView!.image = image
        cell.alpha = 1.0
        
    }

    func updateBottomButton() {
        if selectedImagesToRemove.count > 0 {
            isRemovingImage = true
            bottomButtonItem.setTitle("Remove Selected Pictures", forState: UIControlState.Normal)
        } else {
            isRemovingImage = false
            bottomButtonItem.setTitle("New Collection", forState: UIControlState.Normal)
        }
        
    }
    
}
