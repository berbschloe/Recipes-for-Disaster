//
//  ImageCache.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 1/27/25.
//

import Foundation
import UIKit

final class ImageCache: @unchecked Sendable {
    private let cache = NSCache<NSString, UIImage>()
    
    /// Shared singleton instance for global usage.
    static let shared = ImageCache()
    
    private init() {
        // Optional: Customize cache settings
        cache.countLimit = 1_000 // Max number of items
        cache.totalCostLimit = 50 * 1024 * 1024 // Max memory usage in bytes (50 MB)
    }
    
    /// Stores an image in the cache with the given key.
    func setImage(_ image: UIImage, forKey key: String) {
        let cost = (image.cgImage?.height ?? 0) * (image.cgImage?.bytesPerRow ?? 0)
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
    /// Retrieves an image from the cache for the given key.
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    /// Removes an image from the cache for the given key.
    func removeImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    /// Clears all images from the cache.
    func clearCache() {
        cache.removeAllObjects()
    }
    
    /// Subscript for easy access to images by key.
    subscript(key: String) -> UIImage? {
            get {
                return getImage(forKey: key)
            }
            set {
                if let image = newValue {
                    setImage(image, forKey: key)
                } else {
                    removeImage(forKey: key)
                }
            }
        }
}
