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
        case available, unavailable, preferred, unselectable
    }
    
    
    // MARK: - Properties
    
    var currentState: State
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    // MARK: - Variables
    
    var timeSlot: Int
    
    var isSelected = false
    
    private var previousState = State.unavailable
    
    
    // MARK: - Initialization
    
    init(timeSlot: Int) {
        self.timeSlot = timeSlot
        self.currentState = .unavailable
    }
    
    
    // MARK: - Cell selection
    
    func select(state: State) {
        if !self.isSelected && self.currentState != .preferred && self.currentState != .unselectable {
            self.previousState = self.currentState
            self.currentState = state
            self.isSelected = true
        }
    }
    
    func cancelSelection() {
        if self.isSelected {
            self.currentState = self.previousState
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
