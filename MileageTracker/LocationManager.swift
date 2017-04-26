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
    
    static var mainInstance: LocationManager!
    var lastLocation: CLLocation?
    var activeTrip : Trip!
    var task : DispatchWorkItem!
    
    //    let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: "97690290-6bf6-418e-b220-0e421ce161b2")!, major: 1, minor: 0, identifier: "GimbalBeacon")
    //    let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: "20CAE8A0-A9CF-11E3-A5E2-0800200C9A66")!, major: 105, minor: 2662, identifier: "OnyxBeacon")
    
    static func startMonitoringBeacons(){
        if PFUser.current() != nil{
            Beacon.queryOffline()?.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    self.setupAction()
                    for beacon in objects as! [Beacon]{
                        let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: beacon.uuid)!, major: CLBeaconMajorValue(beacon.major), minor: CLBeaconMinorValue(beacon.minor), identifier: beacon.vehicle)
                        beaconRegion.notifyOnEntry = true
                        beaconRegion.notifyOnExit = true
                        self.mainInstance.startMonitoring(for: beaconRegion)
                    }
                }
            })
        }
    }
    
    static func stopMonitoringBeacons(){
        if PFUser.current() != nil{
            Beacon.queryOffline()?.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    self.setupAction()
                    for beacon in objects as! [Beacon]{
                        let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: beacon.uuid)!, major: CLBeaconMajorValue(beacon.major), minor: CLBeaconMinorValue(beacon.minor), identifier: beacon.vehicle)
                        beaconRegion.notifyOnEntry = false
                        beaconRegion.notifyOnExit = false
                        self.mainInstance.stopMonitoring(for: beaconRegion)
                    }
                }
            })
        }
    }
    
    
    static func stopMonitoring(beacon: Beacon){
            self.setupAction()
            let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: beacon.uuid)!, major: CLBeaconMajorValue(beacon.major), minor: CLBeaconMinorValue(beacon.minor), identifier: beacon.vehicle)
            beaconRegion.notifyOnEntry = false
            beaconRegion.notifyOnExit = false
            self.mainInstance.stopMonitoring(for: beaconRegion)
    }
    
    static func startMonitoring(beacon: Beacon){
        self.setupAction()
        let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: beacon.uuid)!, major: CLBeaconMajorValue(beacon.major), minor: CLBeaconMinorValue(beacon.minor), identifier: beacon.vehicle)
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        self.mainInstance.startMonitoring(for: beaconRegion)
    }
    
    static func setupAction() {
        if mainInstance == nil {
            mainInstance = LocationManager()
            mainInstance.allowsBackgroundLocationUpdates = true
            mainInstance.desiredAccuracy = kCLLocationAccuracyBest
            mainInstance.delegate = mainInstance
            mainInstance.requestAlwaysAuthorization()
            mainInstance.activityType = .automotiveNavigation
            mainInstance.distanceFilter = 200
            mainInstance.headingFilter = 60
            mainInstance.headingOrientation = .unknown
            mainInstance.pausesLocationUpdatesAutomatically = false
        }
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
                    self.activeTrip = try Trip.queryForCurrentTrip()?.getFirstObject() as? Trip
                    do{
                        let lastSavedLocation = try Location.queryLastLocationFor(trip: self.activeTrip)?.getFirstObject() as! Location
                        self.lastLocation = CLLocation(latitude: lastSavedLocation.latitude, longitude: lastSavedLocation.longitude)
                    }catch{
                        
                    }
                }catch{
                    return
                }
            }
            
            guard location.timestamp >= activeTrip.startTime else{
                Utils.showNotification(body:"old timestamp \(location.timestamp.toString())")
                return
            }
            
//            if location.timestamp >= activeTrip.startTime{
//                
//            }else{
//                                Utils.showNotification(body:"old timestamp \(location.timestamp.toString())")
//
//            }
            
            if lastLocation == nil {
                save(location: location)
            }else if location.distance(from: lastLocation!) > 50 {
                save(location: location)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        manager.stopUpdatingLocation()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLBeaconRegion {
            if task != nil{
                task.cancel()
                task = nil
            }
            Utils.showNotification(body: "Did Enter Beacon Region")
            if activeTrip == nil{
                do{
                    self.activeTrip = try Trip.queryForCurrentTrip()?.getFirstObject() as? Trip
                    do{
                        let lastSavedLocation = try Location.queryLastLocationFor(trip: self.activeTrip)?.getFirstObject() as! Location
                        self.lastLocation = CLLocation(latitude: lastSavedLocation.latitude, longitude: lastSavedLocation.longitude)
                    }catch{
                        
                    }
                    self.startLocationUpdates(manager: manager)
                }catch{
                    do{
                        let beacon =  try Beacon.queryByVehicle(vehicle: region.identifier)?.getFirstObject()
                        self.activeTrip = Trip(beacon: beacon as! Beacon)
                        self.activeTrip.pinInBackground()
                        self.activeTrip.saveEventually()
                        self.startLocationUpdates(manager: manager)
                    }catch{
                        
                    }
                }
            }else if activeTrip.beacon.vehicle == region.identifier{
                self.startLocationUpdates(manager: manager)
            }else{
                do{
                    self.activeTrip.current = false
                    self.activeTrip.pinInBackground()
                    self.activeTrip.saveEventually()
                    
                    let beacon =  try Beacon.queryByVehicle(vehicle: region.identifier)?.getFirstObject()
                    self.activeTrip = Trip(beacon: beacon as! Beacon)
                    self.activeTrip.pinInBackground()
                    self.activeTrip.saveEventually()
                    self.startLocationUpdates(manager: manager)
                }catch{
                    
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLBeaconRegion {
            Utils.showNotification(body: "Did Exit Beacon Region")
            
            self.task = DispatchWorkItem {
                Utils.showNotification(body: "Time's up")
                if self.activeTrip == nil{
                    do{
                        self.activeTrip = try Trip.queryForCurrentTrip()?.getFirstObject() as? Trip
                    }catch{
                        return
                    }
                }
                let tripInfo = self.getTripDetails()
                if tripInfo.0 > 80{
                    self.activeTrip.unpinInBackground()
                    self.activeTrip.deleteEventually()
                }else{
                    self.activeTrip.current = false
                    self.activeTrip.distance = tripInfo.1
                    self.activeTrip.averageSpeed = tripInfo.2
                    self.activeTrip.startTime = tripInfo.3!
                    self.activeTrip.endTime = tripInfo.4!
                    self.activeTrip.pinInBackground()
                    self.activeTrip.saveEventually()
                }
                self.activeTrip = nil
                self.lastLocation = nil
                self.task = nil
                self.stopLocationUpdates(manager: manager)
            }
            DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 300, execute: task)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func startLocationUpdates(manager: CLLocationManager){
        manager.startMonitoringSignificantLocationChanges()
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }
    
    func stopLocationUpdates(manager: CLLocationManager){
        manager.stopMonitoringSignificantLocationChanges()
        manager.stopUpdatingHeading()
        manager.stopUpdatingLocation()
    }
    
    func save(location: CLLocation){
        if lastLocation != nil{
            Utils.showNotification(body: "accuracy: \(location.horizontalAccuracy) \n distance: \(location.distance(from: self.lastLocation!))")
        }
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
                return (percentage,distance,speed,firstLocation.date,(locations!.last?.date)!)
            }
        }catch{
            
        }
        return (100,0,0,nil,nil)
    }
}



