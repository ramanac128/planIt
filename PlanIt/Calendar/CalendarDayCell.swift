//
//  CalendarDayCell.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/8/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import Foundation
import JTAppleCalendar

class CalendarDayCell: JTAppleDayCellView {
    @IBOutlet weak var dayNumber: UILabel!
    
    var isToday = false
    
    var position = SelectionRangePosition.none
    var selectedItemHeight = CGFloat(0)
    
    func setupCellBeforeDisplay(cellState: CellState, date: Date) {
        let cellDay = TimeMatrixDay(date: date)
        let today = TimeMatrixDay(date: Date())
        self.isToday = (cellDay == today)
        if cellDay < today {
            self.isUserInteractionEnabled = false
        }
        
        self.dayNumber.text =  cellState.text
        self.configureTextColor(cellState: cellState)
        self.position = cellState.selectedPosition()
    }
    
    func configureTextColor(cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            self.dayNumber.textColor = CalendarViewDisplayManager.thisMonthCellTextColor
        } else {
            self.dayNumber.textColor = CalendarViewDisplayManager.otherMonthCellTextColor
        }
    }
    
    func cellSelectionChanged(_ cellState: CellState) {
        self.position = cellState.selectedPosition()
        self.setNeedsDisplay()
    }
    
    func drawBackground(context: CGContext) {
        context.setFillColor(UIColor.white.cgColor)
        context.fill(self.bounds)
    }
    
    func drawSelectionIndicator(context: CGContext) {
        let yPos = self.bounds.height * CalendarViewDisplayManager.selectedCellYPosPct
        let height = self.bounds.height * CalendarViewDisplayManager.selectedCellHeightPct
        
        switch self.position {
        case .full:
            context.addEllipse(in: ellipseRect(yPos: yPos, height: height))
            break
            
        case .left:
            let width = self.bounds.width / 2
            context.addRect(CGRect(x: width, y: yPos, width: width, height: height))
            context.addEllipse(in: ellipseRect(yPos: yPos, height: height))
            break
            
        case .right:
            let width = self.bounds.width / CGFloat(2)
            context.addRect(CGRect(x: 0, y: yPos, width: width, height: height))
            context.addEllipse(in: ellipseRect(yPos: yPos, height: height))
            break
            
        case .middle:
            context.addRect(CGRect(x: 0, y: yPos, width: self.bounds.width, height: height))
            break
            
        default:
            break
        }
        
        context.setFillColor(CalendarViewDisplayManager.selectedCellColor)
        context.drawPath(using: .fill)
    }
    
    func drawTodayIndicator(context: CGContext) {
        let yPos = self.bounds.height * CalendarViewDisplayManager.selectedCellYPosPct - (CalendarViewDisplayManager.todayCellStrokeWidth / 2)
        let height = self.bounds.height * CalendarViewDisplayManager.selectedCellHeightPct + CalendarViewDisplayManager.todayCellStrokeWidth
        
        context.addEllipse(in: ellipseRect(yPos: yPos, height: height))
        context.setStrokeColor(CalendarViewDisplayManager.todayCellStrokeColor)
        context.setLineWidth(CalendarViewDisplayManager.todayCellStrokeWidth)
        context.drawPath(using: .stroke)
    }
    
    func ellipseRect(yPos: CGFloat, height: CGFloat) -> CGRect {
        let xPos = (self.bounds.width - height) / 2
        let rect = CGRect(x: xPos, y: yPos, width: height, height: height)
        return rect
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        self.drawBackground(context: context)
        if self.isToday {
            self.drawTodayIndicator(context: context)
        }
        if self.position != .none {
            self.drawSelectionIndicator(context: context)
        }
        
        super.draw(rect)
    }
    
    override func layoutSubviews() {
        setNeedsDisplay()
    }
}
