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

class TimeMatrixModel: NSObject {
    let resolution = 4
    
    var cellsPerDay: Int {
        get {
            return resolution * 24
        }
    }
    
    var activeDays: [TimeMatrixDay] {
        get {
            let arr = Array(days)
            return arr.sorted(by: { (lhs, rhs) -> Bool in
                return lhs.toString < rhs.toString
            })
        }
    }
    
    private var dayListeners = [TimeMatrixModelDayListener]()
    
    private var days = Set<TimeMatrixDay>()
    var cells = [TimeMatrixDay: [TimeMatrixCellModel]]()
    
    func add(day: TimeMatrixDay) {
        var cells = self.cells[day]
        if cells == nil {
            cells = [TimeMatrixCellModel]()
            cells!.reserveCapacity(self.cellsPerDay)
            for _ in 1...self.cellsPerDay {
                cells!.append(TimeMatrixCellModel())
            }
            self.cells[day] = cells
        }
        
        if days.insert(day).inserted {
            self.informOnAdded(day: day, cellModels: cells!)
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
