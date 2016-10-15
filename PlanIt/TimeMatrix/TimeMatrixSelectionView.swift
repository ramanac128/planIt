//
//  TimeMatrixSelectionView.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixSelectionView: UIStackView, TimeMatrixModelDayListener, TimeMatrixResolutionListener {
    
    // MARK: - Subviews
    
    private weak var timeLabelColumn: TimeMatrixTimeLabelColumn!
    private var selectionDayViews = [TimeMatrixDay: Weak<TimeMatrixDaySelectionColumn>]()
    
    
    // MARK: - Properties
    
    var model: TimeMatrixModel {
        didSet {
            if oldValue !== model {
                oldValue.dayListeners.remove(self)
                for weakDayView in self.selectionDayViews.values {
                    if let dayView = weakDayView.value {
                        self.removeArrangedSubview(dayView)
                        dayView.removeFromSuperview()
                    }
                }
                self.selectionDayViews.removeAll()
                self.attachToModel()
                self.setNeedsLayout()
            }
        }
    }
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented, use init(frame:model:)")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented, use init(model:)")
    }
    
    init(frame: CGRect, model: TimeMatrixModel) {
        self.model = model
        super.init(frame: frame)
        self.setup()
    }
    
    convenience init(model: TimeMatrixModel) {
        self.init(frame: CGRect(), model: model)
    }
    
    private func setup() {
        self.alignment = .fill
        self.distribution = .fillEqually
        self.spacing = 0
        self.axis = .horizontal
        
        let timeLabelColumn = TimeMatrixTimeLabelColumn()
        self.timeLabelColumn = timeLabelColumn
        
        self.addArrangedSubview(timeLabelColumn)
        self.attachToModel()
        
        TimeMatrixDisplayManager.instance.resolutionListeners.insert(self)
    }
    
    private func attachToModel() {
        var index = 0
        let days = self.model.activeDays
        while index < days.count {
            let day = days[index]
            if let cellModels = self.model.cells[day] {
                self.onAdded(day: day, cellModels: cellModels, atIndex: index)
            }
            index += 1
        }
        self.model.dayListeners.insert(self)
    }
    
    private func makeTimeLabelColumn(resolution: TimeMatrixDisplayManager.Resolution) {
        if self.timeLabelColumn != nil {
            self.removeArrangedSubview(self.timeLabelColumn)
            self.timeLabelColumn.removeFromSuperview()
        }
        let timeLabelColumn = TimeMatrixTimeLabelColumn()
        self.timeLabelColumn = timeLabelColumn
        self.insertArrangedSubview(timeLabelColumn, at: 0)
    }
    
    private func clearDays() {
        self.selectionDayViews.removeAll()
        for index in 1..<self.arrangedSubviews.count {
            let selectionView = self.arrangedSubviews[index]
            self.removeArrangedSubview(selectionView)
            selectionView.removeFromSuperview()
        }
    }
    
    
    // MARK: - Layout and display
    
    func heightForResolution(_ resolution: TimeMatrixDisplayManager.Resolution) -> CGFloat {
        let resolutionInt = Int(resolution.rawValue * 4)
        let cellHeightIncrement = TimeMatrixDisplayManager.cellHeightIncrement * CGFloat(resolutionInt - 1)
        let cellHeight = TimeMatrixDisplayManager.cellHeightMinimum + cellHeightIncrement
        let numCells = TimeMatrixModel.cellsPerDay / resolutionInt
        let totalHeight = cellHeight * CGFloat(numCells)
        return totalHeight
    }
    
    override func setNeedsDisplay() {
        for weakDayView in self.selectionDayViews.values {
            if let dayView = weakDayView.value {
                dayView.setNeedsDisplay()
            }
        }
        super.setNeedsDisplay()
    }
    
    
    // MARK: - TimeMatrixResolutionListener protocol methods
    
    func onChange(resolution: TimeMatrixDisplayManager.Resolution, previous: TimeMatrixDisplayManager.Resolution) {
        self.setNeedsDisplay()
    }
    
    // MARK: - TimeMatrixModelDayListener protocol methods
    
    func onAdded(day: TimeMatrixDay, cellModels: [TimeMatrixCellModel], atIndex index: Int) {
        if let oldWeakDayView = self.selectionDayViews[day],
            let oldDayView = oldWeakDayView.value {
            self.removeArrangedSubview(oldDayView)
            oldDayView.removeFromSuperview()
        }
        
        let dayView = TimeMatrixDaySelectionColumn(day: day, cellModels: cellModels)
        let weakDayView = Weak<TimeMatrixDaySelectionColumn>(value: dayView)
        self.selectionDayViews[day] = weakDayView
        self.insertArrangedSubview(dayView, at: index + 1)
    }
    
    func onRemoved(day: TimeMatrixDay) {
        if let weakDayView = self.selectionDayViews.removeValue(forKey: day),
            let dayView = weakDayView.value {
            self.removeArrangedSubview(dayView)
            dayView.removeFromSuperview()
        }
    }
}
