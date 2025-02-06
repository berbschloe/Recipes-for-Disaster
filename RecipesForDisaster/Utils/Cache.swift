//
//  Cache.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 1/31/25.
//

import Foundation

/// A Swift wrapper around NSCache.
final class Cache<Key: Hashable & Sendable, Value: Sendable>: @unchecked Sendable {
    private let wrapped = NSCache<WrappedKey, Entry>()

    init(
        name: String = "",
        totalCostLimit: Int = 0,
        countLimit: Int = 0
    ) {
        self.name = name
        self.totalCostLimit = totalCostLimit
        self.countLimit = countLimit
    }
    
    var name: String {
        get { wrapped.name }
        set { wrapped.name = newValue }
    }
    
    var totalCostLimit: Int {
        get { wrapped.totalCostLimit }
        set { wrapped.totalCostLimit = newValue }
    }

    var countLimit: Int {
        get { wrapped.countLimit }
        set { wrapped.countLimit = newValue }
    }
    
    func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(value: value)
        wrapped.setObject(entry, forKey: WrappedKey(key))
    }
    
    func insert(_ value: Value, forKey key: Key, cost: Int) {
        let entry = Entry(value: value)
        wrapped.setObject(entry, forKey: WrappedKey(key), cost: max(cost, 0))
    }

    func value(forKey key: Key) -> Value? {
        let entry = wrapped.object(forKey: WrappedKey(key))
        return entry?.value
    }

    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
    
    func removeAll() {
        wrapped.removeAllObjects()
    }
}

protocol CacheCostCalculable: Sendable {
    var cacheCost: Int { get }
}

extension Cache {
    func insert(_ value: Value, forKey key: Key) where Value: CacheCostCalculable {
        insert(value, forKey: key, cost: value.cacheCost)
    }
}

extension Cache {
    subscript(key: Key) -> Value? {
        get { value(forKey: key) }
        set {
            guard let value = newValue else {
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }
}

private extension Cache {
    final class WrappedKey: NSObject, Sendable {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
}

private extension Cache {
    final class Entry: Sendable {
        let value: Value

        init(value: Value) {
            self.value = value
        }
    }
}
