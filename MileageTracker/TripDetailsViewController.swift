//
//  TripDetailsViewController.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 24/04/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import UIKit
import MapKit

class TripDetailsViewController: UIViewController, MKMapViewDelegate {

    var trip: Trip!
    var annotations = [Pin]()
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        placeLocationPins()
        showTripDetails()
    }
    
    @IBAction func route(_ sender: Any) {
        if (annotations.count > 1){
            for index in 0...annotations.count-2{
                let request: MKDirectionsRequest = MKDirectionsRequest()
                let c1 = annotations[index].coordinate
                let c2 = annotations[index + 1].coordinate
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: c1))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: c2))
                request.requestsAlternateRoutes = true
                request.transportType = .automobile
                let directions = MKDirections(request: request)
                
                directions.calculate (completionHandler: {
                    (response: MKDirectionsResponse?, error: Error?) in
                    if (response?.routes) != nil {
                        var routeResponse = response?.routes
                        
                        routeResponse = routeResponse!.sorted(by: {$0.distance < $1.distance})
                        
                        if (routeResponse?[0].distance)! < Double(400){
                            self.mapView.add((routeResponse?[0].polyline)!)
                        }else{
                            let line = MKGeodesicPolyline(coordinates: [c1,c2], count: 2)
                            self.mapView.add(line)
                        }
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                    
                })
                
            }
        }

    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Pin {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
            }
            switch annotation {
            case annotations.first!:
                view.pinTintColor = MKPinAnnotationView.greenPinColor()
                break
            case annotations.last!:
                view.pinTintColor = MKPinAnnotationView.redPinColor()
                break
            default:
                view.pinTintColor =  MyColors.mainColor
            }
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.red
        polylineRenderer.lineWidth = 4
        return polylineRenderer
    }

    
    func showTripDetails(){
        durationLabel.text = trip.endTime.timeIntervalSince(trip.startTime).toHoursMinutesString()
        speedLabel.text = "\(trip.averageSpeed.roundTo(places: 2)) Km/h"
        distanceLabel.text = "\((trip.distance/1000).roundTo(places: 2)) Km"
    }
    
    func placeLocationPins(){
        Location.queryOfflineFor(trip: trip)?.findObjectsInBackground(block: { (locations, error) in
            if error == nil{
                for location in locations!{
                    let coordiante = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                    let pin = Pin(coordinate: coordiante)
                    pin.title = "Viteză: \(location.speed.roundTo(places: 2)) Km/h"
                    pin.subtitle = location.date.toString()
                    self.annotations.append(pin)
                }
                self.annotations.first?.title = self.trip.startPlace
                self.annotations.last?.title = self.trip.endPlace
                self.mapView.showAnnotations(self.annotations, animated: true)
                self.mapView.selectAnnotation(self.annotations.first!, animated: true)
            }
        })
    }
    
}
