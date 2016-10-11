//
//  TimeMatrixDay.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import Foundation

class TimeMatrixDay: NSObject {
    private var year = 2016
    private var month = 1
    private var day = 1
    
    init(date: Date) {
        super.init()
        self.from(date: date)
    }
    
    override var hashValue: Int {
        get {
            return self.toString.hashValue
        }
    }
    
    var toString: String {
        get {
            return String(format: "%d-%02d-%02d", self.year, self.month, self.day)
        }
    }
    
    func from(date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        year = components.year!
        month = components.month!
        day = components.day!
    }
    
    func toDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self.toString)!
    }
}

func ==(lhs: TimeMatrixDay, rhs: TimeMatrixDay) -> Bool {
    return lhs.toString == rhs.toString
}
