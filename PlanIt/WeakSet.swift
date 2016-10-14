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

class WeakSetIterator<T>: IteratorProtocol {
    private var weakSet: WeakSet<T>
    private var iterator: SetIterator<Weak<T>>
    private var hasNilReference = false
    
    init(weakSet: WeakSet<T>, iterator: SetIterator<Weak<T>>) {
        self.weakSet = weakSet
        self.iterator = iterator
    }
    
    func next() -> T? {
        let next = self.iterator.next()
        if next == nil {
            if self.hasNilReference {
                self.weakSet.reap()
            }
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

class WeakSet<T>: Sequence {
    private var values = Set<Weak<T>>()
    
    init() {}
    
    init(elements: [T]) {
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
        var notNil = Set<Weak<T>>()
        for element in self.values {
            if element.value != nil {
                notNil.insert(element)
            }
        }
        self.values = notNil
    }
    
    func makeIterator() -> WeakSetIterator<T> {
        return WeakSetIterator<T>(weakSet: self, iterator: self.values.makeIterator())
    }
}
