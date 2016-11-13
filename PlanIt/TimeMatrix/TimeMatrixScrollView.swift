//
//  TimeMatrixScrollView.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixScrollView: UIScrollView, TimeMatrixWillDisplayListener, TimeMatrixModelPreferredDayListener, TimeMatrixModelPreferredTimeListener, TimeMatrixRowAnimationListener, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Subviews
    
    private weak var contentView: UIStackView!
    private var selectionViews = [Weak<TimeMatrixSelectionView>]()
    
    
    // MARK: - Properties
    
    var model: TimeMatrixModel? {
        didSet {
            oldValue?.preferredDayListeners.remove(self)
            oldValue?.preferredTimeListeners.remove(self)
            if oldValue !== self.model && self.model != nil {
                self.model!.preferredDayListeners.insert(self)
                self.model!.preferredTimeListeners.insert(self)
                for selectionView in self.selectionViews {
                    selectionView.value!.model = self.model!
                }
                self.scrollToPreferredTime()
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
    
    private var isAnimatingRow = false
    private var hasLayedOutSubviews = false
    
    
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
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.clipsToBounds = true
        self.delegate = self
        
        let contentView = UIStackView()
        contentView.alignment = .fill
        contentView.distribution = .fillEqually
        contentView.spacing = 0
        contentView.axis = .vertical
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        for _ in 1...3 {
            let selectionView = TimeMatrixSelectionView()
            let weakView = Weak<TimeMatrixSelectionView>(value: selectionView)
            self.selectionViews.append(weakView)
            contentView.addArrangedSubview(selectionView)
        }
        
        self.contentView = contentView
        self.addSubview(contentView)
        
        let width = NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
        self.addConstraint(width)
        
        let panRecognizer = TimeMatrixPanGestureRecognizer(target: self, action: #selector(TimeMatrixScrollView.handlePan(recognizer:)))
        panRecognizer.delegate = self
        self.addGestureRecognizer(panRecognizer)
        
        let displayManager = TimeMatrixDisplayManager.instance
        displayManager.rowAnimationListeners.insert(self)
        displayManager.willDisplayListeners.insert(self)
    }
    
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        let oldHeight = self.contentView.bounds.height
        let oldContentOffset = self.contentOffset.y
        super.layoutSubviews()
        self.contentView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.contentView.bounds.height)
        self.contentSize = self.contentView.bounds.size
        if oldHeight != self.contentView.bounds.height && oldHeight > 0 {
            let percent = self.contentCenterAsPercent(contentOffset: oldContentOffset, contentHeight: oldHeight)
            self.scrollCenterTo(percent: percent, animated: false)
        }
        else if !self.hasLayedOutSubviews {
            self.hasLayedOutSubviews = true
            self.scrollToPreferredTime()
        }
    }
    
    func contentCenterAsPercent(contentOffset: CGFloat, contentHeight: CGFloat) -> CGFloat {
        let halfFrameHeight = self.bounds.height / 2
        let selectionViewHeight = contentHeight / 3
        var centerPos = contentOffset + halfFrameHeight
        centerPos = centerPos.truncatingRemainder(dividingBy: selectionViewHeight)
        let percent = centerPos / selectionViewHeight
        return percent
    }
    
    func scrollCenterTo(percent: CGFloat, animated: Bool) {
        let halfHeight = self.bounds.height / 2
        let contentHeight = self.contentSize.height / 3
        let contentCenter = contentHeight * percent
        let contentOffset = contentCenter - halfHeight + contentHeight
        self.contentOffset = CGPoint(x: 0, y: contentOffset)
    }
    
    func onWillDisplay() {
        for selectionView in self.selectionViews {
            selectionView.value!.setNeedsDisplay()
        }
    }
    
    
    // MARK: - Cell selection
    
    func selectionState(from: TimeMatrixCellModel.State) -> TimeMatrixCellModel.State {
        switch from {
        case .available, .preferred, .unselectable:
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
    
    
    // MARK: - TimeMatrixModel protocol methods
    
    func onChange(preferredDay: TimeMatrixDay?) {
        self.scrollToPreferredTime()
    }
    
    func onChange(startTime: TimeMatrixTime?) {
        self.scrollToPreferredTime()
    }
    
    func onChange(endTime: TimeMatrixTime?) {
        self.scrollToPreferredTime()
    }
    
    func scrollToPreferredTime() {
        if let model = self.model, let start = model.preferredStartTime, let end = model.preferredEndTime {
            let percent = CGFloat(start.rawValue + end.rawValue - 1) / CGFloat(TimeMatrixModel.cellsPerDay * 2)
            self.scrollCenterTo(percent: percent, animated: false)
        }
    }
    
    // MARK: - TimeMatrixRowAnimationListener protocol methods
    
    func onRowAnimationBegin() {
        self.isAnimatingRow = true
    }
    
    func onRowAnimationFrame() {
        self.layoutIfNeeded()
    }
    
    func onRowAnimationEnd() {
        self.isAnimatingRow = false
        self.realignContentOffsetIfNeeded()
    }
    
    
    // MARK: - UIScrollViewDeleagate protocol methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.isAnimatingRow {
            self.realignContentOffsetIfNeeded()
        }
    }
    
    private func realignContentOffsetIfNeeded() {
        let yPos = self.contentOffset.y
        let centerPos = yPos + (self.frame.height / 2)
        let selectionViewHeight = self.contentSize.height / 3
        
        
        if centerPos < selectionViewHeight {
            let offset = CGPoint(x: 0, y: yPos + selectionViewHeight)
            self.setContentOffset(offset, animated: false)
        }
        else if centerPos > selectionViewHeight * 2 {
            let offset = CGPoint(x: 0, y: yPos - selectionViewHeight)
            self.setContentOffset(offset, animated: false)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
    }
    
    
    // MARK: - UIGestureRecognizerDelegate protocol methods
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
