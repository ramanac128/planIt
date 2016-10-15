//
//  TimeMatrixSelectionView.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixSelectionView: UIView, TimeMatrixModelDayListener, TimeMatrixResolutionListener {
    
    // MARK: - Subviews
    
    private weak var columnStack: UIStackView!
    private weak var timeLabelColumn: TimeMatrixTimeLabelColumn!
    private var selectionDayViews = [TimeMatrixDay: Weak<TimeMatrixDaySelectionColumn>]()
    
    private weak var heightConstraint: NSLayoutConstraint!
    
    
    // MARK: - Properties
    
    var model: TimeMatrixModel {
        didSet {
            if oldValue !== model {
                oldValue.dayListeners.remove(self)
                for weakDayView in self.selectionDayViews.values {
                    let dayView = weakDayView.value!
                    self.columnStack.removeArrangedSubview(dayView)
                    dayView.removeFromSuperview()
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
    
    required init?(coder aDecoder: NSCoder) {
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
        let columnStack = UIStackView()
        columnStack.alignment = .fill
        columnStack.distribution = .fillEqually
        columnStack.spacing = 0
        columnStack.axis = .horizontal
        columnStack.translatesAutoresizingMaskIntoConstraints = false
        self.columnStack = columnStack
        
        let timeLabelColumn = TimeMatrixTimeLabelColumn()
        timeLabelColumn.translatesAutoresizingMaskIntoConstraints = false
        self.timeLabelColumn = timeLabelColumn
        
        self.translatesAutoresizingMaskIntoConstraints = false
        columnStack.addArrangedSubview(timeLabelColumn)
        self.addSubview(columnStack)
        
        let leading = NSLayoutConstraint(item: self.columnStack, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: self.columnStack, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: self.columnStack, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: self.columnStack, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        
        let resolution = TimeMatrixDisplayManager.instance.resolution
        let viewHeight = self.heightForResolution(resolution)
        let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewHeight)
        self.heightConstraint = height
        
        NSLayoutConstraint.activate([leading, trailing, top, bottom, height])
        
        
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
        if self.columnStack != nil && self.timeLabelColumn != nil {
            self.columnStack.removeArrangedSubview(self.timeLabelColumn)
            self.timeLabelColumn.removeFromSuperview()
        }
        let timeLabelColumn = TimeMatrixTimeLabelColumn()
        self.timeLabelColumn = timeLabelColumn
        self.columnStack.insertArrangedSubview(timeLabelColumn, at: 0)
    }
    
    private func clearDays() {
        self.selectionDayViews.removeAll()
        for index in 1..<self.columnStack.arrangedSubviews.count {
            let selectionView = self.columnStack.arrangedSubviews[index]
            self.columnStack.removeArrangedSubview(selectionView)
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
        for dayView in self.selectionDayViews.values {
            dayView.value!.setNeedsDisplay()
        }
        super.setNeedsDisplay()
    }
    
    
    // MARK: - TimeMatrixResolutionListener protocol methods
    
    func onChange(resolution: TimeMatrixDisplayManager.Resolution, previous: TimeMatrixDisplayManager.Resolution) {
        let height = self.heightForResolution(resolution)
        self.heightConstraint.constant = height
        self.setNeedsDisplay()
    }
    
    // MARK: - TimeMatrixModelDayListener protocol methods
    
    func onAdded(day: TimeMatrixDay, cellModels: [TimeMatrixCellModel], atIndex index: Int) {
        if let oldWeakDayView = self.selectionDayViews[day] {
            let oldDayView = oldWeakDayView.value!
            self.columnStack.removeArrangedSubview(oldDayView)
            oldDayView.removeFromSuperview()
        }
        
        let dayView = TimeMatrixDaySelectionColumn(day: day, cellModels: cellModels)
        let weakDayView = Weak<TimeMatrixDaySelectionColumn>(value: dayView)
        self.selectionDayViews[day] = weakDayView
        self.columnStack.insertArrangedSubview(dayView, at: index + 1)
    }
    
    func onRemoved(day: TimeMatrixDay) {
        if let weakDayView = self.selectionDayViews.removeValue(forKey: day) {
            let dayView = weakDayView.value!
            self.columnStack.removeArrangedSubview(dayView)
            dayView.removeFromSuperview()
        }
    }
}
