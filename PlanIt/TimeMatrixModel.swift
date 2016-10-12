//
//  TimeMatrixModel.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import Foundation

protocol TimeMatrixModelDayListener: class {
    func onAdded(day: TimeMatrixDay, cellModels: [TimeMatrixCellModel])
    func onRemoved(day: TimeMatrixDay)
}

class TimeMatrixModel {
    static let resolution = 4
    
    var cellsPerDay: Int {
        get {
            return TimeMatrixModel.resolution * 24
        }
    }
    
    var activeDays: [TimeMatrixDay] {
        get {
            let arr = Array(self.days)
            return arr.sorted(by: { (lhs, rhs) -> Bool in
                return lhs < rhs
            })
        }
    }
    
    private var dayListeners = [TimeMatrixModelDayListener]()
    
    private var days = Set<TimeMatrixDay>()
    var cells = [TimeMatrixDay: [TimeMatrixCellModel]]()
    
    func add(day: TimeMatrixDay) {
        var dayCells = self.cells[day]
        if dayCells == nil {
            dayCells = [TimeMatrixCellModel]()
            dayCells!.reserveCapacity(self.cellsPerDay)
            for index in 0..<self.cellsPerDay {
                let cell = TimeMatrixCellModel(timeSlot: index)
                dayCells!.append(cell)
            }
            self.cells[day] = dayCells
        }
        
        if days.insert(day).inserted {
            self.informOnAdded(day: day, cellModels: dayCells!)
        }
    }

    func remove(day: TimeMatrixDay) -> Bool {
        if days.remove(day) != nil {
            self.informOnRemoved(day: day)
            return true;
        }
        return false
    }
    
    func add(dayListener: TimeMatrixModelDayListener) {
        if !self.dayListeners.contains(where: {(l) -> Bool in
            l === dayListener
        }) {
            self.dayListeners.append(dayListener)
        }
    }
    
    func remove(dayListener: TimeMatrixModelDayListener) {
        if let index = self.dayListeners.index(where: {(l) -> Bool in
            l === dayListener
        }) {
            self.dayListeners.remove(at: index)
        }
    }
    
    private func informOnAdded(day: TimeMatrixDay, cellModels: [TimeMatrixCellModel]) {
        for listener in self.dayListeners {
            listener.onAdded(day: day, cellModels: cellModels)
        }
    }
    
    private func informOnRemoved(day: TimeMatrixDay) {
        for listener in self.dayListeners {
            listener.onRemoved(day: day)
        }
    }
}
