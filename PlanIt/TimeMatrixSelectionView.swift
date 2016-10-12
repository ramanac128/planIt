//
//  TimeMatrixSelectionView.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixSelectionView: UIView {
    var columnStack = UIStackView()
    var labelCellRowStack = UIStackView()
    
    var selectionDayViews = [TimeMatrixSelectionDayView]()
    
    var model: TimeMatrixModel? {
        didSet {
            oldValue?.remove(dayListener: self)
            self.clearDays()
            
            self.model!.add(dayListener: self)
            for (day, cells) in self.model!.cells {
                self.onAdded(day: day, cellModels: cells)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.makeSubviews()
        self.makeLayout()
    }
    
    private func makeSubviews() {
        self.columnStack.alignment = .fill
        self.columnStack.distribution = .fillEqually
        self.columnStack.spacing = 0
        self.columnStack.axis = .horizontal
        self.columnStack.translatesAutoresizingMaskIntoConstraints = false
        
        self.labelCellRowStack.alignment = .fill
        self.labelCellRowStack.distribution = .fillEqually
        self.labelCellRowStack.spacing = 0
        self.labelCellRowStack.axis = .vertical
        self.fillLabelCellRowStack()
        
        self.columnStack.addArrangedSubview(self.labelCellRowStack)
        self.addSubview(self.columnStack)
    }
    
    private func makeLayout() {
        let leading = NSLayoutConstraint(item: self.columnStack, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: self.columnStack, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: self.columnStack, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: self.columnStack, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
    }
    
    private func fillLabelCellRowStack() {
        for dayPart in ["am","pm"] {
            for hour in ["12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"] {
                for minute in ["00","30"] {
                    //                    let cell = TimeMatrixLabelCell()
                    //                    cell.timeLabel.text = "\(hour):\(minute)\(dayPart)"
                    let cell = UILabel()
                    cell.text = "\(hour):\(minute)\(dayPart)"
                    cell.textAlignment = .center
                    labelCellRowStack.addArrangedSubview(cell)
                }
            }
            
        }
    }
    
    private func clearDays() {
        self.selectionDayViews.removeAll()
        for index in 1..<self.columnStack.arrangedSubviews.count {
            self.columnStack.removeArrangedSubview(self.columnStack.arrangedSubviews[index])
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */}

extension TimeMatrixSelectionView: TimeMatrixModelDayListener {
    
    func onAdded(day: TimeMatrixDay, cellModels: [TimeMatrixCellModel]) {
        var index = 0
        while index < self.selectionDayViews.count && self.selectionDayViews[index].day < day {
            index += 1
        }
        let dayView = TimeMatrixSelectionDayView(day: day, cellModels: cellModels)
        self.selectionDayViews.insert(dayView, at: index)
        self.columnStack.insertArrangedSubview(dayView, at: index + 1)
    }
    
    func onRemoved(day: TimeMatrixDay) {
        for index in 0..<self.selectionDayViews.count {
            if self.selectionDayViews[index].day == day {
                let dayView = self.selectionDayViews.remove(at: index)
                self.columnStack.removeArrangedSubview(dayView)
                return
            }
        }
    }
}
