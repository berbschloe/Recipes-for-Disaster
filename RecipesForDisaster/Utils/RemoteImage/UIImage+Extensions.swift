//
//  UIImage+Extensions.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 1/23/25.
//

import UIKit

private let workerQueue = DispatchQueue(
    label: "image-worker-queue",
    attributes: .concurrent
)

extension UIImage {
        
    static func decode(data: Data, scale: CGFloat = 1) async -> UIImage? {
        await withCheckedContinuation { continuation in
            workerQueue.async {
                continuation.resume(returning: UIImage(data: data, scale: scale))
            }
        }
    }
    
    static func load(contentsOfFile path: String) async -> UIImage? {
        await withCheckedContinuation { continuation in
            workerQueue.async {
                continuation.resume(returning: UIImage(contentsOfFile: path))
            }
        }
    }
}

extension UIImage {
    
    func resized(
        to targetSize: CGSize,
        mode: ResizeMode = .fill,
        clipped: Bool = true
    ) -> UIImage {
        let (drawSize, drawRect) = ResizeMode.fill.drawSizeAndRect(
            currentSize: size,
            targetSize: targetSize,
            clipped: clipped
        )
        return UIGraphicsImageRenderer(size: drawSize).image { context in
            draw(in: drawRect)
        }
    }
    
    func resized(
        to targetSize: CGSize,
        mode: ResizeMode = .fill,
        clipped: Bool = true
    ) async -> UIImage {
        await withCheckedContinuation { continuation in
            workerQueue.async {
                let image = self.resized(to: targetSize, mode: mode, clipped: clipped)
                continuation.resume(returning: image)
            }
        }
    }
}
