//
//  CalendarViewController.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 07/04/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import UIKit
import CVCalendar

class SavedScansController: UIViewController, CVCalendarViewAppearanceDelegate,CVCalendarViewDelegate, CVCalendarMenuViewDelegate{
    
    var date: CVDate = CVDate(date: Date())
    
    @IBOutlet private weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    var animationFinished = true
    var firstTime = false
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBAction func previous(_ sender: UIButton) {
        calendarView.loadPreviousView()
    }
    
    @IBAction func next(_ sender: UIButton){
        calendarView.loadNextView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendarView.calendarAppearanceDelegate = self
        self.calendarView.animatorDelegate = self
        self.calendarView.calendarDelegate = self
        self.menuView.menuViewDelegate = self
        Utils.changeStatusBarColor(color : MyColors.mainColor)
        self.calendarView.commitCalendarViewUpdate()
        self.menuView.commitMenuViewUpdate()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        monthLabel.text = date.globalDescription.uppercased()
        reloadTrips(date: date.convertedDate()!)
        
    }
        
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .monday
    }
    
    func presentedDateUpdated(_ date: CVDate) {
        self.date = date
        monthLabel.text = date.globalDescription.uppercased()
        reloadTrips(date: date.convertedDate()!)
    }
    
    func didSelectDayView(_ dayView: CVCalendarDayView, animationDidFinish: Bool) {
        if dayView.tag == 12{
            date = dayView.date
            self.performSegue(withIdentifier: "seeDayTrips", sender: self)
        }
    }
    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .short
    }
    
    func shouldAutoSelectDayOnMonthChange()->Bool{
        return false
    }
    
    func dayLabelWeekdayInTextColor() -> UIColor {
        return MyColors.lightGray
    }
    
    func dayLabelPresentWeekdaySelectedTextColor() -> UIColor {
        return UIColor.lightGray
    }
    
    func dayLabelPresentWeekdayTextColor() -> UIColor {
        return MyColors.lightGray
    }
    
    func dayLabelWeekdaySelectedTextColor() -> UIColor {
        return MyColors.lightGray
    }
    
    func dayLabelPresentWeekdaySelectedFont() -> UIFont {
        return UIFont(name: "Avenir-Medium", size: 22)!
    }
    
    func dayOfWeekFont() -> UIFont {
        return UIFont(name: "Avenir-Medium", size: 14)!
    }
    
    func dayOfWeekTextColor() -> UIColor {
        return MyColors.darkGray
    }
    
    func selectionViewPath() -> ((CGRect) -> (UIBezierPath)) {
        return { _ in UIBezierPath(rect: CGRect(x: 0, y: 0, width: 0, height: 0)) }
    }
    
    func shouldShowCustomSingleSelection() -> Bool {
        return true
    }
    
    //change color for days with trips available
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        return false
    }
    
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
        return [UIColor.clear]
    }
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seeDayTrips" {
            let viewController = segue.destination as! TripsListViewController
            viewController.date = date.convertedDate()
        }
    }
    
    func reloadTrips(date: Date){
        Trip.queryForMonth(date: date)?.findObjectsInBackground(block: { (trips, error) in
            if error == nil{
                for trip in trips!{
                    let week = Calendar(identifier: .gregorian).component(.weekOfMonth, from: trip.startTime)-1
                    let weekday = Calendar(identifier: .gregorian).component(.weekday, from: trip.startTime)-2
                    self.calendarView.contentController.presentedMonthView.weekViews[week].dayViews[weekday].dayLabel.textColor = MyColors.mainColor
                    self.calendarView.contentController.presentedMonthView.weekViews[week].dayViews[weekday].tag = 12
                    self.calendarView.contentController.presentedMonthView.weekViews[week].dayViews[weekday].dayLabel.font = UIFont(name: "Avenir-Black",size: 18)
                }
            }
        })
    }
    
    
}
