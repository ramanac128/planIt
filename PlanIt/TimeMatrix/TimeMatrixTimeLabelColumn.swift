//
//  TimeMatrixTimeLabelColumn.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/12/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixTimeLabelColumn: UIStackView, TimeMatrixResolutionListener {
    
    // MARK: - Subviews
    
    private var timeLabelCells = [TimeMatrixTimeLabelCell]() // strong refs for view recycling
    
    
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
        
        let numCells = TimeMatrixModel.cellsPerDay
        self.timeLabelCells.reserveCapacity(numCells)
        for index in 0..<numCells {
            let cell = TimeMatrixTimeLabelCell(index: index)
            self.timeLabelCells.append(cell)
        }
        
        let resolution = TimeMatrixDisplayManager.instance.resolution
        let skip = Int(resolution.rawValue * 4)
        var index = 0
        while index < numCells {
            let cell = self.timeLabelCells[index]
            self.addArrangedSubview(cell)
            index += skip
        }
        
        TimeMatrixDisplayManager.instance.resolutionListeners.insert(self)
    }
    
    
    // MARK: - TimeMatrixResolutionListener protocol methods
    
    func onChange(resolution: TimeMatrixDisplayManager.Resolution, previous: TimeMatrixDisplayManager.Resolution) {
        let newMod = Int(resolution.rawValue * 4)
        let oldMod = Int(previous.rawValue * 4)
        
        var index = 0
        if newMod < oldMod {
            while index < timeLabelCells.count {
                let cell = self.timeLabelCells[index]
                if index % oldMod > 0 {
                    let insertionPoint = index / newMod
                    self.insertArrangedSubview(cell, at: insertionPoint)
                }
                index += newMod
            }
        }
        else {
            while index < timeLabelCells.count {
                let cell = self.timeLabelCells[index]
                if index % newMod > 0 {
                    self.removeArrangedSubview(cell)
                    cell.removeFromSuperview()
                }
                index += oldMod
            }
        }
    }
}
