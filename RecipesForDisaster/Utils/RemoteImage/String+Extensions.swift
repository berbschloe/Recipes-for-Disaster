//
//  String+Extensions.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 1/24/25.
//

import Foundation
import CryptoKit
import CommonCrypto

extension String {
    
    var sha256: String {
        guard let data = data(using: .utf8) else {
            return self
        }
        
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    var ext: String? {
        guard let firstSegment = split(separator: "@").first else {
            return nil
        }

        var ext = ""
        if let index = firstSegment.lastIndex(of: ".") {
            let extRange = firstSegment.index(index, offsetBy: 1)..<firstSegment.endIndex
            ext = String(firstSegment[extRange])
        }
        return ext.count > 0 ? ext : nil
    }
}
