//
//  TimeMatrixSelectionCell.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixSelectionCell: UIView {
    let bgAvailable = UIColor.green
    let bgUnavailable = UIColor.red
    let bgPreferred = UIColor.blue
    
    var parentStack: TimeMatrixSelectionStack? {
        get {
            return self.superview as? TimeMatrixSelectionStack
        }
    }
    
    var day: TimeMatrixDay? {
        get {
            return self.parentStack?.day
        }
    }
    
    var timeSlot: Int? {
        get {
            return self.superview?.subviews.index(of: self)
        }
    }
    
    var daySlot: Int? {
        get {
            if let stackView = self.superview {
                if let index = stackView.superview?.subviews.index(of: stackView) {
                    return index - 1
                }
            }
            return nil
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
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}

extension TimeMatrixSelectionCell: TimeMatrixCellStateListener {

    func onStateChange(_ state: TimeMatrixCellModel.State, isSelected: Bool) {
        switch (state) {
        case .available:
            self.backgroundColor = bgAvailable
        case .unavailable:
            self.backgroundColor = bgUnavailable
        case .preferred:
            self.backgroundColor = bgPreferred
        }
    }
}

