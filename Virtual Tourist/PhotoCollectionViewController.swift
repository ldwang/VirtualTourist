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
    
    var photoURLArray : [String] = []
    
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
                    print(result)
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Photo", forIndexPath: indexPath)
        
        //configureCell(cell)
        
        return cell
    }

}
