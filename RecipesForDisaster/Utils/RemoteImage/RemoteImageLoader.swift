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
    
    private static let cache: ImageCache = .shared
    
    private let session: URLSession
    private let fileManager: FileManager
    
    init() {
        session = URLSession(configuration: .ephemeral)
        fileManager = FileManager.default
    }
    
    func loadImage(url: URL, targetSize: CGSize? = nil) async throws -> UIImage {
        let cacheKey = cacheKey(url: url, targetSize: targetSize)
        if let memoryImage = Self.cache[cacheKey] {
            return memoryImage
        }
        
        if let diskImage = await loadDiskImage(url: url) {
            return await storeImageToCache(image: diskImage, cacheKey: cacheKey, targetSize: targetSize)
        }
        
        let (image, imageData) = try await loadRemoteImage(url: url)
        
        writeImageToDisk(url: url, data: imageData)
        
        return await storeImageToCache(image: image, cacheKey: cacheKey, targetSize: targetSize)
    }
    
    private func loadRemoteImage(url: URL) async throws -> (UIImage, Data) {
        let request = URLRequest(url: url)
        let (data, _) = try await session.data(for: request)
        
        guard let image = await UIImage.decode(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        return (image, data)
    }
    
    private func loadDiskImage(url: URL) async -> UIImage? {
        guard let fileURL = fileURL(remoteURL: url) else {
            return nil
        }
        
        return await UIImage.load(contentsOfFile: fileURL.path())
    }
    
    private func writeImageToDisk(url: URL, data: Data) {
        guard let fileURL = fileURL(remoteURL: url) else {
            return
        }
        
        let intermediateURL = fileURL.deletingLastPathComponent()
        try? fileManager.createDirectory(at: intermediateURL, withIntermediateDirectories: true)
        
        try? data.write(to: fileURL)
    }
    
    private func storeImageToCache(image: UIImage, cacheKey: String, targetSize: CGSize?) async -> UIImage {
        let image = if let targetSize {
            await image.resized(to: targetSize, aspectMode: .fill, clipped: true)
        } else {
            image
        }
        
        Self.cache[cacheKey] = image
        return image
    }
    
    private func fileURL(remoteURL: URL) -> URL? {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?
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
    
    private func cacheKey(url: URL, targetSize: CGSize?) -> String {
        [fileName(url: url), targetSize?.debugDescription].compactMap { $0 }.joined(separator: ":")
    }
}
