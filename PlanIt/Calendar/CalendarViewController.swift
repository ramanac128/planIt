//
//  CalendarViewController.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/3/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController, CalendarViewConfigurationListener {
    
    // MARK: - Properties
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    var model: TimeMatrixModel? {
        didSet {
            self.calendarView.reloadData()
        }
    }
    
    
    // MARK: - Variables
    
    var calendar = Calendar.current
    var currentDate = Date()
    
    var headerLabelFormatter = DateFormatter()
    
    var configuration = CalendarViewDisplayManager.Configuration.preferredDate
    var numberOfRows = 6
    var discreteScrollUnit = Calendar.Component.month
    var discreteScrollValue = 1
    
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = true;
        self.headerLabelFormatter.dateFormat = "MMMM yyyy"
        
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.registerCellViewXib(file: "CalendarDayCell")
        
        self.calendarView.cellInset = CGPoint()
        self.calendarView.direction = .vertical
        self.calendarView.scrollingMode = .stopAtEach(customInterval: 7)
        
        let displayManager = CalendarViewDisplayManager.instance
        displayManager.configurationListeners.insert(self)
        self.onChange(configuration: displayManager.configuration)
    }
    
    
    // MARK: - Calendar navigation
    
    func scrollToDate(_ date: Date, animation: Bool) {
        let today = Date()
        let nextDate = (date < today ? today : date)
        self.currentDate = nextDate
        self.calendarView.scrollToDate(nextDate, triggerScrollToDateDelegate: true, animateScroll: animation);
    }
    
    @IBAction func backButtonTouch(_ sender: UIButton) {
        if let date = self.calendar.date(byAdding: self.discreteScrollUnit,
                                         value: -self.discreteScrollValue,
                                         to: self.currentDate,
                                         wrappingComponents: false) {
            self.scrollToDate(date, animation: true)
        }
    }
    
    @IBAction func forwardButtonTouch(_ sender: UIButton) {
        if let date = self.calendar.date(byAdding: self.discreteScrollUnit,
                                         value: self.discreteScrollValue,
                                         to: self.currentDate,
                                         wrappingComponents: false) {
            self.scrollToDate(date, animation: true)
        }
    }
    
    
    // MARK: - CalendarViewConfiguration protocol methods
    
    func onChange(configuration: CalendarViewDisplayManager.Configuration) {
        self.configuration = configuration
        switch configuration {
            
        case .preferredDate:
            self.calendarView.allowsMultipleSelection = false
            self.numberOfRows = 6
            self.discreteScrollUnit = .month
            self.discreteScrollValue = 1
            break
            
        case .availableDates:
            self.calendarView.allowsMultipleSelection = true
            self.numberOfRows = 2
            self.discreteScrollUnit = .day
            self.discreteScrollValue = 7
            break
        }
        
        self.calendarView.reloadData(withAnchor: Date(), animation: true)
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let firstDate = Date()
        let secondDate = self.calendar.date(byAdding: .year, value: 1, to: firstDate, wrappingComponents: false)!
        
        let parameters = ConfigurationParameters(startDate: firstDate,
                                                 endDate: secondDate,
                                                 numberOfRows: self.numberOfRows,
                                                 calendar: self.calendar,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfGrid,
                                                 firstDayOfWeek: .sunday)
        return parameters;
    }
}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        (cell as! CalendarDayCell).setupCellBeforeDisplay(cellState: cellState, model: model)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        if let firstMonthDate = visibleDates.monthDates.first {
            self.monthLabel.text = self.headerLabelFormatter.string(from: firstMonthDate)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        self.didChangeSelection(cell, date: date, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        self.didChangeSelection(cell, date: date, cellState: cellState)
    }
    
    func didChangeSelection(_ cell: JTAppleDayCellView?, date: Date, cellState: CellState) {
        if CalendarViewDisplayManager.instance.configuration == .preferredDate {
            self.model?.preferredDay = TimeMatrixDay(date: date)
        }
        (cell as? CalendarDayCell)?.cellSelectionChanged(cellState, configuration: self.configuration)
        self.calendarView.reloadData()
    }
}

