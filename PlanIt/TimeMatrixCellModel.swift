//
//  TimeMatrixCellModel.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/10/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import Foundation

protocol TimeMatrixCellStateListener: class {
    func onStateChange(_ state: TimeMatrixCellModel.State, isSelected: Bool)
}

class TimeMatrixCellModel: Hashable {
    enum State {
        case available, unavailable, preferred
    }
    
    private var stateListeners = [TimeMatrixCellStateListener]()
    
    var currentState: State = .unavailable {
        didSet {
            if oldValue != self.currentState {
                self.informOnStateChange(self.currentState, isSelected: false)
            }
        }
    }
    
    var selectedState: State = .unavailable {
        didSet {
            self.informOnStateChange(self.selectedState, isSelected: true)
        }
    }
    
    func cancelSelection() {
        if self.selectedState != self.currentState {
            self.informOnStateChange(self.currentState, isSelected: false)
        }
    }
    
    func confirmSelection() {
        self.currentState = self.selectedState
    }
    
    func add(stateListener: TimeMatrixCellStateListener) {
        if !self.stateListeners.contains(where: {(l) -> Bool in
            l === stateListener
        }) {
            stateListener.onStateChange(self.currentState, isSelected: false)
            self.stateListeners.append(stateListener)
        }
    }
    
    func remove(stateListener: TimeMatrixCellStateListener) {
        if let index = self.stateListeners.index(where: {(l) -> Bool in
            l === stateListener
        }) {
            self.stateListeners.remove(at: index)
        }
    }
    
    private func informOnStateChange(_ state: TimeMatrixCellModel.State, isSelected: Bool) {
        for listener in self.stateListeners {
            listener.onStateChange(state, isSelected: isSelected)
        }
    }
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

func ==(lhs: TimeMatrixCellModel, rhs: TimeMatrixCellModel) -> Bool {
    return lhs === rhs
}
