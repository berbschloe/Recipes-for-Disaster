//
//  UIImage+Extensions.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 1/23/25.
//

import UIKit

extension UIImage {
    
    private static let decodeQueue = DispatchQueue(label: "decode-queue")
    
    static func decode(data: Data) async -> UIImage? {
        await withCheckedContinuation { continuation in
            decode(data: data) { image in
                continuation.resume(returning: image)
            }
        }
    }
    
    static func decode(data: Data, completion: @escaping @Sendable (UIImage?) -> Void) {
        decodeQueue.async {
            completion(UIImage(data: data))
        }
    }
}
