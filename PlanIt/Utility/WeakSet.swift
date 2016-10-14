//
//  WeakSet.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/13/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import Foundation

class WeakSet<T>: Sequence {
    
    // MARK: - Variables
    
    private var values = Set<Weak<T>>()
    
    
    // MARK: - Initialization
    
    init() {}
    
    init(elements: [T]) {
        for element in elements {
            self.insert(element)
        }
    }
    
    
    // MARK: - Set operations
    
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
    
    func makeIterator() -> WeakSetIterator<T> {
        return WeakSetIterator<T>(weakSet: self, iterator: self.values.makeIterator())
    }
    
    
    // MARK: - Memory management
    
    func reap() {
        var notNil = Set<Weak<T>>()
        for element in self.values {
            if element.value != nil {
                notNil.insert(element)
            }
        }
        self.values = notNil
    }
}

class WeakSetIterator<T>: IteratorProtocol {
    
    // MARK: - Variables
    
    private var weakSet: WeakSet<T>
    private var iterator: SetIterator<Weak<T>>
    private var hasNilReference = false
    
    
    // MARK: - Initialization
    
    init(weakSet: WeakSet<T>, iterator: SetIterator<Weak<T>>) {
        self.weakSet = weakSet
        self.iterator = iterator
    }
    
    
    // MARK: - IteratorProtocol protocol methods
    
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
