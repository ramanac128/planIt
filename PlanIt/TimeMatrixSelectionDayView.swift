//
//  TimeMatrixSelectionDayView.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/11/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixSelectionDayView: UIView {
    static let bgUnavailable = UIColor.red.cgColor //UIColor(red: 1, green: 150/255, blue: 150/255, alpha: 1).cgColor
    static let bgAvailable = UIColor.yellow.cgColor
    static let bgPreferred = UIColor.green.cgColor
    
    static let minorTicksPerMajorTick = 1
    static let strokeWidthMajorTick = CGFloat(1.0)
    static let strokeWidthMinorTick = CGFloat(0.5)
    static let strokeColorMajorTick = UIColor.black.cgColor
    static let strokeColorMinorTick = UIColor.gray.cgColor
    
    static let strokeWidthDayBorder = CGFloat(4.0)
    static let strokeColorDayBorder = UIColor.white.cgColor

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
        
        let first = Int(rect.origin.y / self.bounds.height * numCells)
        let end = first + Int(ceil(rect.height / self.bounds.height * numCells))
        
        self.drawBlocks(from: first, to: end, cellHeight: cellHeight, context: context)
        self.drawBorders(from: first, to: end, cellHeight: cellHeight, context: context)
    }
    
    private func drawBlocks(from start: Int, to end: Int, cellHeight: CGFloat, context: CGContext) {
        for var index in start..<end {
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
    
    private func drawBlock(from start: Int, to end: Int, cellHeight: CGFloat, state: TimeMatrixCellModel.State, context: CGContext) {
        let top = cellHeight * CGFloat(start)
        let height = cellHeight * CGFloat(end - start)
        let rectangle = CGRect(x: 0, y: top, width: self.bounds.width, height: height)
        
        context.setFillColor(self.fillColor(from: state))
        context.addRect(rectangle)
        context.drawPath(using: .fill)
    }
    
    private func drawBorders(from start: Int, to end: Int, cellHeight: CGFloat, context: CGContext) {
        let mod = TimeMatrixSelectionDayView.minorTicksPerMajorTick + 1
        
        for index in start...end {
            let yPos = CGFloat(index) * cellHeight
            context.move(to: CGPoint(x: 0, y: yPos))
            context.addLine(to: CGPoint(x: self.bounds.width, y: yPos))
            if index % mod == 0 {
                context.setStrokeColor(TimeMatrixSelectionDayView.strokeColorMajorTick)
                context.setLineWidth(TimeMatrixSelectionDayView.strokeWidthMajorTick)
            }
            else {
                context.setStrokeColor(TimeMatrixSelectionDayView.strokeColorMinorTick)
                context.setLineWidth(TimeMatrixSelectionDayView.strokeWidthMinorTick)
            }
            context.drawPath(using: .stroke)
        }
        
        let top = CGFloat(start) * cellHeight
        let bottom = CGFloat(end) * cellHeight
        
        context.move(to: CGPoint(x: 0, y: top))
        context.addLine(to: CGPoint(x: 0, y: bottom))
        context.setStrokeColor(TimeMatrixSelectionDayView.strokeColorDayBorder)
        context.setLineWidth(TimeMatrixSelectionDayView.strokeWidthDayBorder)
        context.drawPath(using: .stroke)
    }
}
