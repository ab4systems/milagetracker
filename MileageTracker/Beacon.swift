//
//  Beacon.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 07/04/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import UIKit
import Parse

class Beacon : PFObject{
    
    @NSManaged var uuid: String
    @NSManaged var major: Int
    @NSManaged var minor: Int
    @NSManaged var vehicle: String
    @NSManaged var user: PFUser
    
    init(uuid: String, major: Int, minor: Int,vehicle:String,user: PFUser) {
        super.init()
        self.uuid = uuid
        self.major = major
        self.minor = minor
        self.vehicle = vehicle
        self.user = user
    }
    
    override init() {
        super.init()
    }
    
    override class func query() -> PFQuery<PFObject>? {
        let query = PFQuery(className: Beacon.parseClassName())
        query.whereKey("user", equalTo: PFUser.current()!)
        return query
    }
    
    class func queryByVehicle(vehicle:String) -> PFQuery<PFObject>? {
        let query = PFQuery(className: Beacon.parseClassName())
        query.fromLocalDatastore()
        query.whereKey("vehicle", equalTo: vehicle)
        return query
    }

    class func queryOffline() -> PFQuery<PFObject>? {
        let query = PFQuery(className: Beacon.parseClassName())
        query.fromLocalDatastore()
        query.whereKey("user", equalTo: PFUser.current()!)
        return query
    }
}

extension Beacon : PFSubclassing{
    class func parseClassName() -> String {
        return "Beacon"
    }
}
