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

protocol CalendarViewSizeListener: class {
    func onChange(size: CalendarViewDisplayManager.ViewSize)
    func onSizeAnimationBegin()
    func onSizeAnimationChange()
    func onSizeAnimationEnd()
}

extension CalendarViewSizeListener {
    func onSizeAnimationBegin() {}
    func onSizeAnimationChange() {}
    func onSizeAnimationEnd() {}
}

class CalendarViewDisplayManager: TimeMatrixModelListener {
    static let instance = CalendarViewDisplayManager()
    
    // MARK: - Display constants
    
    static let sizeChangeAnimationDuration = 0.5
    
    static let thisMonthCellTextColor = UIColor.black
    static let otherMonthCellTextColor = UIColor.gray
    
    static let preferredDateCellColor = UIColor.green.cgColor
    static let selectedCellColor = UIColor.yellow.cgColor
    static let selectedCellHeightPct = CGFloat(0.65)
    static let selectedCellYPosPct = (CGFloat(1) - CalendarViewDisplayManager.selectedCellHeightPct) / CGFloat(2)
    
    static let todayCellStrokeWidth = CGFloat(3.5)
    static let todayCellStrokeColor = UIColor(hex: 0x3399FF).cgColor
    
    
    // MARK: - Enumerations
    
    enum Configuration {
        case preferredDate
        case availableDates
    }
    
    enum ViewSize {
        case small, large
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
    
    var viewSize: ViewSize {
        didSet {
            if oldValue != self.viewSize {
                for listener in self.sizeListeners {
                    listener.onChange(size: self.viewSize)
                    listener.onSizeAnimationBegin()
                }
                
                UIView.animate(withDuration: CalendarViewDisplayManager.sizeChangeAnimationDuration,
                               animations: {() -> Void in
                    for listener in self.sizeListeners {
                        listener.onSizeAnimationChange()
                    }
                }, completion: {(finished: Bool) -> Void in
                    for listener in self.sizeListeners {
                        listener.onSizeAnimationEnd()
                    }
                })
            }
        }
    }
    
    var model: TimeMatrixModel?

    
    // MARK: - Variables
    
    let configurationListeners = WeakSet<CalendarViewConfigurationListener>()
    let sizeListeners = WeakSet<CalendarViewSizeListener>()
    
    
    // MARK: - Initialization
    
    private init() {
        self.configuration = .preferredDate
        self.viewSize = .large
        
        let modelManager = TimeMatrixModelManager.instance
        modelManager.modelListeners.insert(self)
        self.onChange(model: modelManager.model)
    }
    
    func onChange(model: TimeMatrixModel?) {
        self.model = model
    }
}
