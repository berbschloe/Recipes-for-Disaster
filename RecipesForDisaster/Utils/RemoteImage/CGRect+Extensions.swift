//
//  CGRect+Extensions.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 1/27/25.
//

import CoreGraphics

extension CGRect {
    static func centered(targetSize: CGSize, newSize: CGSize, clipped: Bool = false) -> CGRect {
        let originX = (targetSize.width - newSize.width) / 2
        let originY = (targetSize.height - newSize.height) / 2
        return CGRect(origin: CGPoint(x: originX, y: originY), size: clipped ? targetSize : newSize)
    }
}
