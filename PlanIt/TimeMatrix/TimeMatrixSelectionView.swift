//
//  TimeMatrixSelectionView.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixSelectionView: TimeMatrixDayViewLayoutManager<TimeMatrixDaySelectionColumn> {
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame, sideView: TimeMatrixTimeLabelColumn())
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, sideView: TimeMatrixTimeLabelColumn())
    }
    
    convenience init() {
        self.init(frame: CGRect())
    }
    
    
    // MARK: - Layout and display
    
    override func makeDayView(day: TimeMatrixDay, cellModels: [TimeMatrixCellModel]) -> TimeMatrixDaySelectionColumn {
        return TimeMatrixDaySelectionColumn(day: day, cellModels: cellModels)
    }
    
    override func setNeedsDisplay() {
        for tuple in self.dayViews.values {
            if let selectionColumn = tuple.view.value {
                selectionColumn.setNeedsDisplay()
            }
        }
        super.setNeedsDisplay()
    }
}
