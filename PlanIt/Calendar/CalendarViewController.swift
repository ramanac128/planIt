//
//  CalendarViewController.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/3/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController, TimeMatrixModelListener, CalendarViewConfigurationListener, CalendarViewSizeListener, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    @IBOutlet weak var eventPicker: UIPickerView!
    var eventPickerData = ["Breakfast", "Lunch", "Dinner", "Drinks", "Movie"];
    
    var model: TimeMatrixModel? {
        didSet {
            self.calendarView.reloadData()
            let row = self.eventPicker.selectedRow(inComponent: 0)
            self.model?.eventType = self.eventPickerData[row]
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
        
        self.eventPicker.dataSource = self
        self.eventPicker.delegate = self
        self.eventPicker.selectRow(self.eventPickerData.count / 2, inComponent: 0, animated: false)
        
        
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.registerCellViewXib(file: "CalendarDayCell")
        
        self.calendarView.cellInset = CGPoint()
        self.calendarView.direction = .vertical
        self.calendarView.scrollingMode = .stopAtEach(customInterval: 7)
        
        let modelManager = TimeMatrixModelManager.instance
        modelManager.modelListeners.insert(self)
        self.onChange(model: modelManager.model)
        
        let displayManager = CalendarViewDisplayManager.instance
        displayManager.configurationListeners.insert(self)
        displayManager.sizeListeners.insert(self)
        self.onChange(configuration: displayManager.configuration)
        self.onChange(size: displayManager.viewSize)
        
        self.setMonthLabel(date: Date())
        
    }
    
    func refreshCellSelectionStates() {
        self.calendarView.deselectAllDates(triggerSelectionDelegate: false)
        if let days = self.model?.activeDays {
            var dates = [Date]()
            for day in days {
                dates.append(day.toDate())
            }
            self.calendarView.selectDates(dates, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: false)
        }
    }
    
    func setMonthLabel(date: Date) {
        self.monthLabel.text = self.headerLabelFormatter.string(from: date)
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
    
    
    // MARK: - EventPicker
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return eventPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return eventPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.model?.eventType = self.eventPickerData[row]
    }
    
    @IBAction func addEventTouch(_ sender: Any) {
        let view = AddEventViewController()
        view.display(in: self)
    }
    
    func insertNewEvent(_ event: String, animated: Bool) {
        self.eventPickerData.append(event);
        self.eventPicker.reloadAllComponents()
        self.eventPicker.selectRow(self.eventPickerData.count - 1, inComponent: 0, animated: animated)
        self.model?.eventType = event
    }
    
    
    // MARK: - CalendarViewConfiguration protocol methods
    
    func onChange(configuration: CalendarViewDisplayManager.Configuration) {
        switch configuration {
            
        case .preferredDate:
            self.calendarView.allowsMultipleSelection = false
            break
            
        case .availableDates:
            self.calendarView.allowsMultipleSelection = true
            break
        }
        
        self.configuration = configuration
        self.refreshCellSelectionStates()
        self.calendarView.reloadData(withAnchor: Date(), animation: true)
    }
    
    func onChange(model: TimeMatrixModel?) {
        self.model = model
    }
    
    func onChange(size: CalendarViewDisplayManager.ViewSize) {
        switch size {
            
        case .small:
            self.numberOfRows = 2
            self.discreteScrollUnit = .day
            self.discreteScrollValue = 7
            self.calendarView.scrollingMode = .stopAtEach(customInterval: 7)
            break
            
        case .large:
            self.numberOfRows = 6
            self.discreteScrollUnit = .month
            self.discreteScrollValue = 1
            self.calendarView.scrollingMode = .stopAtEachCalendarFrameWidth
            break
        }
        
        self.calendarView.reloadData(withAnchor: Date(), animation: true)
    }
    
    func onSizeAnimationChange() {
        self.view.layoutIfNeeded()
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
        (cell as! CalendarDayCell).setupCellBeforeDisplay(cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        if let firstMonthDate = visibleDates.monthDates.first {
            self.setMonthLabel(date: firstMonthDate)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        if let model = self.model {
            let day = TimeMatrixDay(date: date)
            switch self.configuration {
            case .preferredDate:
                model.preferredDay = day
                break
                
            case .availableDates:
                model.add(day: day)
                break
            }
            self.calendarView.reloadData()
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        if let model = self.model {
            let day = TimeMatrixDay(date: date)
            switch self.configuration {
            case .preferredDate:
                model.preferredDay = nil
                break
                
            case .availableDates:
                model.remove(day: day)
                break
            }
            self.calendarView.reloadData()
        }
    }
}

