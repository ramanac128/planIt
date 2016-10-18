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
            
            let center = NSLayoutConstraint(item: cell, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
            let width = NSLayoutConstraint(item: cell, attribute: .width, relatedBy: .lessThanOrEqual, toItem: self, attribute: .width, multiplier: 0.9, constant: 0)
            self.addConstraints([center, width])
            
            viewDict[viewString] = cell
            vString += String(format: "-0-[%@]", viewString)
        }
        vString += "-0-|"
        
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: vString, options: .directionLeftToRight, metrics: nil, views: viewDict)
        self.addConstraints(constraints)
        
        let resolution = TimeMatrixDisplayManager.instance.resolution
        self.changeResolution(from: TimeMatrixDisplayManager.Resolution.fifteenMinutes, to: resolution)
        
        TimeMatrixDisplayManager.instance.resolutionListeners.insert(self)
    }
    
    
    func changeResolution(from previous: TimeMatrixDisplayManager.Resolution, to current: TimeMatrixDisplayManager.Resolution) {
        let newMod = Int(current.rawValue * 4)
        let oldMod = Int(previous.rawValue * 4)
        let cellHeight = TimeMatrixTimeLabelCell.cellHeight(resolution: current)
        
        self.changeResolutionLoop(newMod: newMod, oldMod: oldMod, cellHeight: cellHeight)
    }
    
    private func changeResolutionLoop(newMod: Int, oldMod: Int, cellHeight: CGFloat) {
        var index = 0
        if newMod < oldMod {
            while index < self.timeLabelCells.count {
                let cell = self.timeLabelCells[index]
                cell.height = cellHeight
                cell.alpha = 1
                index += newMod
            }
        }
        else {
            while index < self.timeLabelCells.count {
                let cell = self.timeLabelCells[index]
                if index % newMod > 0 {
                    cell.height = 0
                    cell.alpha = 0
                }
                else {
                    cell.height = cellHeight
                    cell.alpha = 1
                }
                index += oldMod
            }
        }
    }
    
    
    // MARK: - TimeMatrixResolutionListener protocol methods
    
    func onChange(resolution: TimeMatrixDisplayManager.Resolution, previous: TimeMatrixDisplayManager.Resolution) {
        let newMod = Int(resolution.rawValue * 4)
        let oldMod = Int(previous.rawValue * 4)
        let cellHeight = TimeMatrixTimeLabelCell.cellHeight(resolution: resolution)
        let duration = TimeMatrixDisplayManager.resolutionChangeAnimationDuration
        
        TimeMatrixDisplayManager.instance.informOnRowAnimationBegin()
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            self.changeResolutionLoop(newMod: newMod, oldMod: oldMod, cellHeight: cellHeight)
            TimeMatrixDisplayManager.instance.informOnRowAnimationFrame()
            self.layoutIfNeeded()
        }, completion: {(value: Bool) in
            TimeMatrixDisplayManager.instance.informOnRowAnimationEnd()
        })
    }
}
