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
    
    private var currentState_ = State.unavailable
    private var previousState = State.unavailable
    
    var currentState: State {
        get {
            return self.currentState_
        }
    }
    
    init(timeSlot: Int) {
        self.timeSlot = timeSlot
    }
    
    func select(state: State) {
        if !self.isSelected {
            self.previousState = self.currentState
            self.currentState_ = state
            self.isSelected = true
        }
    }
    
    func cancelSelection() {
        if self.isSelected {
            self.currentState_ = self.previousState
            self.isSelected = false
        }
    }
    
    func confirmSelection() {
        self.isSelected = false
    }
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

func ==(lhs: TimeMatrixCellModel, rhs: TimeMatrixCellModel) -> Bool {
    return lhs === rhs
}
