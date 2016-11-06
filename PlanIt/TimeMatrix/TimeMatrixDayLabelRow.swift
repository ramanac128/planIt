//
//  TimeMatrixDayLabelRow.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/14/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixDayLabelRow: TimeMatrixDayViewLayoutManager<TimeMatrixDayLabelCell> {
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame, sideView: TimeMatrixResolutionStepperView())
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder, sideView: TimeMatrixResolutionStepperView())
    }
    
    convenience init() {
        self.init(frame: CGRect())
    }
    
    
    // MARK: - Layout and display
    
    override func makeDayView(day: TimeMatrixDay, cellModels: [TimeMatrixCellModel]) -> TimeMatrixDayLabelCell {
        return TimeMatrixDayLabelCell(day: day)
    }
}
