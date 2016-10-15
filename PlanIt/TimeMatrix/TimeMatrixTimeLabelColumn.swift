//
//  TimeMatrixTimeLabelColumn.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/12/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixTimeLabelColumn: UIView, TimeMatrixResolutionListener {
    
    // MARK: - Subviews
    
    private var timeLabelCells = [TimeMatrixTimeLabelCell]() // strong refs for view recycling
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        var viewDict = [String: UIView]()
        var vString = "V:|"
        
        let numCells = TimeMatrixModel.cellsPerDay
        self.timeLabelCells.reserveCapacity(numCells)
        for index in 0..<numCells {
            let viewString = String(format: "v%d", index)
            let cell = TimeMatrixTimeLabelCell(index: index)
            self.addSubview(cell)
            self.timeLabelCells.append(cell)
            
            viewDict[viewString] = cell
            vString += String(format: "-0-[%@]", viewString)
        }
        vString += "-0-|"
        
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: vString, options: .directionLeftToRight, metrics: nil, views: viewDict)
        self.addConstraints(constraints)
        
        let resolution = TimeMatrixDisplayManager.instance.resolution
        self.onChange(resolution: resolution, previous: TimeMatrixDisplayManager.Resolution.fifteenMinutes)
        
        TimeMatrixDisplayManager.instance.resolutionListeners.insert(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = self.bounds.width
        for cell in self.timeLabelCells {
            cell.frame = CGRect(x: 0, y: cell.frame.origin.y, width: width, height: cell.frame.size.height)
        }
    }
    
    
    // MARK: - TimeMatrixResolutionListener protocol methods
    
    func onChange(resolution: TimeMatrixDisplayManager.Resolution, previous: TimeMatrixDisplayManager.Resolution) {
        let newMod = Int(resolution.rawValue * 4)
        let oldMod = Int(previous.rawValue * 4)
        
        let cellHeight = TimeMatrixTimeLabelCell.cellHeight(resolution: resolution)
        
        var index = 0
        if newMod < oldMod {
            while index < self.timeLabelCells.count {
                let cell = self.timeLabelCells[index]
                cell.setHeight(height: cellHeight)
                index += newMod
            }
        }
        else {
            while index < self.timeLabelCells.count {
                let cell = self.timeLabelCells[index]
                if index % newMod > 0 {
                    cell.setHeight(height: 0)
                }
                else {
                    cell.setHeight(height: cellHeight)
                }
                index += oldMod
            }
        }
    }
}
