//
//  TimeMatrixScrollView.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixScrollView: UIScrollView {
    
    // MARK: - Subviews
    
    private weak var contentView: UIStackView!
    private var selectionViews = [Weak<TimeMatrixSelectionView>]()
    
    
    // MARK: - Properties
    
    var model: TimeMatrixModel? {
        didSet {
            if oldValue !== self.model {
                if oldValue == nil {
                    for _ in 1...3 {
                        let selectionView = TimeMatrixSelectionView(model: self.model!)
                        let weakView = Weak<TimeMatrixSelectionView>(value: selectionView)
                        self.selectionViews.append(weakView)
                        contentView.addArrangedSubview(selectionView)
                    }
                }
                else {
                    for selectionView in self.selectionViews {
                        selectionView.value!.model = self.model!
                    }
                }
            }
        }
    }
    
    
    // MARK: - Variables
    
    private var panStartPoint: CGPoint?
    private var panEndPoint: CGPoint?
    private var panStartIndex: Int?
    private var panEndIndex: Int?
    private var panStartDayView: TimeMatrixDaySelectionColumn?
    private var panEndDayView: TimeMatrixDaySelectionColumn?
    private var panSelectionState = TimeMatrixCellModel.State.unavailable
    private var selectedCells = Set<TimeMatrixCellModel>()
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        let contentView = UIStackView()
        
        contentView.alignment = .fill
        contentView.distribution = .fillEqually
        contentView.spacing = 0
        contentView.axis = .vertical
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.clipsToBounds = true
        self.delegate = self
        
        self.contentView = contentView
        self.addSubview(contentView)
        
        let width = NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
        self.addConstraint(width)
        
        let panRecognizer = TimeMatrixPanGestureRecognizer(target: self, action: #selector(TimeMatrixScrollView.handlePan(recognizer:)))
        panRecognizer.delegate = self
        self.addGestureRecognizer(panRecognizer)
    }
    
    
    // MARK: - Layout
    
    override func layoutSubviews() {
//        let oldHeight = self.contentView.frame.size.height
//        let oldContentOffset = self.contentOffset.y
        super.layoutSubviews()
        self.contentView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.contentView.frame.height)
        self.contentSize = self.contentView.bounds.size
