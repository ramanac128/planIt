//
//  TimeMatrixLabelCell.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixTimeLabelCell: UILabel, TimeMatrixTimeFormatListener {
    
    // MARK: - Properties
    
    var height: CGFloat {
        get {
            return self.heightConstraint.constant
        }
        set {
            self.heightConstraint.constant = newValue
        }
    }
    
    // MARK: - Variables
    
    private var hour = 0
    private var minute = 0
    
    private weak var heightConstraint: NSLayoutConstraint!
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented, use init(frame:timeSlot:height:)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented, use init(timeSlot:height:)")
    }
    
    init(frame: CGRect, index: Int) {
        super.init(frame: frame)
        self.setup()
        self.setTime(index: index)
    }
    
    convenience init(index: Int) {
        self.init(frame: CGRect(), index: index)
    }
    
    private func setup() {
        self.font = UIFont(name: "GillSans", size: TimeMatrixDisplayManager.timeLabelFontSize)
        self.adjustsFontSizeToFitWidth = true
        self.textAlignment = .center
        self.baselineAdjustment = .alignCenters
        
        let resolution = TimeMatrixDisplayManager.instance.resolution
        let cellHeight = TimeMatrixTimeLabelCell.cellHeight(resolution: resolution)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cellHeight)
        self.addConstraint(height)
        self.heightConstraint = height
        
        TimeMatrixDisplayManager.instance.timeFormatListeners.insert(self)
    }
    
    
    // MARK: - Layout and display
    
    static func cellHeight(resolution: TimeMatrixDisplayManager.Resolution) -> CGFloat {
        let resolutionInt = Int(resolution.rawValue * 4)
        let cellHeightIncrement = TimeMatrixDisplayManager.cellHeightIncrement * CGFloat(resolutionInt - 1)
        let cellHeight = TimeMatrixDisplayManager.cellHeightMinimum + cellHeightIncrement
        return cellHeight
    }
    
    
    // MARK: - Time label setter helpers
    
    func setTime(index: Int) {
        let totalSlots = TimeMatrixModel.cellsPerDay
        let decimalHours = Double(index) / Double(totalSlots) * 24.0
        
        self.hour = Int(decimalHours)
        self.minute = Int((decimalHours - Double(self.hour)) * 60)
        
        if self.minute == 0 {
            self.textColor = TimeMatrixDisplayManager.timeLabelColorOnHour
        }
        else if self.minute == 30 {
            self.textColor = TimeMatrixDisplayManager.timeLabelColorOn30Min
        }
        else {
            self.textColor = TimeMatrixDisplayManager.timeLabelColorOn15Min
        }
        
        self.setLabelText(timeFormat: TimeMatrixDisplayManager.instance.timeFormat)
    }
    
    private func setLabelText(timeFormat: TimeMatrixDisplayManager.TimeFormat) {
        switch (timeFormat) {
        case .military:
            self.text = String(format: "%02d:%02d", self.hour, self.minute)
            
        case .standard:
            var displayHour: Int
            var dayPart: String
            if self.hour < 12 {
                displayHour = (self.hour == 0 ? 12 : self.hour)
                dayPart = "am"
            }
            else {
                displayHour = (self.hour == 12 ? 12 : self.hour - 12)
                dayPart = "pm"
            }
            self.text = String(format: "%d:%02d%@", displayHour, self.minute, dayPart)
        }
    }
    
    
    // MARK: - TimeMatrixTimeFormatListener protocol methods
    
    func onChange(timeFormat: TimeMatrixDisplayManager.TimeFormat, previous: TimeMatrixDisplayManager.TimeFormat) {
        self.setLabelText(timeFormat: timeFormat)
    }
}
