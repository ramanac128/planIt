//
//  TimeMatrixSelectionDayView.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/11/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixSelectionDayView: UIView {
    
    static let bgUnavailable = UIColor.red.cgColor
    static let bgAvailable = UIColor.yellow.cgColor
    static let bgPreferred = UIColor.green.cgColor

    var day: TimeMatrixDay
    
    var cellModels: [TimeMatrixCellModel]
    
    override init(frame: CGRect) {
        day = TimeMatrixDay(date: Date())
        cellModels = []
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        day = TimeMatrixDay(date: Date())
        cellModels = []
        super.init(coder: aDecoder)
        self.setup()
    }
    
    init(frame: CGRect, day: TimeMatrixDay, cellModels: [TimeMatrixCellModel]) {
        self.day = day
        self.cellModels = cellModels
        super.init(frame: frame)
        self.setup()
    }
    
    convenience init(day: TimeMatrixDay, cellModels: [TimeMatrixCellModel]) {
        self.init(frame: CGRect(), day: day, cellModels: cellModels)
    }
    
    convenience init() {
        self.init(frame: CGRect(), day: TimeMatrixDay(date: Date()), cellModels: [])
    }
    
    private func setup() {
        self.backgroundColor = UIColor(cgColor: TimeMatrixSelectionDayView.bgUnavailable)
    }
    
    func timeSlot(from: CGPoint) -> Int? {
        if from.y < 0 || from.y > self.bounds.height {
            return nil
        }
        return Int(from.y / self.bounds.height * CGFloat(self.cellModels.count))
    }
    
    func cellModel(from: CGPoint) -> TimeMatrixCellModel? {
        if self.cellModels.isEmpty {
            return nil
        }
        
        if let index = timeSlot(from: from) {
            return self.cellModels[index]
        }
        
        return nil
    }
    
    func fillColor(from: TimeMatrixCellModel.State) -> CGColor {
        switch (from) {
        case .available:
            return TimeMatrixSelectionDayView.bgAvailable
        case .preferred:
            return TimeMatrixSelectionDayView.bgPreferred
        case .unavailable:
            return TimeMatrixSelectionDayView.bgUnavailable
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if self.cellModels.isEmpty || self.bounds.height == 0 {
            return
        }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let numCells = CGFloat(self.cellModels.count)
        let cellHeight = self.bounds.height / numCells
        
        var index = Int(rect.origin.y / self.bounds.height * numCells)
        let end = index + Int(ceil(rect.height / self.bounds.height * numCells))
        
        while index < end {
            let state = self.cellModels[index].displayState
            if state == .unavailable {
                index += 1
            }
            else {
                var next = index + 1
                while next < end && self.cellModels[next].displayState == state {
                    next += 1
                }
                self.drawBlock(from: index, to: next, cellHeight: cellHeight, state: state, context: context)
                index = next
            }
        }
    }
    
    func drawBlock(from: Int, to: Int, cellHeight: CGFloat, state: TimeMatrixCellModel.State, context: CGContext) {
        let top = cellHeight * CGFloat(from)
        let height = cellHeight * CGFloat(to - from)
        let rectangle = CGRect(x: 0, y: top, width: self.bounds.width, height: height)
        
        context.setFillColor(self.fillColor(from: state))
        context.addRect(rectangle)
        context.drawPath(using: .fill)
    }
}
