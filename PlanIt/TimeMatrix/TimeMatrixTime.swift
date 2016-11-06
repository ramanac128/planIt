//
//  TimeMatrixTime.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/6/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

class TimeMatrixTime: Hashable, CustomStringConvertible {
    
    // MARK: - Static functions
    
    static func rawValueFrom(date: Date) -> Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return (hour * 4) + (minute / 15)
    }
    
    
    // MARK: - Properties
    
    var rawValue: Int
    
    var hashValue: Int {
        get {
            return self.rawValue.hashValue
        }
    }
    
    var description: String {
        get {
            let hour = self.rawValue / 4
            let minute = (self.rawValue % 4) * 15
            return String(format: "%d:%02d", hour, minute)
        }
    }
    
    
    // MARK: - Initialization
    
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    init(date: Date) {
        self.rawValue = TimeMatrixTime.rawValueFrom(date: date)
    }
    
    func from(date: Date) {
        self.rawValue = TimeMatrixTime.rawValueFrom(date: date)
    }
}


func ==(lhs: TimeMatrixTime, rhs: TimeMatrixTime) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

func <(lhs: TimeMatrixTime, rhs: TimeMatrixTime) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

func >(lhs: TimeMatrixTime, rhs: TimeMatrixTime) -> Bool {
    return lhs.rawValue > rhs.rawValue
}

func <=(lhs: TimeMatrixTime, rhs: TimeMatrixTime) -> Bool {
    return lhs.rawValue <= rhs.rawValue
}

func >=(lhs: TimeMatrixTime, rhs: TimeMatrixTime) -> Bool {
    return lhs.rawValue >= rhs.rawValue
}

