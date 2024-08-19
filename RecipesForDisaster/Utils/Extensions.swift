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

extension NSPredicate {
    static func equalTo<Root, Value>(keyPath: KeyPath<Root, Value>, value: Value) -> NSPredicate {
        NSComparisonPredicate(
            leftExpression: NSExpression(forKeyPath: keyPath),
            rightExpression: NSExpression(forConstantValue: value),
            modifier: .direct,
            type: .equalTo
        )
    }
}
