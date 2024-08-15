//
//  Extensions.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/14/24.
//

import Foundation

extension Sequence {
    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
        return self.sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
}
