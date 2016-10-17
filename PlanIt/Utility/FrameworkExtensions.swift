//
//  FrameworkExtensions.swift
//  PlanIt
//
//  Created by Richmond Starbuck on 10/16/16.
//  Copyright © 2016 OneTwo Productions. All rights reserved.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}
