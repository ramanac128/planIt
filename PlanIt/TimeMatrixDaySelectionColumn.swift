//
//  TimeMatrixDaySelectionColumn.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/11/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixDaySelectionColumn: UIView, TimeMatrixResolutionListener {
    var day: TimeMatrixDay
    
    var cellModels: [TimeMatrixCellModel]
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented, use init(frame:day:cellModels:)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented, use init(day:cellModels)")
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
        self.backgroundColor = UIColor(cgColor: TimeMatrixDisplayManager.cellBackgroundColorUnavailable)
    }
    
    func touchResult(at point: CGPoint) -> (index: Int, cell: TimeMatrixCellModel)? {
        if point.y < 0 || point.y > self.bounds.height {
            return nil
        }
        let index = Int(point.y / self.bounds.height * CGFloat(self.cellModels.count))
        let cell = self.cellModels[index]
        return (index: index, cell: cell)
    }
    
    func timeSlot(at point: CGPoint) -> Int? {
        if point.y < 0 || point.y > self.bounds.height {
            return nil
        }
        return Int(point.y / self.bounds.height * CGFloat(self.cellModels.count))
    }
    
    func fillColor(from: TimeMatrixCellModel.State) -> CGColor {
        switch (from) {
        case .available:
            return TimeMatrixDisplayManager.cellBackgroundColorAvailable
        case .preferred:
            return TimeMatrixDisplayManager.cellBackgroundColorPreferred
        case .unavailable:
            return TimeMatrixDisplayManager.cellBackgroundColorUnavailable
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
        
        let first = Int(rect.origin.y / self.bounds.height * numCells)
        let end = first + Int(ceil(rect.height / self.bounds.height * numCells))
        
        self.drawBlocks(from: first, to: end, cellHeight: cellHeight, context: context)
        self.drawBorders(from: first, to: end, cellHeight: cellHeight, context: context)
    }
    
    private func drawBlocks(from start: Int, to end: Int, cellHeight: CGFloat, context: CGContext) {
        for var index in start..<end {
            let state = self.cellModels[index].currentState
            if state == .unavailable {
                index += 1
            }
            else {
                var next = index + 1
                while next < end && self.cellModels[next].currentState == state {
                    next += 1
                }
                self.drawBlock(from: index, to: next, cellHeight: cellHeight, state: state, context: context)
                index = next
            }
        }
    }
    
    private func drawBlock(from start: Int, to end: Int, cellHeight: CGFloat, state: TimeMatrixCellModel.State, context: CGContext) {
        let top = cellHeight * CGFloat(start)
        let height = cellHeight * CGFloat(end - start)
        let rectangle = CGRect(x: 0, y: top, width: self.bounds.width, height: height)
        
        context.setFillColor(self.fillColor(from: state))
        context.addRect(rectangle)
        context.drawPath(using: .fill)
    }
    
    private func drawBorders(from start: Int, to end: Int, cellHeight: CGFloat, context: CGContext) {
        let resolution = TimeMatrixDisplayManager.instance.resolution
        let skip = Int(resolution.rawValue * 4)
        let mod = Int(ceil(1 / resolution.rawValue))
        
        var index = start, modIndex = start
        while index < end {
            let yPos = CGFloat(index) * cellHeight
            context.move(to: CGPoint(x: 0, y: yPos))
            context.addLine(to: CGPoint(x: self.bounds.width, y: yPos))
            if modIndex % mod == 0 {
                context.setStrokeColor(TimeMatrixDisplayManager.cellStrokeColorMajorTick)
                context.setLineWidth(TimeMatrixDisplayManager.cellStrokeWidthMajorTick)
            }
            else {
                context.setStrokeColor(TimeMatrixDisplayManager.cellStrokeColorMinorTick)
                context.setLineWidth(TimeMatrixDisplayManager.cellStrokeWidthMinorTick)
            }
            context.drawPath(using: .stroke)
            index += skip
            modIndex += 1
        }
        
        let top = CGFloat(start) * cellHeight
        let bottom = CGFloat(end) * cellHeight
        
        context.move(to: CGPoint(x: 0, y: top))
        context.addLine(to: CGPoint(x: 0, y: bottom))
        context.setStrokeColor(TimeMatrixDisplayManager.cellStrokeColorDayBorder)
        context.setLineWidth(TimeMatrixDisplayManager.cellStrokeWidthDayBorder)
        context.drawPath(using: .stroke)
    }
    
    func onChange(resolution: TimeMatrixDisplayManager.Resolution) {
        self.setNeedsDisplay()
    }
}
