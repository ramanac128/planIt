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
    
    // MARK: - Properties
    
    @IBOutlet weak var dayNumber: UILabel!
    
    var day: TimeMatrixDay!
    
    // MARK: - Variables
    
    var isToday = false
    var isPreferredDay = false
    var position = SelectionRangePosition.none
    
    
    // MARK: - Initialization
    
    func setupCellBeforeDisplay(cellState: CellState) {
        let displayManager = CalendarViewDisplayManager.instance
        let today = TimeMatrixDay(date: Date())
        self.day = TimeMatrixDay(date: cellState.date)
        self.isToday = (self.day == today)
        
        self.dayNumber.text =  cellState.text
        self.configureTextColor(cellState: cellState)
        
        if let model = displayManager.model {
            self.isPreferredDay = (model.preferredDay == self.day)
            self.position = self.getPosition()
            self.isUserInteractionEnabled = (self.day >= today && (displayManager.configuration == .preferredDate || !self.isPreferredDay))
        }
        else {
            self.isUserInteractionEnabled = false
        }
    }
    
    func configureTextColor(cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            self.dayNumber.textColor = CalendarViewDisplayManager.thisMonthCellTextColor
        } else {
            self.dayNumber.textColor = CalendarViewDisplayManager.otherMonthCellTextColor
        }
    }
    
    func getPosition() -> SelectionRangePosition {
        if let model = CalendarViewDisplayManager.instance.model {
            if model.hasDay(self.day) {
                let leftDay = TimeMatrixDay(from: self.day, byAdding: .day, value: -1)
                let hasLeft = model.hasDay(leftDay)
                
                let rightDay = TimeMatrixDay(from: self.day, byAdding: .day, value: 1)
                let hasRight = model.hasDay(rightDay)
                
                if hasLeft {
                    return (hasRight ? .middle : .right)
                }
                return (hasRight ? .left : .full)
            }
        }
            
        return .none
    }
    
    
    // MARK: - TimeMatrixDay handling
    
    func onChange(preferredDay: TimeMatrixDay?) {
        self.isPreferredDay = (preferredDay == self.day);
    }
    
    
    // MARK: - Layout and display
    
    override func layoutSubviews() {
        setNeedsDisplay()
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
        if self.isPreferredDay {
            self.drawPreferredDayIndicator(context: context)
        }
        
        super.draw(rect)
    }
    
    func drawBackground(context: CGContext) {
        context.setFillColor(UIColor.white.cgColor)
        context.fill(self.bounds)
    }
    
    func drawTodayIndicator(context: CGContext) {
        let yPos = self.bounds.height * CalendarViewDisplayManager.selectedCellYPosPct - (CalendarViewDisplayManager.todayCellStrokeWidth / 2)
        let height = self.bounds.height * CalendarViewDisplayManager.selectedCellHeightPct + CalendarViewDisplayManager.todayCellStrokeWidth
        
        context.addEllipse(in: ellipseRect(yPos: yPos, height: height))
        context.setStrokeColor(CalendarViewDisplayManager.todayCellStrokeColor)
        context.setLineWidth(CalendarViewDisplayManager.todayCellStrokeWidth)
        context.drawPath(using: .stroke)
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
            return
        }
        
        context.setFillColor(CalendarViewDisplayManager.selectedCellColor)
        context.drawPath(using: .fill)
    }
    
    func drawPreferredDayIndicator(context: CGContext) {
        let yPos = self.bounds.height * CalendarViewDisplayManager.selectedCellYPosPct
        let height = self.bounds.height * CalendarViewDisplayManager.selectedCellHeightPct
        
        context.addEllipse(in: ellipseRect(yPos: yPos, height: height))
        context.setFillColor(CalendarViewDisplayManager.preferredDateCellColor)
        context.drawPath(using: .fill)
    }
    
    func ellipseRect(yPos: CGFloat, height: CGFloat) -> CGRect {
        let xPos = (self.bounds.width - height) / 2
        let rect = CGRect(x: xPos, y: yPos, width: height, height: height)
        return rect
    }
}
