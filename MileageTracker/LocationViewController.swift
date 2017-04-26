//
//  ViewController.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 01/12/2016.
//  Copyright © 2016 Vlad Alexandru. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import UserNotifications
import Parse

class LocationViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    fileprivate var locations = [MKPointAnnotation]()
    
    @IBAction func showRoute(_ sender: UIButton) {
        if (locations.count > 1){
            for index in 0...locations.count-2{
                let request: MKDirectionsRequest = MKDirectionsRequest()
                let c1 = locations[index].coordinate
                let c2 = locations[index + 1].coordinate
                if #available(iOS 10.0, *) {
                    request.source = MKMapItem(placemark: MKPlacemark(coordinate: c1))
                    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: c2))
                } else {
                    // Fallback on earlier versions
                }
                request.requestsAlternateRoutes = true
                request.transportType = .walking
                let directions = MKDirections(request: request)
                
                directions.calculate (completionHandler: {
                    (response: MKDirectionsResponse?, error: Error?) in
                    if (response?.routes) != nil {
                        var routeResponse = response?.routes
                        
                        routeResponse = routeResponse!.sorted(by: {$0.expectedTravelTime < $1.expectedTravelTime})
                        
                        self.mapView.add((routeResponse?[0].polyline)!)
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                    
                })
                
            }
        }
        
    }
    
    
    @IBAction func showLocations(_ sender: Any) {
        let query = Trip.query()
        query?.fromLocalDatastore()
        query?.whereKey("current", equalTo: true)
        query?.getFirstObjectInBackground(block: {(object, error) in
        
//        Location.query()?.getObjectInBackground(withId: "22iqxijnE7", block: { (location, error) in
//            print(location as! Location)
//        })
            Location.queryOfflineFor(trip: object as! Trip)?.findObjectsInBackground(block: { (objects, error) in
                
                for location in objects as! [Location]{
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                    self.locations.append(annotation)
                }
                self.mapView.showAnnotations(self.locations, animated: true)
            })
        })
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    @IBAction func changeAngle(_ sender: UISlider) {
        
        label.text = String(Int(sender.value))
        LocationManager.mainInstance.headingFilter = CLLocationDegrees(Int(sender.value))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        slider.value = Float(LocationManager.mainInstance.headingFilter)
        label.text = String(slider.value)

    }
}

extension LocationViewController : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.red
        polylineRenderer.lineWidth = 4
        return polylineRenderer
    }
    
}



