//
//  CalendarViewController.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/3/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarView: UIView, CalendarViewConfigurationListener {
    
    // MARK: - Properties
    
    weak var monthLabel: UILabel!
    weak var calendarView: JTAppleCalendarView!
    
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
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    private func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let headerView = UIStackView()
        headerView.alignment = .fill
        headerView.distribution = .equalSpacing
        headerView.axis = .horizontal
        headerView.backgroundColor = CalendarViewDisplayManager.headerBackgroundColor
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "Back Icon"), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        backButton.addTarget(self, action: #selector(CalendarView.backButtonTouch(_:)), for: .touchUpInside)
        
        let monthLabel = UILabel()
        monthLabel.font = UIFont(name: "Gill Sans", size: 24)
        monthLabel.textColor = UIColor.white
        monthLabel.adjustsFontSizeToFitWidth = true
        self.monthLabel = monthLabel
        
        let forwardButton = UIButton(type: .custom)
        forwardButton.setImage(UIImage(named: "Forward Icon"), for: .normal)
        forwardButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        forwardButton.addTarget(self, action: #selector(CalendarView.forwardButtonTouch(_:)), for: .touchUpInside)
        
        headerView.addArrangedSubview(backButton)
        headerView.addArrangedSubview(monthLabel)
        headerView.addArrangedSubview(forwardButton)
        
        let calendarView = JTAppleCalendarView()
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.registerCellViewXib(file: "CalendarDayCell")
        calendarView.cellInset = CGPoint()
        calendarView.direction = .vertical
        calendarView.scrollingMode = .stopAtEach(customInterval: 7)
        self.calendarView = calendarView
        
        self.addSubview(headerView)
        self.addSubview(calendarView)
        
        var viewDict = [String: UIView]()
        viewDict["header"] = headerView
        viewDict["calendar"] = calendarView
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[header]-0-[calendar]-0-|", options: .directionLeftToRight, metrics: nil, views: viewDict)
        let hConstraintsHeader = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[header]-0-|", options: .directionLeftToRight, metrics: nil, views: viewDict)
        let hConstraintsCalendar = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[calendar]-0-|", options: .directionLeftToRight, metrics: nil, views: viewDict)
        let heightContraintHeader = NSLayoutConstraint(item: headerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        
        self.addConstraints(vConstraints)
        self.addConstraints(hConstraintsHeader)
        self.addConstraints(hConstraintsCalendar)
        self.addConstraint(heightContraintHeader)
        
        
        self.headerLabelFormatter.dateFormat = "MMMM yyyy"
        
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

extension CalendarView: JTAppleCalendarViewDataSource {
    
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

extension CalendarView: JTAppleCalendarViewDelegate {
    
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

