//
//  TimeMatrixDayLabelRow.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/14/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixDayLabelRow: UIStackView, TimeMatrixModelDayListener {
    var dayLabelCells = [TimeMatrixDay: TimeMatrixDayLabelCell]()
    
    var model: TimeMatrixModel? {
        didSet {
            if oldValue !== model {
                if oldValue != nil {
                    oldValue!.dayListeners.remove(self)
                    for cell in self.dayLabelCells.values {
                        self.removeArrangedSubview(cell)
                    }
                    self.dayLabelCells.removeAll()
                }
                if let model = self.model {
                    self.attachToModel(model)
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        self.alignment = .fill
        self.distribution = .fillEqually
        self.spacing = 0
        self.axis = .horizontal
        
        self.addArrangedSubview(UIView())
    }
    
    private func attachToModel(_ model: TimeMatrixModel) {
        model.dayListeners.insert(self)
        let days = model.activeDays
        for index in 0..<days.count {
            self.onAdded(day: days[index], cellModels: [], atIndex: index)
        }
    }
    
    func onAdded(day: TimeMatrixDay, cellModels: [TimeMatrixCellModel], atIndex index: Int) {
        if self.dayLabelCells[day] == nil {
            let cell = TimeMatrixDayLabelCell(day: day)
            self.dayLabelCells[day] = cell
            self.insertArrangedSubview(cell, at: index + 1)
        }
    }
    
    func onRemoved(day: TimeMatrixDay) {
        if let cell = self.dayLabelCells.removeValue(forKey: day) {
            self.removeArrangedSubview(cell)
        }
    }
}
