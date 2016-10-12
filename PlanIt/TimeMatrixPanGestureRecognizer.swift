//
//  TimeMatrixPanGestureRecognizer.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/12/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class TimeMatrixPanGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
}
