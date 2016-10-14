//
//  TimeMatrixTimeLabelColumn.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/12/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixTimeLabelColumn: UIStackView {
    
    // MARK: - Initialization
    
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
        let skip = Int(resolution.rawValue * 4)
        let cellHeightIncrement = TimeMatrixDisplayManager.cellHeightIncrement * CGFloat(skip - 1)
        let cellHeight = TimeMatrixDisplayManager.cellHeightMinimum + cellHeightIncrement
        
        var index = 0
        while index < TimeMatrixModel.cellsPerDay {
            let cell = TimeMatrixTimeLabelCell(index: index, height: cellHeight)
            self.addArrangedSubview(cell)
            index += skip
        }
    }
}
