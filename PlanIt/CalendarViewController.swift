//
//  CalendarViewController.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/6/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController {
    @IBOutlet weak var calendarView: JTAppleCalendarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.registerCellViewXib(fileName: "CalendarDayCell")
        
        self.calendarView.cellInset = CGPoint()
//        self.calendarView.reloadData()
//        self.calendarView.scrollToDate(Date(), triggerScrollToDateDelegate: false, animateScroll: false, preferredScrollPosition: .top, completionHandler: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> (startDate: Date, endDate: Date, numberOfRows: Int, calendar: Calendar) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let aCalendar = Calendar.current // Properly configure your calendar to your time zone here
        let firstDate = Date()
        let secondDate = aCalendar.date(byAdding: .year, value: 1, to: firstDate, wrappingComponents: false)
        let numberOfRows = 6
        
        return (startDate: firstDate, endDate: secondDate!, numberOfRows: numberOfRows, calendar: aCalendar)
    }

    func calendar(_ calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        (cell as! CalendarDayCell).setupCellBeforeDisplay(cellState: cellState, date: date)
    }
}
