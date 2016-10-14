//
//  Delay.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/13/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import Foundation

func delay(_ delaySeconds: Double, closure: @escaping ()->()) {
    let when = DispatchTime.now() + delaySeconds
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

func delayedRepeater(delay delaySeconds: Double, count: Int = -1, closure: @escaping ()->()) {
    var n = 0
    while count < 0 || n < count {
        delay(delaySeconds, closure: closure)
        n += 1
    }
}
