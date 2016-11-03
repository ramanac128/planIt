//
//  CalendarViewController.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/3/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController {
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    var calendar = Calendar.current
    var currentDate = Date()
    
    var headerLabelFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = true;
        
        self.headerLabelFormatter.dateFormat = "MMMM yyyy"
        
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.registerCellViewXib(file: "CalendarDayCell")
        
        self.calendarView.cellInset = CGPoint()
        self.calendarView.direction = .vertical
        self.calendarView.allowsMultipleSelection = true
        self.calendarView.scrollingMode = .stopAtEach(customInterval: 7)
        
        self.scrollToDate(Date(), animation: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollToDate(_ date: Date, animation: Bool) {
        let today = Date()
        let nextDate = (date < today ? today : date)
        self.currentDate = nextDate
        self.calendarView.scrollToDate(nextDate, triggerScrollToDateDelegate: true, animateScroll: animation)
    }
    
    @IBAction func backButtonTouch(_ sender: UIButton) {
        if let date = calendar.date(byAdding: .day, value: -7, to: currentDate) {
            self.scrollToDate(date, animation: true)
        }
    }
    
    @IBAction func forwardButtonTouch(_ sender: UIButton) {
        if let date = calendar.date(byAdding: .day, value: 7, to: currentDate) {
            self.scrollToDate(date, animation: true)
        }
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let firstDate = Date()
        let secondDate = self.calendar.date(byAdding: .year, value: 1, to: firstDate, wrappingComponents: false)!
        let numberOfRows = 2
        
        let parameters = ConfigurationParameters(startDate: firstDate,
                                                 endDate: secondDate,
                                                 numberOfRows: numberOfRows,
                                                 calendar: Calendar.current,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfGrid,
                                                 firstDayOfWeek: .sunday)
        return parameters;
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        (cell as! CalendarDayCell).setupCellBeforeDisplay(cellState: cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        if let firstMonthDate = visibleDates.monthDates.first {
            self.monthLabel.text = self.headerLabelFormatter.string(from: firstMonthDate)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CalendarDayCell)?.cellSelectionChanged(cellState)
        self.calendarView.reloadDates(calendarView.selectedDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CalendarDayCell)?.cellSelectionChanged(cellState)
        self.calendarView.reloadDates(calendarView.selectedDates)
    }
}

