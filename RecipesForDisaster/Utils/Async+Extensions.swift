//
//  Async+Extensions.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/16/24.
//

import Foundation

actor PreviusDuplicateDetector<Value: Equatable> {
    private var lastValue: Value?
    
    init(initialValue: Value? = nil) {
        self.lastValue = initialValue
    }

    func isDuplicate(_ value: Value) -> Bool {
        if let lastValue, lastValue == value {
            return true
        }
        lastValue = value
        return false
    }
    
    func isUnique(_ value: Value) -> Bool {
        !isDuplicate(value)
    }
}

extension AsyncSequence {

    func filterDuplicate() -> AsyncFilterSequence<Self> where Self.Element: Equatable {
        let detector = PreviusDuplicateDetector<Element>()
        return self.filter {
            await detector.isUnique($0)
        }
    }
}
