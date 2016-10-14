//
//  TimeMatrixCellModel.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import Foundation

class TimeMatrixCellModel: Hashable {
    
    // MARK: - Enumerations
    
    enum State {
        case available, unavailable, preferred
    }
    
    
    // MARK: - Properties
    
    var currentState: State {
        get {
            return self.currentState_
        }
    }
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    // MARK: - Variables
    
    var timeSlot: Int
    
    var isSelected = false
    
    private var currentState_ = State.unavailable
    private var previousState = State.unavailable
    
    
    // MARK: - Initialization
    
    init(timeSlot: Int) {
        self.timeSlot = timeSlot
    }
    
    
    // MARK: - Cell selection
    
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
}

func ==(lhs: TimeMatrixCellModel, rhs: TimeMatrixCellModel) -> Bool {
    return lhs === rhs
}
