//
//  CalendarViewDisplayManager.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/3/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class CalendarViewDisplayManager: NSObject {
    static var thisMonthCellTextColor = UIColor.black
    static var otherMonthCellTextColor = UIColor.gray
    
    static var selectedCellColor = UIColor.yellow.cgColor
    static var selectedCellHeightPct = CGFloat(0.65)
    static var selectedCellYPosPct = (CGFloat(1) - CalendarViewDisplayManager.selectedCellHeightPct) / CGFloat(2)
    
    static var todayCellStrokeWidth = CGFloat(3)
    static var todayCellStrokeColor = UIColor(hex: 0x33CCCC).cgColor
}
