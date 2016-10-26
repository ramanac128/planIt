//
//  TimeMatrixDisplayManager.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/13/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

protocol TimeMatrixResolutionListener: class {
    func onChange(resolution: TimeMatrixDisplayManager.Resolution, previous: TimeMatrixDisplayManager.Resolution)
}

protocol TimeMatrixTimeFormatListener: class {
    func onChange(timeFormat: TimeMatrixDisplayManager.TimeFormat, previous: TimeMatrixDisplayManager.TimeFormat)
}

protocol TimeMatrixRowAnimationListener: class {
    func onRowAnimationBegin()
    func onRowAnimationFrame()
    func onRowAnimationEnd()
}

extension TimeMatrixRowAnimationListener {
    func onRowAnimationBegin() {}
    func onRowAnimationFrame() {}
    func onRowAnimationEnd() {}
}

protocol TimeMatrixColumnAnimationListener: class {
    func onColumnAnimationBegin()
    func onColumnAnimationFrame()
    func onColumnAnimationEnd()
}

extension TimeMatrixColumnAnimationListener {
    func onColumnAnimationBegin() {}
    func onColumnAnimationFrame() {}
    func onColumnAnimationEnd() {}
}

class TimeMatrixDisplayManager {
    static let instance = TimeMatrixDisplayManager()
    
    static let defaultResolution = Resolution.thirtyMinutes
    static let defaultTimeFormat = TimeFormat.standard
    
    
    // MARK: - Display constants
    
    // day and time labels
    
    static let dayLabelDayOfWeekFontSize = CGFloat(20)
    static let dayLabelMonthAndDayFontSize = CGFloat(12)
    
    static let timeLabelFontSize = CGFloat(16)
    
    static let timeLabelColorOnHour = UIColor.black
    static let timeLabelColorOn30Min = UIColor(white: 0.4, alpha: 1)
    static let timeLabelColorOn15Min = UIColor(white: 0.7, alpha: 1)
    
    // selection cells
    
    static let cellHeightMinimum = CGFloat(30)
    static let cellHeightIncrement = CGFloat(5)
    
    static let cellBackgroundColorUnavailable = UIColor.red.cgColor
    static let cellBackgroundColorAvailable = UIColor.yellow.cgColor
    static let cellBackgroundColorPreferred = UIColor.green.cgColor
    
    static let cellStrokeWidthMajorTick = CGFloat(2.5)
    static let cellStrokeWidthMinorTick = CGFloat(1)
    static let cellStrokeColorMajorTick = UIColor(white: 0.85, alpha: 1).cgColor
    static let cellStrokeColorMinorTick = UIColor(white: 0.75, alpha: 1).cgColor
    
    static let cellStrokeWidthDayBorder = CGFloat(8)
    static let cellStrokeColorDayBorder = UIColor.white.cgColor
    
    // animations
    
    static let resolutionChangeAnimationDuration = TimeInterval(0.6)
    
    static let dayAddedAnimationDuration = TimeInterval(0.4)
    static let dayRemovedAnimationDuration = TimeInterval(0.4)

    
    // MARK: - Enumerations
    
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
    
    
    // MARK: - Properties
    
    var resolution: Resolution {
        didSet {
            if oldValue != self.resolution {
                for listener in self.resolutionListeners {
                    listener.onChange(resolution: self.resolution, previous: oldValue)
                }
            }
        }
    }
    
    var timeFormat: TimeFormat {
        didSet {
            if oldValue != self.timeFormat {
                for listener in self.timeFormatListeners {
                    listener.onChange(timeFormat: self.timeFormat, previous: oldValue)
                }
            }
        }
    }
    
    
    // MARK: - Variables
    
    let resolutionListeners = WeakSet<TimeMatrixResolutionListener>()
    let timeFormatListeners = WeakSet<TimeMatrixTimeFormatListener>()
    let rowAnimationListeners = WeakSet<TimeMatrixRowAnimationListener>()
    let columnAnimationListeners = WeakSet<TimeMatrixColumnAnimationListener>()
    
    
    // MARK: - Initialization
    
    private init() {
        self.resolution = TimeMatrixDisplayManager.defaultResolution
        self.timeFormat = TimeMatrixDisplayManager.defaultTimeFormat
    }
    
    
    // MARK: - Speaker methods
    
    func informOnRowAnimationBegin() {
        for listener in self.rowAnimationListeners {
            listener.onRowAnimationBegin()
        }
    }
    
    func informOnRowAnimationFrame() {
        for listener in self.rowAnimationListeners {
            listener.onRowAnimationFrame()
        }
    }
    
    func informOnRowAnimationEnd() {
        for listener in self.rowAnimationListeners {
            listener.onRowAnimationEnd()
        }
    }
    
    func informOnColumnAnimationBegin() {
        for listener in self.columnAnimationListeners {
            listener.onColumnAnimationBegin()
        }
    }
    
    func informOnColumnAnimationFrame() {
        for listener in self.columnAnimationListeners {
            listener.onColumnAnimationFrame()
        }
    }
    
    func informOnColumnAnimationEnd() {
        for listener in self.columnAnimationListeners {
            listener.onColumnAnimationEnd()
        }
    }
}
