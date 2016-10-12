//
//  TimeMatrixLabelCell.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixLabelCell: UILabel {
    
    static let cellHeight = CGFloat(35)
    static let fontSize = CGFloat(16)
    
    private var timeSlot = 0
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    init(frame: CGRect, timeSlot: Int, isMilitaryTime: Bool = false) {
        self.timeSlot = timeSlot
        super.init(frame: frame)
        self.setup()
        self.setLabel(timeSlot: self.timeSlot, isMilitaryTime: isMilitaryTime)
    }
    
    convenience init(timeSlot: Int, isMilitaryTime: Bool = false) {
        self.init(frame: CGRect(), timeSlot: timeSlot, isMilitaryTime: isMilitaryTime)
    }
    
    private func setup() {
        self.font = UIFont.systemFont(ofSize: TimeMatrixLabelCell.fontSize)
        self.adjustsFontSizeToFitWidth = true
        self.textAlignment = .center
        self.baselineAdjustment = .alignCenters
        
        let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: TimeMatrixLabelCell.cellHeight)
        
        NSLayoutConstraint.activate([height])
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.timeLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.width * CGFloat(0.9), height: self.bounds.height)
//    }
    
    func setLabel(timeSlot: Int, isMilitaryTime: Bool = false) {
        self.timeSlot = timeSlot
        
        let totalSlots = TimeMatrixModel.resolution * 24 / 2
        let hoursFromMidnight = Double(timeSlot) / Double(totalSlots) * 24.0
        
        var hour = Int(hoursFromMidnight)
        let minute = Int((hoursFromMidnight - Double(hour)) * 60)
        
        if isMilitaryTime {
            self.text = String(format: "%02d:%02d", hour, minute)
        }
        else {
            var dayPart: String
            if hour < 12 {
                dayPart = "am"
            }
            else {
                dayPart = "pm"
                hour -= 12
            }
            hour = (hour == 0 ? 12 : hour)
            self.text = String(format: "%d:%02d%@", hour, minute, dayPart)
        }
    }
}
