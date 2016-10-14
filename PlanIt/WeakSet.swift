//
//  WeakSet.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/13/16.
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

class WeakSet<T>: Sequence, IteratorProtocol {
    private var values = Set<Weak<T>>()
    
    private var iterator: SetIterator<Weak<T>>
    private var hasNilReference = false
    private var isIterating = false
    
    init() {
        self.iterator = self.values.makeIterator()
    }
    
    init(elements: [T]) {
        self.iterator = self.values.makeIterator()
        for element in elements {
            self.insert(element)
        }
    }
    
    func insert(_ newElement: T) {
        let ref = Weak(value: newElement)
        self.values.insert(ref)
    }
    
    @discardableResult func remove(_ element: T) -> Bool {
        let ref = Weak(value: element)
        return self.values.remove(ref) != nil
    }
    
    func removeAll() {
        self.values.removeAll()
    }
    
    func reap() {
        var toReap = Set<Weak<T>>()
        for element in self.values {
            if element.value == nil {
                toReap.insert(element)
            }
        }
        self.values = self.values.subtracting(toReap)
    }
    
    func next() -> T? {
        if !self.isIterating {
            self.iterator = self.values.makeIterator()
            self.isIterating = true
        }
        let next = self.iterator.next()
        if next == nil {
            if self.hasNilReference {
                self.reap()
                self.hasNilReference = false
            }
            self.isIterating = false
            return nil
        }
        else if let value = next!.value {
            return value
        }
        else {
            self.hasNilReference = true
            return self.next()
        }
    }
}