//        if oldHeight != self.contentView.frame.height && self.frame.size.height > 0 {
//            let percent = self.contentCenterAsPercent(contentOffset: oldContentOffset)
//            self.scrollCenterTo(percent: percent, animated: false)
//        }
    }
    
    func contentCenterAsPercent(contentOffset: CGFloat) -> CGFloat {
        let halfHeight = self.bounds.height / 2
        let contentHeight = self.contentSize.height / 3
        var contentCenter = contentOffset + halfHeight
        while contentCenter > contentHeight {
            contentCenter -= contentHeight
        }
        let percent = contentCenter / contentHeight
        return percent
    }
    
    func scrollCenterTo(percent: CGFloat, animated: Bool) {
        let halfHeight = self.bounds.height / 2
        let contentHeight = self.contentSize.height / 3
        let contentCenter = contentHeight * CGFloat(percent)
        var contentOffset = contentCenter - halfHeight
        while contentOffset < contentHeight {
            contentOffset += contentHeight
        }
        while contentOffset > contentHeight * 2 {
            contentOffset -= contentHeight
        }
        self.contentOffset = CGPoint(x: CGFloat(0), y: contentOffset)
    }
    
    
    // MARK: - Cell selection
    
    func selectionState(from: TimeMatrixCellModel.State) -> TimeMatrixCellModel.State {
        switch from {
        case .available, .preferred:
            return TimeMatrixCellModel.State.unavailable
        case .unavailable:
            return TimeMatrixCellModel.State.available
        }
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        if self.model == nil {
            return
        }
        
        let posInSelf = recognizer.location(in: self)
        let view = self.hitTest(posInSelf, with: nil)
        
        if let dayView = view as? TimeMatrixDaySelectionColumn {
            switch recognizer.state {
            case .began:
                self.setContentOffset(self.contentOffset, animated: false)
                self.isScrollEnabled = false
                
                let posInDayView = recognizer.location(in: dayView)
                if let result = dayView.touchResult(at: posInDayView) {
                    let state = self.selectionState(from: result.cell.currentState)
                    self.panStartPoint = posInSelf
                    self.panEndPoint = posInSelf
                    self.panStartIndex = result.index
                    self.panEndIndex = result.index
                    self.panStartDayView = dayView
                    self.panEndDayView = dayView
                    self.panSelectionState = state
                    self.updatePanCellSelections()
                }
                
            case .changed:
                if self.isScrollEnabled == false {
                    let posInDayView = recognizer.location(in: dayView)
                    if let result = dayView.touchResult(at: posInDayView) {
                        if dayView !== self.panEndDayView || result.index != self.panEndIndex {
                            self.panEndPoint = posInSelf
                            self.panEndIndex = result.index
                            self.panEndDayView = dayView
                            self.updatePanCellSelections()
                        }
                    }
                }
                
            case .ended:
                for cell in self.selectedCells {
                    cell.confirmSelection()
                }
                self.isScrollEnabled = true
                
            case .cancelled, .failed:
                for cell in self.selectedCells {
                    cell.cancelSelection()
                }
                self.isScrollEnabled = true
                
            default:
                self.isScrollEnabled = true
            }
        }
        else if recognizer.state != .changed {
            for cell in self.selectedCells {
                cell.confirmSelection()
            }
            self.isScrollEnabled = true
        }
    }
    
    func updatePanCellSelections() {
        var leftDay, rightDay: TimeMatrixDaySelectionColumn?
        var topIndex, bottomIndex: Int?
        
        if self.panStartPoint!.y < self.panEndPoint!.y {
            topIndex = self.panStartIndex
            bottomIndex = self.panEndIndex
        }
        else {
            topIndex = self.panEndIndex
            bottomIndex = self.panStartIndex
        }
        
        let mod = Int(TimeMatrixDisplayManager.instance.resolution.rawValue * 4)
        let firstTime = topIndex! - (topIndex! % mod)
        let secondTime = bottomIndex! - (bottomIndex! % mod) + mod - 1
        
        if self.panStartPoint!.x < self.panEndPoint!.x {
            leftDay = self.panStartDayView
            rightDay = self.panEndDayView
        }
        else {
            leftDay = self.panEndDayView
            rightDay = self.panStartDayView
        }
        
        if let firstDay = leftDay?.day, let secondDay = rightDay?.day {
            var slots: [Int]
            if firstTime <= secondTime {
                slots = Array(firstTime...secondTime)
            }
            else {
                slots = Array(firstTime..<TimeMatrixModel.cellsPerDay) + Array(0...secondTime)
            }
            
            var newSelectedCells = Set<TimeMatrixCellModel>()
            
            let days = self.model!.activeDays
            var dayIndex = 0
            while dayIndex < days.count && days[dayIndex] < firstDay {
                dayIndex += 1
            }
            while dayIndex < days.count && days[dayIndex] <= secondDay {
                let day = days[dayIndex]
                for index in slots {
                    if let cell = self.model!.cells[day]?[index] {
                        cell.select(state: self.panSelectionState)
                        newSelectedCells.insert(cell)
                    }
                }
                dayIndex += 1
            }
            
            for cell in self.selectedCells.subtracting(newSelectedCells) {
                cell.cancelSelection()
            }
            self.selectedCells = newSelectedCells
            
            for selectionView in self.selectionViews {
                selectionView.value!.setNeedsDisplay()
            }
        }
    }
}


extension TimeMatrixScrollView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yPos = scrollView.contentOffset.y
        let selectionViewHeight = scrollView.contentSize.height / 3
        
        
        if yPos < selectionViewHeight {
            scrollView.setContentOffset(CGPoint(x: 0, y: yPos + selectionViewHeight), animated: false)
        }
        else if yPos > selectionViewHeight * 2 {
            scrollView.setContentOffset(CGPoint(x: 0, y: yPos - selectionViewHeight), animated: false)
        }
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
