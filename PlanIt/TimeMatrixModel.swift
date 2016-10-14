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

class TimeMatrixModel {
    static let cellsPerDay = 24 * 4
    
    var activeDays: [TimeMatrixDay] {
        get {
            let arr = Array(self.days)
            return arr.sorted(by: <)
        }
    }
    
    var dayListeners = WeakSet<TimeMatrixModelDayListener>()
    
    private var days = Set<TimeMatrixDay>()
    var cells = [TimeMatrixDay: [TimeMatrixCellModel]]()
    
    func add(day: TimeMatrixDay) {
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
        
        if days.insert(day).inserted {
            self.informOnAdded(day: day, cellModels: dayCells!)
        }
    }

    func remove(day: TimeMatrixDay) {
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
}
