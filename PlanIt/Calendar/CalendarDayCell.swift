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
    
    var normalDayColor = UIColor.black
    var weekendDayColor = UIColor.gray
    
    func setupCellBeforeDisplay(cellState: CellState, date: Date) {
        // Setup Cell text
        dayNumber.text =  cellState.text
        
        // Setup text color
        configureTextColor(cellState: cellState)
    }
    
    func configureTextColor(cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            dayNumber.textColor = normalDayColor
        } else {
            dayNumber.textColor = weekendDayColor
        }
    }
}
