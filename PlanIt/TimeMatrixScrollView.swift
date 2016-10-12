//
//  TimeMatrixScrollView.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixScrollView: UIScrollView {
    
    private let selectionViews = [TimeMatrixSelectionView(), TimeMatrixSelectionView(), TimeMatrixSelectionView()]
    private let contentView = UIStackView()
    
    var panStartPoint: CGPoint?
    var panEndPoint: CGPoint?
    
    var panStartCell: TimeMatrixCellModel?
    var panEndCell: TimeMatrixCellModel?
    
    var panStartDayView: TimeMatrixSelectionDayView?
    var panEndDayView: TimeMatrixSelectionDayView?
    
    var panSelectionState = TimeMatrixCellModel.State.unavailable
    
    var selectedCells = Set<TimeMatrixCellModel>()
    
    var model: TimeMatrixModel? {
        didSet {
            for view in self.selectionViews {
                view.model = self.model
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.makeLayout()
    }
    
    private func setup() {
        let panRecognizer = TimeMatrixPanGestureRecognizer(target: self, action: #selector(TimeMatrixScrollView.handlePan(recognizer:)))
        panRecognizer.delegate = self
        self.addGestureRecognizer(panRecognizer)
        
        // TODO: delete this
        let model = TimeMatrixModel()
        let calendar = Calendar.current
        model.add(day: TimeMatrixDay(date: Date()))
        model.add(day: TimeMatrixDay(date: calendar.date(byAdding: .day, value: 1, to: Date())!))
        model.add(day: TimeMatrixDay(date: calendar.date(byAdding: .day, value: 2, to: Date())!))
        model.add(day: TimeMatrixDay(date: calendar.date(byAdding: .day, value: 4, to: Date())!))
        self.model = model
    }
    
    private func makeLayout() {
        contentView.alignment = .fill
        contentView.distribution = .fillEqually
        contentView.spacing = 0
        contentView.axis = .vertical
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: contentView.frame.size)
        
        for view in self.selectionViews {
            contentView.addArrangedSubview(view)
        }
        
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.clipsToBounds = true
        self.contentSize = contentView.bounds.size
        self.addSubview(contentView)
        self.delegate = self
        
        let leading = NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([leading, trailing, width])
    }
    
    func selectionState(from: TimeMatrixCellModel.State) -> TimeMatrixCellModel.State {
        switch from {
        case .available, .preferred:
            return TimeMatrixCellModel.State.unavailable
        case .unavailable:
            return TimeMatrixCellModel.State.available
        }
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        let posInSelf = recognizer.location(in: self)
        let view = self.hitTest(posInSelf, with: nil)
        
        if let dayView = view as? TimeMatrixSelectionDayView {
            switch (recognizer.state) {
            case .began:
                self.setContentOffset(self.contentOffset, animated: false)
                self.isScrollEnabled = false
                
                let posInDayView = recognizer.location(in: dayView)
                if let cellModel = dayView.cellModel(from: posInDayView) {
                    self.panStartPoint = posInSelf
                    self.panEndPoint = posInSelf
                    self.panStartCell = cellModel
                    self.panEndCell = cellModel
                    self.panStartDayView = dayView
                    self.panEndDayView = dayView
                    self.selectedCells = [cellModel]
                    
                    let state = self.selectionState(from: cellModel.currentState)
                    self.panSelectionState = state
                    cellModel.selectedState = state
                    dayView.setNeedsDisplay()
                }
                
            case .changed:
                let posInDayView = recognizer.location(in: dayView)
                if let cellModel = dayView.cellModel(from: posInDayView) {
                    if dayView !== self.panEndDayView || cellModel !== self.panEndCell {
                        self.panEndPoint = posInSelf
                        self.panEndCell = cellModel
                        self.panEndDayView = dayView
                        self.updatePanCellSelections()
                    }
                }
                
            case .ended:
                for cell in self.selectedCells {
                    cell.confirmSelection()
                }
                self.selectedCells.removeAll()
                self.isScrollEnabled = true
                
            case .cancelled, .failed:
                for cell in self.selectedCells {
                    cell.cancelSelection()
                }
                self.selectedCells.removeAll()
                self.isScrollEnabled = true
                
            default:
                self.selectedCells.removeAll()
                self.isScrollEnabled = true
            }
        }
    }
    
    func updatePanCellSelections() {
        if self.model == nil || self.panStartPoint == nil || self.panEndPoint == nil {
            print("ERROR updatePanCellSelections: something is nil")
            return
        }
        
        var leftDay, rightDay: TimeMatrixSelectionDayView?
        var topCell, bottomCell: TimeMatrixCellModel?
        
        if self.panStartPoint!.y < self.panEndPoint!.y {
            topCell = self.panStartCell
            bottomCell = self.panEndCell
        }
        else {
            topCell = self.panEndCell
            bottomCell = self.panStartCell
        }
        
        if self.panStartPoint!.x < self.panEndPoint!.x {
            leftDay = self.panStartDayView
            rightDay = self.panEndDayView
        }
        else {
            leftDay = self.panEndDayView
            rightDay = self.panStartDayView
        }
        
        if let firstDay = leftDay?.day, let secondDay = rightDay?.day,
            let firstTime = topCell?.timeSlot, let secondTime = bottomCell?.timeSlot {
            
            var slots: [Int]
            if firstTime <= secondTime {
                slots = Array(firstTime...secondTime)
            }
            else {
                slots = Array(firstTime..<self.model!.cellsPerDay) + Array(0...secondTime)
            }
            
            var days = [firstDay]
            for day in self.model!.activeDays {
                if firstDay < day {
                    if secondDay < day {
                        break
                    }
                    days.append(day)
                }
            }
            
            var newSelectedCells = Set<TimeMatrixCellModel>()
            
            for day in days {
                for index in slots {
                    if let cell = self.model?.cells[day]?[index] {
                        cell.selectedState = self.panSelectionState
                        newSelectedCells.insert(cell)
                    }
                }
            }
            
            for cell in self.selectedCells.subtracting(newSelectedCells) {
                cell.cancelSelection()
            }
            
            self.selectedCells = newSelectedCells
            self.updateViews()
        }
    }
    
    func updateViews() {
        for selectionView in self.selectionViews {
            for dayView in selectionView.selectionDayViews {
                dayView.setNeedsDisplay()
            }
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}

extension TimeMatrixScrollView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("DID SCROLL BEGIN")
        let yPos = scrollView.contentOffset.y
        let selectionViewHeight = scrollView.contentSize.height / 3
        
        
        if yPos < selectionViewHeight {
            scrollView.setContentOffset(CGPoint(x: 0, y: yPos + selectionViewHeight), animated: false)
        }
        else if yPos > selectionViewHeight * 2 {
            scrollView.setContentOffset(CGPoint(x: 0, y: yPos - selectionViewHeight), animated: false)
        }
        print("DID SCROLL END")
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
    }
}

extension TimeMatrixScrollView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
