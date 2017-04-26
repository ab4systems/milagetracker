//
//  TripTableViewCell.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 19/04/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import UIKit
import MapKit

class TripTableViewCell: UITableViewCell,MKMapViewDelegate{

    @IBOutlet weak var startHourLabel: UILabel!
    @IBOutlet weak var endHourLabel: UILabel!
    @IBOutlet weak var startLocationLabel: UILabel!
    @IBOutlet weak var endLocationLabel: UILabel!
    @IBOutlet weak var vehicleLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var annotations = [Pin]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mapView.isZoomEnabled = false
        self.mapView.isScrollEnabled = false
        self.mapView.isUserInteractionEnabled = false
        self.mapView.delegate = self
    }
    
    func prepareCell(trip:Trip){
        self.mapView.removeAnnotations(self.mapView.annotations)
        annotations.removeAll()
        startHourLabel.text = trip.startTime.toHourString()
        endHourLabel.text = trip.endTime.toHourString()
        vehicleLabel.text = trip.beacon.vehicle
        Location.queryOfflineFor(trip: trip)?.findObjectsInBackground(block: { (locations, error) in
            if error == nil{
                if trip.startPlace == nil{
                    CLGeocoder().reverseGeocodeLocation((locations?.first?.getCLLocation())!, completionHandler: {(placemarks, error) -> Void in
                        if error == nil {
                            if let pm = placemarks?[0]{
                                var address = ""
                                if let street = pm.addressDictionary?["Street"] {
                                    address += "\(street), "
                                }
                                if let city = pm.addressDictionary?["City"]{
                                    address += "\(city), "
                                }

                                if let country = pm.addressDictionary?["Country"]{
                                    address += "\(country)"
                                }
                                trip.startPlace = address
                                self.startLocationLabel.text = trip.startPlace!
                                trip.pinInBackground()
                                trip.saveEventually()
                            }
                        }
                    })
                }else{
                    self.startLocationLabel.text = trip.startPlace!
                }
                
                if trip.endPlace == nil{
                    CLGeocoder().reverseGeocodeLocation((locations?.last?.getCLLocation())!, completionHandler: {(placemarks, error) -> Void in
                        if error == nil {
                            if let pm = placemarks?[0]{
                                var address = ""
                                if let street = pm.addressDictionary?["Street"] {
                                    address += "\(street), "
                                }
                                if let city = pm.addressDictionary?["City"]{
                                    address += "\(city), "
                                }
                                
                                if let country = pm.addressDictionary?["Country"]{
                                    address += "\(country)"
                                }
                                trip.endPlace = address
                                self.endLocationLabel.text = trip.endPlace!
                                trip.pinInBackground()
                                trip.saveEventually()
                            }
                        }
                    })
                }else{
                    self.endLocationLabel.text = trip.endPlace!
                }
                
                for location in locations!{
                    let coordiante = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                    self.annotations.append(Pin(coordinate: coordiante))
                }
                self.mapView.showAnnotations(self.annotations, animated: true)
                
            }
        })
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
    
}
