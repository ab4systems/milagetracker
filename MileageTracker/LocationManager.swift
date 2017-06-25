//
//  LocationManager.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 09/03/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import Parse


class LocationManager: CLLocationManager, CLLocationManagerDelegate {
    
    static let mainInstance: LocationManager = {
        let instance = LocationManager()
        instance.requestAlwaysAuthorization()
        instance.allowsBackgroundLocationUpdates = true
        instance.desiredAccuracy = kCLLocationAccuracyBest
        instance.delegate = instance
        instance.activityType = .automotiveNavigation
        instance.distanceFilter = 200
        instance.headingFilter = 60
        instance.headingOrientation = .unknown
        instance.pausesLocationUpdatesAutomatically = false
        return instance
    }()
    
    private var lastLocation: CLLocation!
    private var activeTrip : Trip!
    private var task : DispatchWorkItem!
    
    //    let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: "97690290-6bf6-418e-b220-0e421ce161b2")!, major: 1, minor: 0, identifier: "GimbalBeacon")
    //    let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: "20CAE8A0-A9CF-11E3-A5E2-0800200C9A66")!, major: 105, minor: 2662, identifier: "OnyxBeacon")
    
    func startMonitoringBeacons(){
        if PFUser.current() != nil{
            Beacon.queryOffline()?.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    for beacon in objects as! [Beacon]{
                        self.startMonitoring(beacon: beacon)
                    }
                }
            })
        }
    }
    
    func stopMonitoringBeacons(){
        if PFUser.current() != nil{
            Beacon.queryOffline()?.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    for beacon in objects as! [Beacon]{
                        self.stopMonitoring(beacon: beacon)
                    }
                }
            })
        }
    }
    
    func stopMonitoring(beacon: Beacon){
        let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: beacon.uuid)!, major: CLBeaconMajorValue(beacon.major), minor: CLBeaconMinorValue(beacon.minor), identifier: beacon.vehicle)
        beaconRegion.notifyOnEntry = false
        beaconRegion.notifyOnExit = false
        stopMonitoring(for: beaconRegion)
    }
    
    func startMonitoring(beacon: Beacon){
        let uuid = UUID(uuidString: beacon.uuid)!
        let major = CLBeaconMajorValue(beacon.major)
        let minor = CLBeaconMinorValue(beacon.minor)
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid,
                                          major: major,
                                          minor: minor,
                                          identifier: beacon.vehicle)
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        startMonitoring(for: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            guard task == nil else{
                return
            }
            guard location.horizontalAccuracy < 120 && location.horizontalAccuracy >= 0 else {
                return
            }
            if activeTrip == nil{
                do{
                   try restoreActiveTripFromDatabase()
                }catch{
                    return
                }
            }
//            guard location.timestamp > activeTrip.startTime else{
//                return
//            }
            
            if lastLocation == nil {
                save(location: location)
            }else if location.distance(from: lastLocation!) > 30 {
                save(location: location)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        stopUpdatingLocation()
        requestLocation()
        startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLBeaconRegion {
            Utils.showNotification(body: "Did enter beacon region")
            if activeTrip == nil{
                do{
                    try restoreActiveTripFromDatabase()
                }catch{
                    startNewTrip(vehicle: region.identifier)
                    return
                }
            }
            if activeTrip.beacon.vehicle == region.identifier{
                resumeCurrentTrip()
                Utils.showNotification(body: "Calatorie contiuata")
            }else{
                endCurrentTrip()
                startNewTrip(vehicle: region.identifier)
                Utils.showNotification(body: "Calatorie noua")
            }
        }
    }
    
    func restoreActiveTripFromDatabase() throws {
        self.activeTrip = try Trip.queryForCurrentTrip()?.getFirstObject() as? Trip
        do{
            let lastSavedLocation = try Location.queryLastLocationFor(trip: self.activeTrip)?.getFirstObject() as! Location
            self.lastLocation = CLLocation(latitude: lastSavedLocation.latitude, longitude: lastSavedLocation.longitude)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func startNewTrip(vehicle : String) {
        do{
            let beacon =  try Beacon.queryByVehicle(vehicle: vehicle)?.getFirstObject()
            self.activeTrip = Trip(beacon: beacon as! Beacon)
            self.activeTrip.pinInBackground()
            self.activeTrip.saveEventually()
            self.startLocationUpdates()
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func resumeCurrentTrip(){
        if task != nil{
            task.cancel()
            task = nil
        }
        self.startLocationUpdates()
    }
    
    func endCurrentTrip(){
        let tripInfo = self.getTripDetails()
        if tripInfo.0 > 80{
            self.activeTrip.unpinInBackground()
            self.activeTrip.deleteEventually()
            Utils.showNotification(body: "Calatoria a fost stearsa")
        }else{
            self.activeTrip.current = false
            self.activeTrip.distance = tripInfo.1
            self.activeTrip.averageSpeed = tripInfo.2
//            self.activeTrip.startTime = tripInfo.3!
            self.activeTrip.endTime = tripInfo.4!
            self.activeTrip.pinInBackground()
            self.activeTrip.saveEventually()
            Utils.showNotification(body: "A fost adăugată o călătorie nouă!")
        }
        self.activeTrip = nil
        self.lastLocation = nil
        self.task = nil
        self.stopLocationUpdates()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLBeaconRegion {
            Utils.showNotification(body: "Did exit beacon region")
            self.task = DispatchWorkItem {
                if self.activeTrip == nil{
                    do{
                        try self.restoreActiveTripFromDatabase()
                    }catch{
                        return
                    }
                }
                self.endCurrentTrip()
            }
            let queue = DispatchQueue.global(qos: .default)
            queue.asyncAfter(deadline: DispatchTime.now() + 300, execute: task)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func startLocationUpdates(){
        startMonitoringSignificantLocationChanges()
        startUpdatingLocation()
        startUpdatingHeading()
    }
    
    func stopLocationUpdates(){
        stopMonitoringSignificantLocationChanges()
        stopUpdatingHeading()
        stopUpdatingLocation()
    }
    
    func save(location: CLLocation){
        let pLocation = Location(latitude: location.coordinate.latitude,
                                 longitude: location.coordinate.longitude,
                                 speed: location.speed < 0 ? 0 : location.speed * 3.6,
                                 date: location.timestamp,
                                 trip: self.activeTrip)
        pLocation.pinInBackground()
        pLocation.saveEventually()
        self.lastLocation = location
    }
    
    func getTripDetails()->(Double,Double,Double,Date?,Date?){
        do{
            var nrInRegion = 0
            var distance = 0.0
            var speed = 0.0
            
            let locations = try Location.queryOfflineFor(trip: self.activeTrip)?.findObjects()
            if let firstLocation = locations!.first{
                let region =  CLCircularRegion(center: CLLocationCoordinate2D(latitude: firstLocation.latitude, longitude: firstLocation.longitude), radius: 500, identifier: "startRegion")
                for i in 1..<locations!.count-1{
                    if region.contains(CLLocationCoordinate2D(latitude: locations![i].latitude, longitude: locations![i].longitude)){
                        nrInRegion+=1
                    }
                    distance += locations![i].distanceFrom(location: locations![i-1])
                    speed += locations![i].speed
                }
                speed = speed/Double(locations!.count-1)
                let percentage = Double((nrInRegion*100)/locations!.count)
                if percentage > 80{
                    for location in locations!{
                        location.unpinInBackground()
                        location.deleteEventually()
                    }
                }
                return (percentage,distance,speed,firstLocation.date,(locations!.last?.date)!)
            }
        }catch{
            
        }
        return (100,0,0,nil,nil)
    }
}



