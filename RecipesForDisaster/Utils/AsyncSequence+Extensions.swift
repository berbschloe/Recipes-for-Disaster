//
//  Async+Extensions.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/16/24.
//

import Foundation

actor PreviusDuplicateDetector<Value> {
    
    private var lastValue: Value?
    private let isDuplicate: (Value, Value) -> Bool
    
    init(
        initialValue: Value? = nil,
        isDuplicate: @Sendable @escaping (Value, Value) -> Bool
    ) {
        self.lastValue = initialValue
        self.isDuplicate = isDuplicate
    }

    func isDuplicate(_ value: Value) -> Bool {
        defer { lastValue = value }
        if let lastValue, isDuplicate(lastValue, value) {
            return true
        }
        return false
    }
    
    func isUnique(_ value: Value) -> Bool {
        !isDuplicate(value)
    }
}

extension PreviusDuplicateDetector where Value: Equatable {
    init(initialValue: Value? = nil) {
        self.init(initialValue: initialValue) { $0 == $1 }
    }
}

extension AsyncSequence {

    func removeDuplicates(initialValue: Element? = nil) -> AsyncFilterSequence<Self> where Self.Element: Equatable {
        let detector = PreviusDuplicateDetector<Element>(initialValue: initialValue)
        return self.filter {
            await detector.isUnique($0)
        }
    }
}
