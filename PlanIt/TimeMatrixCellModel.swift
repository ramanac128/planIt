//
//  TimeMatrixCellModel.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import Foundation

class TimeMatrixCellModel: Hashable {
    enum State {
        case available, unavailable, preferred
    }
    
    var timeSlot: Int
    
    var isSelected = false
    
    var currentState: State = .unavailable
    
    var selectedState: State = .unavailable {
        didSet {
            self.isSelected = true
        }
    }
    
    var displayState: State {
        get {
            return isSelected ? self.selectedState : self.currentState
        }
    }
    
    init(timeSlot: Int) {
        self.timeSlot = timeSlot
    }
    
    func cancelSelection() {
        self.isSelected = false
    }
    
    func confirmSelection() {
        self.currentState = self.selectedState
        self.isSelected = false
    }
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

func ==(lhs: TimeMatrixCellModel, rhs: TimeMatrixCellModel) -> Bool {
    return lhs === rhs
}
