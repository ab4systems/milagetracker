//
//  TripsListViewController.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 18/04/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import UIKit

class TripsListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tripsList: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    
    var date : Date?
    var trips = [Trip]()
    var selectedTrip = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripsList.delegate = self
        tripsList.dataSource = self
        if date != nil{
            dateLabel.text = date?.toDateString()
            Trip.queryFor(date: date!)?.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    self.trips = objects as! [Trip]
                    self.tripsList.reloadData()
                self.placeTripsDetails()
                }
            })
        }else{
            dateLabel.text = "Toate călătoriile"
            Trip.queryOffline()?.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    self.trips = objects as! [Trip]
                    self.tripsList.reloadData()
                self.placeTripsDetails()
                }
            })
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripCell",for: indexPath) as! TripTableViewCell
        cell.prepareCell(trip: trips[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTrip = indexPath.row
        performSegue(withIdentifier: "seeDetailMap", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as! TripDetailsViewController).trip = trips[selectedTrip]
    }
    
    func placeTripsDetails(){
        var distance = 0.0
        for trip in trips{
            distance += trip.distance
        }
        countLabel.text = "\(trips.count)"
        distanceLabel.text = "\((distance/1000).roundTo(places: 2)) KM"
    }

}
