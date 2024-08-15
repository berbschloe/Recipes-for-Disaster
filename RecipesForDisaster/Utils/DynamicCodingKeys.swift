//
//  DynamicCodingKeys.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/15/24.
//

import Foundation

struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

extension KeyedDecodingContainer<DynamicCodingKeys> {
    func decodeFlattenedStringArray(forKey key: any CodingKey) throws -> [String] {
        var items: [String] = []
        for index in 1... {
            let key = DynamicCodingKeys(stringValue: "\(key.stringValue)\(index)")
            guard let item = try self.decodeIfPresent(String.self, forKey: key) else { break }
            guard !item.trimmingCharacters(in: .whitespaces).isEmpty else { break }
            items.append(item)
        }
        return items
    }
}
