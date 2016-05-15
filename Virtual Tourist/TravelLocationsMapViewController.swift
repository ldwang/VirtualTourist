//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Long Wang on 2016-04-17.
//  Copyright © 2016 Long Wang. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var bottomUIView: UIView!
    
    
    var isEditingPin : Bool = false
    
    var longPressGestrue = UILongPressGestureRecognizer()
    
    //var newPin : Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.'
        
        mapView.delegate = self
        
        self.longPressGestrue.minimumPressDuration = 1.0
        self.longPressGestrue.addTarget(self, action: #selector(self.addPin(_:)))
        mapView.addGestureRecognizer(longPressGestrue)
        
        restoreMapRegion()
        
        
        // Set the fetchedResultsController.delegate = self
        fetchedResultsController.delegate = self
        
        // Invoke fetchedResultsController.performFetch(nil) here
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        let pins = fetchedResultsController.fetchedObjects! as? [Pin]
        
        print(pins)
        
        for pin in pins! {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            mapView.addAnnotation(annotation)

        }
        //mapView.addAnnotations(fetchedResultsController.fetchedObjects as! [MKAnnotation])
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    
    // Add the lazy fetchedResultsController property. See the reference sheet in the lesson if you
    // want additional help creating this property.
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()



    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        
        let height = bottomUIView.frame.height

        if !isEditingPin {
            self.rightBarButtonItem.title = "Done"
            isEditingPin = true
            bottomUIView.alpha = 1
            mapView.frame.origin.y -= height
            
        } else {
            self.rightBarButtonItem.title = "Edit"
            isEditingPin = false
            bottomUIView.alpha = 0
            mapView.frame.origin.y += height
        }
    }
    
    func addPin(getstureRecognizer: UIGestureRecognizer) {
        let touchPoint = getstureRecognizer.locationInView(mapView)
        let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
        
        print(newCoordinates)

        _ = Pin(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude,  context: sharedContext)
        
            CoreDataStackManager.sharedInstance().saveContext()
        
    }
    
    //MARK: MapView delegate implementation
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
    
    //Mark: restore map region from NSUserDefaults Dictionary
    func restoreMapRegion() {
        
        if let mapRegionDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(VTDB.NSUserDefaultKey.MapRegionKey) {
            
            let region = MKCoordinateRegionMake(
                CLLocationCoordinate2DMake(
                    mapRegionDict["latitude"] as! Double,
                    mapRegionDict["longitude"] as! Double
                ),
                MKCoordinateSpanMake(
                    mapRegionDict["spanLatitude"] as! Double,
                    mapRegionDict["spanLongitude"] as! Double
                )
            )
            
            mapView.setRegion(region, animated: true)
        
        }
    }
    
    //Mark: save map region in NSUserDefaults Dictionary
    func saveMapRegion() {
        let region = mapView.region
        let mapRegiondict = [
            "latitude": region.center.latitude,
            "longitude": region.center.longitude,
            "spanLatitude": region.span.longitudeDelta,
            "spanLongitude": region.span.longitudeDelta
        ]
        
        NSUserDefaults.standardUserDefaults().setObject(mapRegiondict, forKey: VTDB.NSUserDefaultKey.MapRegionKey)
    }

}

