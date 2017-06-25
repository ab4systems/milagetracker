//
//  ProfileViewController.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 10/04/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var selectedBeaconIndex = -1
    
    var beacons = [Beacon]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        showUserInfo()
        loadBeacons()
    }

    func showUserInfo(){
        if let user = PFUser.current(){
            emailLabel.text = user.email
            let info = user.dictionaryWithValues(forKeys: ["first_name","last_name"])
            nameLabel.text = "\(info["first_name"] as! String) \(info["last_name"] as! String)"
            dateLabel.text = user.createdAt?.toDateString()
        }
    }

    func loadBeacons(){
        Beacon.queryOffline()?.findObjectsInBackground(block: { (objects, error) in
            if error == nil{
                self.beacons = objects as! [Beacon]
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func unwindToProfile(segue: UIStoryboardSegue) {
        loadBeacons()
    }

    @IBAction func logOut(_ sender: Any) {
        LocationManager.mainInstance.stopMonitoringBeacons()
        PFUser.logOut()
         (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = storyboard?.instantiateViewController(withIdentifier: "LoginController")
    }
    
    @IBAction func addBeacon(_ sender: Any) {
        self.performSegue(withIdentifier: "newBeacon", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beacons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "vehicleCell", for: indexPath)

        cell.textLabel?.text = beacons[indexPath.row].vehicle
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Editează") { action, index in
            self.selectedBeaconIndex = index.row
            self.performSegue(withIdentifier: "editBeacon", sender: self)
        }
        edit.backgroundColor = UIColor.blue
        
        if beacons.count > 1{
            let delete = UITableViewRowAction(style: .normal, title: "Șterge") { action, index in
                LocationManager.mainInstance.stopMonitoring(beacon: self.beacons[index.row])
                self.beacons[index.row].unpinInBackground()
                self.beacons[index.row].deleteEventually()
                self.beacons.remove(at: index.row)
                tableView.reloadData()
            }
            delete.backgroundColor = UIColor.red
            
            return [edit, delete]
        }else{
            return [edit]
        }
    }
        
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editBeacon"{
            (segue.destination as! EditOrAddBeaconViewController).beacon = beacons[selectedBeaconIndex]
        }
    }
}
