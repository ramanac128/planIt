//
//  TimeMatrixDayViewManager.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/16/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixDayViewLayoutManager<DayView: UIView>: UIStackView, TimeMatrixModelDayListener {
    
    // MARK: - Subviews
    
    var sideView: Weak<UIView>
    var dayViews = [TimeMatrixDay: (view: Weak<DayView>, smallWidth: NSLayoutConstraint, largeWidth: NSLayoutConstraint, zeroWidth: NSLayoutConstraint)]()
    
    
    // MARK: - Properties
    
    var model: TimeMatrixModel? {
        didSet {
            if oldValue !== model {
                oldValue?.dayListeners.remove(self)
                for item in self.dayViews.values {
                    if let dayView = item.view.value {
                        self.removeArrangedSubview(dayView)
                        dayView.removeFromSuperview()
                    }
                }
                self.dayViews.removeAll()
                if let newValue = self.model {
                    self.attachToModel(newValue)
                }
                self.setNeedsLayout()
            }
        }
    }
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented, use init(frame:model:sideView:)")
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, use init(model:sideView:)")
    }
    
    init(frame: CGRect, sideView: UIView) {
        self.sideView = Weak<UIView>(value: sideView)
        super.init(frame: frame)
        self.setup()
    }
    
    init(coder: NSCoder, sideView: UIView) {
        self.sideView = Weak<UIView>(value: sideView)
        super.init(coder: coder)
        self.setup()
    }
    
    convenience init(sideView: UIView) {
        self.init(frame: CGRect(), sideView: sideView)
    }
    
    func setup() {
        self.alignment = .fill
        self.distribution = .fill
        self.spacing = 0
        self.axis = .horizontal
        
        self.addArrangedSubview(self.sideView.value!)
    }
    
    func attachToModel(_ model: TimeMatrixModel) {
        model.dayListeners.insert(self)
        let days = model.activeDays
        for index in 0..<days.count {
            let day = days[index]
            if let cellModels = model.cells[day] {
                self.insertDayView(day: day, cellModels: cellModels, atIndex: index)
            }
        }
    }
    
    
    // MARK: - Abstract methods
    
    func makeDayView(day: TimeMatrixDay, cellModels: [TimeMatrixCellModel]) -> DayView {
        preconditionFailure("makeDayView(day:cellModels:) must be overridden")
    }
    
    
    // MARK: - Layout and display
    
    @discardableResult func insertDayView(day: TimeMatrixDay, cellModels: [TimeMatrixCellModel], atIndex index: Int) -> (view: Weak<DayView>, smallWidth: NSLayoutConstraint, largeWidth: NSLayoutConstraint, zeroWidth: NSLayoutConstraint) {
        if self.dayViews.count == 1 {
            if let tuple = self.dayViews.first?.value {
                tuple.largeWidth.isActive = false
                tuple.smallWidth.isActive = true
            }
        }
        
        if let oldView = self.dayViews.removeValue(forKey: day)?.view.value {
            self.removeArrangedSubview(oldView)
            oldView.removeFromSuperview()
        }
        
        let view = self.makeDayView(day: day, cellModels: cellModels)
        let weakView = Weak<DayView>(value: view)
        let smallWidth = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: self.sideView.value!, attribute: .width, multiplier: 1, constant: 0)
        let largeWidth = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: self.sideView.value!, attribute: .width, multiplier: 2, constant: 0)
        let zeroWidth = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        
        self.insertArrangedSubview(view, at: index + 1)
        self.addConstraints([smallWidth, largeWidth])
        
        if self.dayViews.isEmpty {
            smallWidth.isActive = false
            largeWidth.isActive = true
        }
        else {
            largeWidth.isActive = false
            smallWidth.isActive = true
        }
        zeroWidth.isActive = false
        
        let tuple = (view: weakView, smallWidth: smallWidth, largeWidth: largeWidth, zeroWidth: zeroWidth)
        self.dayViews[day] = tuple
        return tuple
    }
    
    
    // MARK: - TimeMatrixModelDayListener protocol methods
    
    func onAdded(day: TimeMatrixDay, cellModels: [TimeMatrixCellModel], atIndex index: Int) {
        let shrinkIfNeeded = self.dayViews.count == 1 ? self.dayViews.first?.value : nil
        let tuple = self.insertDayView(day: day, cellModels: cellModels, atIndex: index)
        
        let nextWidth = self.dayViews.count == 1 ? tuple.largeWidth : tuple.smallWidth
        let zeroWidth = tuple.zeroWidth
        nextWidth.isActive = false
        zeroWidth.isActive = true
        
        if let shrink = shrinkIfNeeded {
            shrink.smallWidth.isActive = false
            shrink.largeWidth.isActive = true
        }
        
        let duration = TimeMatrixDisplayManager.dayAddedAnimationDuration
        TimeMatrixDisplayManager.instance.informOnColumnAnimationBegin()
        self.layoutIfNeeded()
        UIView.animate(withDuration: duration, animations: {
            if let shrink = shrinkIfNeeded {
                shrink.largeWidth.isActive = false
                shrink.smallWidth.isActive = true
            }
            zeroWidth.isActive = false
            nextWidth.isActive = true
            //TimeMatrixDisplayManager.instance.informOnColumnAnimationFrame()
            self.layoutIfNeeded()
        }, completion: {(Bool) -> Void in
            TimeMatrixDisplayManager.instance.informOnColumnAnimationEnd()
        })
    }
    
    func onRemoved(day: TimeMatrixDay) {
        if let item = self.dayViews.removeValue(forKey: day), let view = item.view.value {
            let growIfNeeded = self.dayViews.count == 1 ? self.dayViews.first?.value : nil
            
            let duration = TimeMatrixDisplayManager.dayRemovedAnimationDuration
            TimeMatrixDisplayManager.instance.informOnColumnAnimationBegin()
            self.layoutIfNeeded()
            UIView.animate(withDuration: duration, animations: {
                if let grow = growIfNeeded {
                    grow.smallWidth.isActive = false
                    grow.largeWidth.isActive = true
                }
                item.smallWidth.isActive = false
                item.largeWidth.isActive = false
                item.zeroWidth.isActive = true
                //TimeMatrixDisplayManager.instance.informOnColumnAnimationFrame()
                self.layoutIfNeeded()
            }, completion: {(Bool) -> Void in
                self.removeArrangedSubview(view)
                view.removeFromSuperview()
                TimeMatrixDisplayManager.instance.informOnColumnAnimationEnd()
            })
        }
    }
}
