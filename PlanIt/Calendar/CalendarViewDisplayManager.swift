//
//  CalendarViewDisplayManager.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/3/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

protocol CalendarViewConfigurationListener: class {
    func onChange(configuration: CalendarViewDisplayManager.Configuration)
}

protocol CalendarViewModelListener: class {
    func onChange(model: TimeMatrixModel?)
}

class CalendarViewDisplayManager {
    static let instance = CalendarViewDisplayManager()
    
    // MARK: - Display constants
    
    static var thisMonthCellTextColor = UIColor.black
    static var otherMonthCellTextColor = UIColor.gray
    
    static var preferredDateCellColor = UIColor.green.cgColor
    static var selectedCellColor = UIColor.yellow.cgColor
    static var selectedCellHeightPct = CGFloat(0.65)
    static var selectedCellYPosPct = (CGFloat(1) - CalendarViewDisplayManager.selectedCellHeightPct) / CGFloat(2)
    
    static var todayCellStrokeWidth = CGFloat(3.5)
    static var todayCellStrokeColor = UIColor(hex: 0x3399FF).cgColor
    
    
    // MARK: - Enumerations
    
    enum Configuration {
        case preferredDate
        case availableDates
    }
    
    
    // MARK: - Properties
    
    var configuration: Configuration {
        didSet {
            if oldValue != self.configuration {
                if oldValue == .preferredDate {
                    if let preferredDay = self.model?.preferredDay {
                        self.model!.add(day: preferredDay, isPreferred: false)
                    }
                }
                for listener in self.configurationListeners {
                    listener.onChange(configuration: self.configuration)
                }
            }
        }
    }
    
    var model: TimeMatrixModel? {
        didSet {
            for listener in self.modelListeners {
                listener.onChange(model: self.model)
            }
        }
    }

    
    // MARK: - Variables
    
    let configurationListeners = WeakSet<CalendarViewConfigurationListener>()
    let modelListeners = WeakSet<CalendarViewModelListener>()
    
    
    // MARK: - Initialization
    
    private init() {
        self.configuration = .preferredDate
    }
}
