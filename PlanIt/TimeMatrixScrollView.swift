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
    
    var panStartCell: TimeMatrixSelectionCell?
    var panEndCell: TimeMatrixSelectionCell?
    
    var panSelectionState: TimeMatrixCellModel.State?
    
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
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TimeMatrixScrollView.handlePan(recognizer:)))
        panRecognizer.delegate = self
        self.addGestureRecognizer(panRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(TimeMatrixScrollView.handleTap(recognizer:)))
        self.addGestureRecognizer(tapRecognizer)
        
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
    
    func selectionState(from: TimeMatrixSelectionCell) -> TimeMatrixCellModel.State {
        if let startState = self.model?.cells[from.day!]?[from.timeSlot!].currentState {
            switch startState {
            case .available, .preferred:
                return TimeMatrixCellModel.State.unavailable
            case .unavailable:
                return TimeMatrixCellModel.State.available
            }
        }
        return TimeMatrixCellModel.State.available
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        let position = recognizer.location(in: self)
        let currentCell = self.hitTest(position, with: nil)
        
        if let selectionCell = currentCell as? TimeMatrixSelectionCell {
            let state = self.selectionState(from: selectionCell)
            self.selectCell(selectionCell, state: state)
        }
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        let position = recognizer.location(in: self)
        let currentCell = self.hitTest(position, with: nil)
        
        if let selectionCell = currentCell as? TimeMatrixSelectionCell {
            switch (recognizer.state) {
            case .began:
                self.setContentOffset(self.contentOffset, animated: false)
                self.isScrollEnabled = false
                
                self.panStartCell = selectionCell
                self.panEndCell = selectionCell
                self.panStartPoint = position
                self.panEndPoint = position
                self.panSelectionState = self.selectionState(from: selectionCell)
                self.selectCell(selectionCell, state: self.panSelectionState!)
                
            case .changed:
                if self.panEndCell != selectionCell {
                    self.panEndCell = selectionCell
                    self.panEndPoint = position
                    self.updatePanCellSelections()
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
    
    func selectCell(_ cell: TimeMatrixSelectionCell, state: TimeMatrixCellModel.State) {
        if let day = cell.day, let time = cell.timeSlot {
            self.model?.cells[day]?[time].currentState = state
        }
    }
    
    func updatePanCellSelections() {
        if self.model == nil || self.panStartPoint == nil || self.panEndPoint == nil || self.panSelectionState == nil {
            print("ERROR updatePanCellSelections: something is nil")
            return
        }
        
        var topCell, bottomCell, leftCell, rightCell: TimeMatrixSelectionCell?
        
        if self.panStartPoint!.y < self.panEndPoint!.y {
            topCell = self.panStartCell
            bottomCell = self.panEndCell
        }
        else {
            topCell = self.panEndCell
            bottomCell = self.panStartCell
        }
        
        if self.panStartPoint!.x < self.panEndPoint!.x {
            leftCell = self.panStartCell
            rightCell = self.panEndCell
        }
        else {
            leftCell = self.panEndCell
            rightCell = self.panStartCell
        }
        
        if let firstDay = leftCell?.day?.toString, let secondDay = rightCell?.day?.toString,
            let firstTime = topCell?.timeSlot, let secondTime = bottomCell?.timeSlot {
            
            var slots: [Int]
            if firstTime <= secondTime {
                slots = Array(firstTime...secondTime)
            }
            else {
                slots = Array(firstTime..<self.model!.cellsPerDay) + Array(0...secondTime)
            }
            
            var days = [TimeMatrixDay]()
            for day in self.model!.activeDays {
                let dayString = day.toString
                if dayString >= firstDay {
                    if dayString > secondDay {
                        break
                    }
                    days.append(day)
                }
            }
            
            var newSelectedCells = Set<TimeMatrixCellModel>()
            
            for day in days {
                for index in slots {
                    if let cell = self.model?.cells[day]?[index] {
                        cell.selectedState = self.panSelectionState!
                        newSelectedCells.insert(cell)
                    }
                }
            }
            
            for cell in self.selectedCells.subtracting(newSelectedCells) {
                cell.cancelSelection()
            }
            
            self.selectedCells = newSelectedCells
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
