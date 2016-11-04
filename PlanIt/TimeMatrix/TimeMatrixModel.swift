//
//  TimeMatrixModel.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import Foundation

protocol TimeMatrixModelDayListener: class {
    func onAdded(day: TimeMatrixDay, cellModels: [TimeMatrixCellModel], atIndex index: Int)
    func onRemoved(day: TimeMatrixDay)
}

protocol TimeMatrixModelPreferredDayListener: class {
    func onChange(preferredDay: TimeMatrixDay?)
}

class TimeMatrixModel {
    
    // MARK: - Static constants
    
    static let cellsPerDay = 24 * 4
    
    
    // MARK: - Properties
    
    var preferredDay: TimeMatrixDay? {
        didSet {
            if oldValue != self.preferredDay {
                if let previous = oldValue {
                    if !self.nonPreferredDays.contains(previous) {
                        self.remove(day: previous, isPreferred: true)
                    }
                }
                if let current = self.preferredDay {
                    self.add(day: current, isPreferred: true)
                }
                self.informOnChange(preferredDay: self.preferredDay)
            }
        }
    }
    
    var activeDays: [TimeMatrixDay] {
        get {
            let arr = Array(self.days)
            return arr.sorted(by: <)
        }
    }
    
    func hasDay(_ day: TimeMatrixDay) -> Bool {
        return days.contains(day)
    }
    
    
    // MARK: - Variables
    
    private var days = Set<TimeMatrixDay>()
    private var nonPreferredDays = Set<TimeMatrixDay>()
    var cells = [TimeMatrixDay: [TimeMatrixCellModel]]()
    
    var dayListeners = WeakSet<TimeMatrixModelDayListener>()
    var preferredDayListeners = WeakSet<TimeMatrixModelPreferredDayListener>()
    
    
    // MARK: - TimeMatrixDay handlers
    
    func add(day: TimeMatrixDay, isPreferred: Bool = false) {
        var dayCells = self.cells[day]
        if dayCells == nil {
            dayCells = [TimeMatrixCellModel]()
            dayCells!.reserveCapacity(TimeMatrixModel.cellsPerDay)
            for index in 0..<TimeMatrixModel.cellsPerDay {
                let cell = TimeMatrixCellModel(timeSlot: index)
                dayCells!.append(cell)
            }
            self.cells[day] = dayCells
        }
        
        if !isPreferred {
            self.nonPreferredDays.insert(day)
        }
        if days.insert(day).inserted {
            self.informOnAdded(day: day, cellModels: dayCells!)
        }
    }

    func remove(day: TimeMatrixDay, isPreferred: Bool = false) {
        if day == self.preferredDay {
            if isPreferred {
                self.preferredDay = nil
            }
            else {
                return
            }
        }
            
        if !isPreferred {
            self.nonPreferredDays.remove(day)
        }
        
        if days.remove(day) != nil {
            self.informOnRemoved(day: day)
        }
    }
    
    private func informOnAdded(day: TimeMatrixDay, cellModels: [TimeMatrixCellModel]) {
        var index = 0
        if let i = self.activeDays.index(of: day) {
            index = i
        }
        for listener in self.dayListeners {
            listener.onAdded(day: day, cellModels: cellModels, atIndex: index)
        }
    }
    
    private func informOnRemoved(day: TimeMatrixDay) {
        for listener in self.dayListeners {
            listener.onRemoved(day: day)
        }
    }
    
    private func informOnChange(preferredDay: TimeMatrixDay?) {
        for listener in self.preferredDayListeners {
            listener.onChange(preferredDay: preferredDay)
        }
    }
}
