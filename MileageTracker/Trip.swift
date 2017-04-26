//
//  Trip.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 12/04/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import Foundation
import Parse

class Trip : PFObject{
    @NSManaged var current : Bool
    @NSManaged var user : PFUser
    @NSManaged var beacon : Beacon
    @NSManaged var startTime : Date
    @NSManaged var endTime : Date
    @NSManaged var averageSpeed : Double
    @NSManaged var distance : Double
    @NSManaged var startPlace : String?
    @NSManaged var endPlace : String?

    
    override init() {
        super.init()
    }
    
    init(beacon: Beacon) {
        super.init()
        self.startTime = Date()
        self.beacon = beacon
        self.current = true
        self.user = PFUser.current()!
    }
    
    override class func query() -> PFQuery<PFObject>? {
        let query = PFQuery(className: Trip.parseClassName())
        query.whereKey("user", equalTo: PFUser.current()!)
        return query
    }
    
    class func queryForCurrentTrip() -> PFQuery<PFObject>? {
        let query = PFQuery(className: Trip.parseClassName())
        query.fromLocalDatastore()
        query.whereKey("current", equalTo: true)
        return query
    }
    
    class func queryOffline() -> PFQuery<PFObject>? {
        let query = PFQuery(className: Trip.parseClassName())
        query.fromLocalDatastore()
        query.includeKey("beacon")
        query.addDescendingOrder("startTime")
        query.whereKey("current", equalTo: false)
        return query
    }
    
    class func queryForMonth(date:Date) -> PFQuery<Trip>?{
        let query = PFQuery(className: Trip.parseClassName())
        query.fromLocalDatastore()
        query.whereKey("current", equalTo: false)
        query.whereKey("startTime", greaterThan: date.startOfMonth())
        query.whereKey("startTime", lessThan: date.endOfMonth())
        query.addDescendingOrder("startTime")
        return query as? PFQuery<Trip>
    }
    
    class func queryFor(date:Date) -> PFQuery<PFObject>? {
        let gregorian = Calendar(identifier: .gregorian)
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.hour = 0
        components.minute = 0
        components.second = 0
        let startDate = gregorian.date(from: components)!
        components.hour = 23
        components.minute = 59
        components.second = 59
        let endDate = gregorian.date(from: components)!
        
        let query = PFQuery(className: Trip.parseClassName())
        query.fromLocalDatastore()
        query.includeKey("beacon")
        query.whereKey("current", equalTo: false)
        query.whereKey("startTime", greaterThan: startDate)
        query.whereKey("startTime", lessThan: endDate)
        query.addDescendingOrder("startTime")
        return query
    }
}

extension Trip : PFSubclassing{
    class func parseClassName() -> String {
        return "Trip"
    }
}
