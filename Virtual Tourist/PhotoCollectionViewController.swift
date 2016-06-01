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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.'
        
        mapView.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
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
            VTDB.sharedInstance().getPhotosByPin(pin) { result, error in
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
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.collectionView.reloadData()
                    }
                    
                }
            }
        }
    }
    
    @IBAction func OKButtonTouch(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    
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
    
    
    // MARK: - Configure Cell
    func configureCell(cell: PhotoCollectionViewCell, photo: Photo) {
        
        var image = UIImage(named: "PhotoPlaceHolder")
    
        cell.imageView!.image = nil
        
        //Set the Photo Image
        if photo.photoURL == nil || photo.photoURL == "" {
            image = UIImage(named: "noImage")
        } else if photo.image != nil {
            image = photo.image
        } else {
            VTDB.sharedInstance().taskForGetImage(photo.photoURL!) { imageData, error in
                
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
                    }
                }
            }
            
            
        }
        
        cell.imageView!.image = image
        
    }

}
