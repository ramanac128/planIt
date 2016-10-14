//
//  Weak.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/14/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import Foundation

struct Weak<T>: Hashable {
    private weak var value_: AnyObject?
    var value: T? {
        get {
            return self.value_ as? T
        }
        set {
            self.value_ = newValue as AnyObject
        }
    }
    
    var hashValue: Int {
        get {
            return ObjectIdentifier(self.value_ as AnyObject).hashValue
        }
    }
    
    init (value: T) {
        self.value_ = value as AnyObject
    }
}

func == <T>(lhs: Weak<T>, rhs: Weak<T>) -> Bool {
    return lhs.value as AnyObject === rhs.value as AnyObject
}
