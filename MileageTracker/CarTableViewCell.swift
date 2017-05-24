//
//  CarTableViewCell.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 11/05/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import UIKit

class CarTableViewCell: UITableViewCell {
    
    var dates = [Date]()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var nrTripsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepareCell(car: Beacon){
        nameLabel.text = car.vehicle
        Trip.queryFor(car: car)?.findObjectsInBackground(block: { (trips, error) in
            if error == nil{
                var km = 0.0
                for trip in trips!{
                    if !self.dates.contains(where: { (date) -> Bool in
                        return Calendar.current.dateComponents([.month,.year], from: date) == Calendar.current.dateComponents([.month,.year], from: trip.startTime)
                    }){
                        self.dates.append(trip.startTime)
                    }
                    
                    km+=trip.distance
                }
                self.distanceLabel.text = "\((km/1000).roundTo(places: 2)) Km parcurși"
                self.nrTripsLabel.text =  "\(trips!.count) călătorii"
            }
        })
    }
}
