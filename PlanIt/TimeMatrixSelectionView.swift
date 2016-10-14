//
//  TimeMatrixSelectionView.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixSelectionView: UIView, TimeMatrixResolutionListener {
    
    var model: TimeMatrixModel {
        didSet {
            if oldValue !== model {
                oldValue.dayListeners.remove(self)
                for dayView in self.selectionDayViews.values {
                    self.columnStack.removeArrangedSubview(dayView)
                    dayView.removeFromSuperview()
                }
                self.selectionDayViews.removeAll()
                self.attachToModel()
                self.setNeedsLayout()
            }
        }
    }
    
    var columnStack = UIStackView()
    var timeLabelColumn = TimeMatrixTimeLabelColumn()
    var selectionDayViews = [TimeMatrixDay: TimeMatrixDaySelectionColumn]()
    
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
        self.columnStack.alignment = .fill
        self.columnStack.distribution = .fillEqually
        self.columnStack.spacing = 0
        self.columnStack.axis = .horizontal
        self.columnStack.translatesAutoresizingMaskIntoConstraints = false
        
        self.makeTimeLabelColumnStack(resolution: TimeMatrixDisplayManager.instance.resolution)
        self.addSubview(self.columnStack)
        
        let leading = NSLayoutConstraint(item: self.columnStack, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: self.columnStack, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: self.columnStack, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: self.columnStack, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
        
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
    
    private func makeTimeLabelColumnStack(resolution: TimeMatrixDisplayManager.Resolution) {
        self.columnStack.removeArrangedSubview(self.timeLabelColumn)
        self.timeLabelColumn.removeFromSuperview()
        self.timeLabelColumn = TimeMatrixTimeLabelColumn()
        self.columnStack.insertArrangedSubview(self.timeLabelColumn, at: 0)
    }
    
    private func clearDays() {
        self.selectionDayViews.removeAll()
        for index in 1..<self.columnStack.arrangedSubviews.count {
            self.columnStack.removeArrangedSubview(self.columnStack.arrangedSubviews[index])
        }
    }
    
    func onChange(resolution: TimeMatrixDisplayManager.Resolution) {
        self.makeTimeLabelColumnStack(resolution: resolution)
        self.setNeedsDisplay()
    }
    
    override func setNeedsDisplay() {
        for dayView in self.selectionDayViews.values {
            dayView.setNeedsDisplay()
        }
        super.setNeedsDisplay()
    }
}

extension TimeMatrixSelectionView: TimeMatrixModelDayListener {
    
    func onAdded(day: TimeMatrixDay, cellModels: [TimeMatrixCellModel], atIndex index: Int) {
        if let oldDayView = self.selectionDayViews[day] {
            self.columnStack.removeArrangedSubview(oldDayView)
            oldDayView.removeFromSuperview()
        }
        
        let dayView = TimeMatrixDaySelectionColumn(day: day, cellModels: cellModels)
        self.selectionDayViews[day] = dayView
        self.columnStack.insertArrangedSubview(dayView, at: index + 1)
    }
    
    func onRemoved(day: TimeMatrixDay) {
        if let dayView = self.selectionDayViews.removeValue(forKey: day) {
            self.columnStack.removeArrangedSubview(dayView)
            dayView.removeFromSuperview()
        }
    }
}
