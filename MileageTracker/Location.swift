//
//  Location.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 12/04/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import Foundation
import Parse

class Location: PFObject{
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var speed: Double
    @NSManaged var date: Date
    @NSManaged var trip: Trip
    
    init(latitude: Double, longitude: Double, speed: Double, date: Date, trip: Trip) {
        super.init()
        self.latitude = latitude
        self.longitude = longitude
        self.speed = speed
        self.date = date
        self.trip = trip
    }
    
    override init() {
        super.init()
    }
    
    override class func query() -> PFQuery<PFObject>? {
        let query = PFQuery(className: Location.parseClassName())
        return query
    }
    
    class func queryOnlineFor(trip:Trip) -> PFQuery<Location>? {
        let query = PFQuery(className: Location.parseClassName())
        query.whereKey("trip", equalTo: trip)
        return query as? PFQuery<Location>
    }
    
    class func queryLastLocationFor(trip:Trip) -> PFQuery<PFObject>? {
        let query = PFQuery(className: Location.parseClassName())
        query.fromLocalDatastore()
        query.whereKey("trip", equalTo: trip)
        query.addDescendingOrder("date")
        return query
    }
    
    class func queryOfflineFor(trip:Trip) -> PFQuery<Location>? {
        let query = PFQuery(className: Location.parseClassName())
        query.fromLocalDatastore()
        query.addAscendingOrder("date")
        query.whereKey("trip", equalTo: trip)
        return query as? PFQuery<Location>
    }
    
    func distanceFrom(location: Location)->CLLocationDistance{
        return CLLocation(latitude: location.latitude, longitude: location.longitude).distance(from: CLLocation(latitude: self.latitude,longitude: self.longitude))
    }
    
    func getCLLocation()->CLLocation{
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
}

extension Location : PFSubclassing{
    class func parseClassName() -> String {
        return "Location"
    }
}

