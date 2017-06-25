//
//  ChartViewController.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 11/05/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import UIKit
import Charts

class ChartViewController: UIViewController,ChartViewDelegate {
    
    var month : Date!
    var days : [Int]!
    var distances : [Double]!
    var trips : [Trip]!
    var selectedDay = 0
    
    @IBOutlet weak var barChartView: BarChartView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = month.toMonthYearString()
        barChartView.delegate = self
        let range = Calendar.current.range(of: .day, in: .month, for: month)!
        days = [Int](range.lowerBound..<range.upperBound)
        distances = [Double](repeating: 0.0, count: days.count)
        
        Trip.queryForMonth(date: month)?.findObjectsInBackground(block: { (trips, error) in
            if error == nil{
                self.trips = trips!
                for trip in trips!{
                    self.distances[Calendar.current.component(.day, from: trip.startTime) - 1] += (trip.distance/1000).roundTo(places: 2)
                }
                self.setChart(dataPoints: self.days, values: self.distances)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setChart(dataPoints: [Int], values: [Double]) {
        
        var dataEntries = [BarChartDataEntry]()
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(dataPoints[i]), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let data = BarChartData()
        let dataset = BarChartDataSet(values: dataEntries, label: "Km/zi")
        dataset.colors = [MyColors.mainColor]
        data.addDataSet(dataset)
        barChartView.data = data
        barChartView.chartDescription?.text = ""
        barChartView.xAxis.labelPosition = .bottom
        barChartView.animate(xAxisDuration:0.5, yAxisDuration: 1.0)
        
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let gregorian = Calendar(identifier: .gregorian)
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: month)
        components.day = Int(entry.x)
        month = gregorian.date(from: components)!
        self.performSegue(withIdentifier: "tripsFromChart", sender: self)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tripsFromChart"{
            (segue.destination as! TripsListViewController).date = month
        }else{
            (segue.destination as! ReportPreviewViewController).trips = trips.sorted(by: { (trip1, trip2) -> Bool in
                return trip1.startTime < trip2.startTime
            })

        }
    }

}
