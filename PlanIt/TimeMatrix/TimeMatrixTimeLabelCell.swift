//
//  TimeMatrixLabelCell.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixTimeLabelCell: UILabel, TimeMatrixTimeFormatListener {
    
    // MARK: - Variables
    
    private var hour = 0
    private var minute = 0
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented, use init(frame:timeSlot:height:)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented, use init(timeSlot:height:)")
    }
    
    init(frame: CGRect, index: Int, height: CGFloat) {
        super.init(frame: frame)
        self.setup(height: height)
        self.setTime(index: index)
    }
    
    convenience init(index: Int, height: CGFloat) {
        self.init(frame: CGRect(), index: index, height: height)
    }
    
    private func setup(height: CGFloat) {
        self.font = UIFont.systemFont(ofSize: TimeMatrixDisplayManager.timeLabelFontSize)
        self.adjustsFontSizeToFitWidth = true
        self.textAlignment = .center
        self.baselineAdjustment = .alignCenters
        
        let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        NSLayoutConstraint.activate([height])
        
        TimeMatrixDisplayManager.instance.timeFormatListeners.insert(self)
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
    
    func onChange(timeFormat: TimeMatrixDisplayManager.TimeFormat) {
        self.setLabelText(timeFormat: timeFormat)
    }
}
