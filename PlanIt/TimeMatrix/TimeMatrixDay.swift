//
//  TimeMatrixDay.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import Foundation

struct TimeMatrixDay: Hashable, CustomStringConvertible {
    
    // MARK: - Properties
    
    var hashValue: Int {
        get {
            return self.description.hashValue
        }
    }
    
    var description: String {
        get {
            return String(format: "%d-%02d-%02d", self.year, self.month, self.day)
        }
    }
    
    
    // MARK: - Variables
    
    var year = 2016
    var month = 1
    var day = 1
    var dayOfWeek = 1
    
    
    // MARK: - Initialization
    
    init(date: Date) {
        self.from(date: date)
    }
    
    
    // MARK: - Date conversions
    
    mutating func from(date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
        self.year = components.year!
        self.month = components.month!
        self.day = components.day!
        self.dayOfWeek = components.weekday!
    }
    
    func toDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self.description)!
    }
}

func ==(lhs: TimeMatrixDay, rhs: TimeMatrixDay) -> Bool {
    return lhs.day == rhs.day && lhs.month == rhs.month && lhs.year == rhs.year
}

func <(lhs: TimeMatrixDay, rhs: TimeMatrixDay) -> Bool {
    if lhs.year < rhs.year {
        return true
    }
    if lhs.year > rhs.year {
        return false
    }
    if lhs.month < rhs.month {
        return true
    }
    if lhs.month > rhs.month {
        return false
    }
    if lhs.day < rhs.day {
        return true
    }
    return false
}

func >(lhs: TimeMatrixDay, rhs: TimeMatrixDay) -> Bool {
    return rhs < lhs
}

func <=(lhs: TimeMatrixDay, rhs: TimeMatrixDay) -> Bool {
    return lhs < rhs || lhs == rhs
}

func >=(lhs: TimeMatrixDay, rhs: TimeMatrixDay) -> Bool {
    return lhs > rhs || lhs == rhs
}
