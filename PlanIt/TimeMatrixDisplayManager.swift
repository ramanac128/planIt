//
//  TimeMatrixDisplayManager.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/13/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

protocol TimeMatrixResolutionListener: class {
    func onChange(resolution: TimeMatrixDisplayManager.Resolution)
}

protocol TimeMatrixTimeFormatListener: class {
    func onChange(timeFormat: TimeMatrixDisplayManager.TimeFormat)
}

class TimeMatrixDisplayManager {
    static let instance = TimeMatrixDisplayManager()
    
    static let minimumCellHeight = CGFloat(30)
    static let cellHeightIncrement = CGFloat(5)
    
    enum Resolution: Double {
        case fifteenMinutes = 0.25
        case thirtyMinutes = 0.5
        case oneHour = 1.0
        case twoHours = 2.0
        case fourHours = 4.0
        case eightHours = 8.0
    }
    
    enum TimeFormat {
        case standard, military
    }
    
    var resolution: Resolution {
        didSet {
            if oldValue != self.resolution {
                for listener in self.resolutionListeners {
                    listener.onChange(resolution: self.resolution)
                }
            }
        }
    }
    
    var selectionCellsPerTimeLabel: Int
    
    var timeFormat: TimeFormat {
        didSet {
            if oldValue != self.timeFormat {
                for listener in self.timeFormatListeners {
                    listener.onChange(timeFormat: self.timeFormat)
                }
            }
        }
    }
    
    let resolutionListeners = WeakSet<TimeMatrixResolutionListener>()
    let timeFormatListeners = WeakSet<TimeMatrixTimeFormatListener>()
    
    private init() {
        self.resolution = .oneHour
        self.timeFormat = .military
        self.selectionCellsPerTimeLabel = 1
    }
    
}
