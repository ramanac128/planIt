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
    
    init(from otherDay: TimeMatrixDay) {
        self.day = otherDay.day
        self.month = otherDay.month
        self.year = otherDay.year
        self.dayOfWeek = otherDay.dayOfWeek
    }
    
    init(from otherDay: TimeMatrixDay, byAdding component: Calendar.Component, value: Int) {
        self.init(from: otherDay)
        self.add(component, value: value)
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
    
    mutating func add(_ component: Calendar.Component, value: Int) {
        switch component {
        case .day:
            self.day += value
            break
            
        case .month:
            self.month += value
            break
            
        case .year:
            self.year += value
            break
            
        default:
            break
        }
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
    return lhs.year < rhs.year || lhs.month < rhs.month || lhs.day < rhs.day;
}

func >(lhs: TimeMatrixDay, rhs: TimeMatrixDay) -> Bool {
    return rhs < lhs
}

func <=(lhs: TimeMatrixDay, rhs: TimeMatrixDay) -> Bool {
    return !(lhs > rhs)
}

func >=(lhs: TimeMatrixDay, rhs: TimeMatrixDay) -> Bool {
    return !(lhs < rhs)
}
