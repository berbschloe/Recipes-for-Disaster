//
//  RemoteImageLoader.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 1/25/25.
//

import Foundation
import UIKit

actor RemoteImageLoader {
    
    static let shared = RemoteImageLoader()
    
    private static let cache = Cache<CacheKey, UIImage>(
        totalCostLimit: 50 * 1024 * 1024,
        countLimit: 1_000
    )
    
    private let session: URLSession
    private let fileManager: FileManager
    
    init() {
        session = URLSession(configuration: .ephemeral)
        fileManager = FileManager.default
    }
    
    private struct RemoteImageRequest {
        var url: URL
        var targetSize: CGSize?
    }
    
    func loadImage(url: URL, targetSize: CGSize? = nil) async throws -> UIImage {
        let cacheKey = CacheKey(url: url, targetSize: targetSize)
        let fileURL = fileURL(remoteURL: url)
        
        if let cachedImage = accessImageFromCache(cacheKey: cacheKey) {
            return cachedImage
        }
        
        if let diskImage = await loadImageFromDisk(fileURL: fileURL, cacheKey: cacheKey) {
            return diskImage
        }
        
        
        return try await loadImageFromRemote(url: url, fileURL: fileURL, cacheKey: cacheKey)
    }
    
    private func loadImageFromRemote(url: URL, fileURL: URL, cacheKey: CacheKey) async throws -> UIImage {
        let request = URLRequest(url: url)
        let (data, _) = try await session.data(for: request)
        
        guard let image = await UIImage.decode(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        writeImageToDisk(fileURL: fileURL, data: data)
        return await storeImageToCache(image: image, cacheKey: cacheKey)
    }
    
    private func loadImageFromDisk(fileURL: URL, cacheKey: CacheKey) async -> UIImage? {
        guard let image = await UIImage.load(contentsOfFile: fileURL.path()) else {
            return nil
        }
        
        return await storeImageToCache(image: image, cacheKey: cacheKey)
    }
    
    private func writeImageToDisk(fileURL: URL, data: Data) {
        let intermediateURL = fileURL.deletingLastPathComponent()
        try? fileManager.createDirectory(at: intermediateURL, withIntermediateDirectories: true)
        
        try? data.write(to: fileURL)
    }
    
    private func accessImageFromCache(cacheKey: CacheKey) -> UIImage? {
        Self.cache[cacheKey]
    }
    
    private func storeImageToCache(image: UIImage, cacheKey: CacheKey) async -> UIImage {
        let image = if let targetSize = cacheKey.targetSize {
            await image.resized(to: targetSize)
        } else {
            image
        }
        
        Self.cache[cacheKey] = image
        
        return image
    }
    
    private func fileURL(remoteURL: URL) -> URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appending(path: "remote-images-cache", directoryHint: .isDirectory)
            .appending(path: fileName(url: remoteURL), directoryHint: .notDirectory)
    }
    
    private func fileName(url: URL) -> String {
        let string = url.absoluteString
        let hash = string.sha256
        if let ext = string.ext {
            return "\(hash).\(ext)"
        }
        
        return hash
    }
    
    private struct CacheKey: Hashable {
        var url: URL
        var targetSize: CGSize?
        var resizeMode: ResizeMode?
    }
}
