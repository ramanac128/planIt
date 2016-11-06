//
//  TimeMatrixModelManager.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 11/6/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit

protocol TimeMatrixModelListener: class {
    func onChange(model: TimeMatrixModel?)
}

class TimeMatrixModelManager {
    static var instance = TimeMatrixModelManager()
    
    var model: TimeMatrixModel? {
        didSet {
            for listener in modelListeners {
                listener.onChange(model: self.model)
            }
        }
    }
    var modelListeners = WeakSet<TimeMatrixModelListener>()
    
    private init() {}
}
