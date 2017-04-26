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
    
    func showTripDetails(){
        durationLabel.text = trip.endTime.timeIntervalSince(trip.startTime).toHoursMinutesString()
        speedLabel.text = "\(trip.averageSpeed.roundTo(places: 2)) Km/h"
        distanceLabel.text = "\((trip.distance/1000).roundTo(places: 2)) Km"
    }
    
    func placeLocationPins(){
        Location.queryOnlineFor(trip: trip)?.findObjectsInBackground(block: { (locations, error) in
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
