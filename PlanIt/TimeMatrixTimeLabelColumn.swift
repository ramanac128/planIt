//
//  TimeMatrixTimeLabelColumn.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/12/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixTimeLabelColumn: UIStackView {
    
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
        self.axis = .vertical
        
        let resolution = TimeMatrixDisplayManager.instance.resolution
        let labelSkips = TimeMatrixDisplayManager.instance.selectionCellsPerTimeLabel
        let resolutionInt = resolution.rawValue * 4
        let cellHeight = TimeMatrixDisplayManager.minimumCellHeight + (CGFloat(resolutionInt - 1) * TimeMatrixDisplayManager.cellHeightIncrement)
        
        let skip = Int(resolutionInt) * labelSkips
        var index = 0
        while index < TimeMatrixModel.cellsPerDay {
            let cell = TimeMatrixTimeLabelCell(index: index, height: cellHeight)
            self.addArrangedSubview(cell)
            index += skip
        }
    }
    
    func cellHeight(resolution: TimeMatrixDisplayManager.Resolution) {
        
    }
}
