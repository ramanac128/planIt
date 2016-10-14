//
//  TimeMatrixDayLabelCell.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/14/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixDayLabelCell: UIStackView {
    private var dayOfWeekLabel = UILabel()
    private var monthAndDayLabel = UILabel()
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented, use init(frame:day:)")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented, use init(day:)")
    }
    
    init(frame: CGRect, day: TimeMatrixDay) {
        super.init(frame: frame)
        self.setup()
        self.setDay(day)
    }
    
    convenience init(day: TimeMatrixDay) {
        self.init(frame: CGRect(), day: day)
    }
    
    private func setup() {
        self.alignment = .center
        self.distribution = .fill
        self.spacing = 0
        self.axis = .vertical
        
        self.dayOfWeekLabel.adjustsFontSizeToFitWidth = true
        self.dayOfWeekLabel.textAlignment = .center
        self.monthAndDayLabel.adjustsFontSizeToFitWidth = true
        self.monthAndDayLabel.textAlignment = .center
        
        self.addArrangedSubview(self.dayOfWeekLabel)
        self.addArrangedSubview(self.monthAndDayLabel)
    }
    
    override func layoutSubviews() {
        self.dayOfWeekLabel.font = UIFont.systemFont(ofSize: TimeMatrixDisplayManager.dayLabelDayOfWeekFontSize)
        self.monthAndDayLabel.font = UIFont.systemFont(ofSize: TimeMatrixDisplayManager.dayLabelMonthAndDayFontSize)
        super.layoutSubviews()
    }
    
    private func setDay(_ day: TimeMatrixDay) {
        self.dayOfWeekLabel.text = self.dayOfWeekText(from: day)
        self.monthAndDayLabel.text = self.monthAndDayText(from: day)
    }
    
    func dayOfWeekText(from day: TimeMatrixDay) -> String {
        switch (day.dayOfWeek) {
        case 1:
            return "SUN"
        case 2:
            return "MON"
        case 3:
            return "TUE"
        case 4:
            return "WED"
        case 5:
            return "THU"
        case 6:
            return "FRI"
        case 7:
            return "SAT"
        default:
            return ""
        }
    }
    
    func monthAndDayText(from day: TimeMatrixDay) -> String {
        let month = self.monthText(from: day)
        return String(format: "%@ %d", month, day.day)
    }
    
    func monthText(from day: TimeMatrixDay) -> String {
        switch (day.month) {
        case 1:
            return "JAN"
        case 2:
            return "FEB"
        case 3:
            return "MAR"
        case 4:
            return "APR"
        case 5:
            return "MAY"
        case 6:
            return "JUN"
        case 7:
            return "JUL"
        case 8:
            return "AUG"
        case 9:
            return "SEP"
        case 10:
            return "OCT"
        case 11:
            return "NOV"
        case 12:
            return "DEC"
        default:
            return "ERR"
        }
    }
}
