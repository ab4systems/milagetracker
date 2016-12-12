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

class LocationViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    fileprivate var locations = [MKPointAnnotation]()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.activityType = .automotiveNavigation
        manager.headingFilter = 60
        manager.headingOrientation = .unknown
        return manager
    }()
    
    @IBAction func enabledChanged(_ sender: UISwitch) {
        if sender.isOn {
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.startUpdatingHeading()
        } else {
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.stopUpdatingHeading()
        }
    }
    
    @IBAction func showRoute(_ sender: UIButton) {
        if (locations.count > 1){
            for index in 0...locations.count-2{
                let request: MKDirectionsRequest = MKDirectionsRequest()
                let c1 = locations[index].coordinate
                let c2 = locations[index + 1].coordinate
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: c1))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: c2))
                request.requestsAlternateRoutes = true
                request.transportType = .automobile
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
    
    
    @IBAction func accuracyChanged(_ sender: UISegmentedControl) {
        let accuracyValues = [
            kCLLocationAccuracyBestForNavigation,
            kCLLocationAccuracyBest,
            kCLLocationAccuracyNearestTenMeters,
            kCLLocationAccuracyHundredMeters,
            kCLLocationAccuracyKilometer,
            kCLLocationAccuracyThreeKilometers]
        
        locationManager.desiredAccuracy = accuracyValues[sender.selectedSegmentIndex];
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
}


extension LocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        
        let spanX = 0.007
        let spanY = 0.007
        let newRegion = MKCoordinateRegion(center: mostRecentLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        mapView.setRegion(newRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = mostRecentLocation.coordinate
        self.locations.append(annotation)
        print("\(mostRecentLocation.speed*3.6)")
        if UIApplication.shared.applicationState == .active {
            mapView.showAnnotations(self.locations, animated: true)
        } else {
            print("App is backgrounded. New location is %@", mostRecentLocation)
        }
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
