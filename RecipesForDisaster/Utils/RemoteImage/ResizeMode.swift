//
//  ResizeMode.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 1/30/25.
//

import CoreGraphics

enum ResizeMode: Hashable, Sendable {
    case fit
    case fill
    
    func drawSizeAndRect(currentSize: CGSize, targetSize: CGSize, clipped: Bool = true) -> (drawSize: CGSize, drawRect: CGRect) {
        let drawSize: CGSize
        let drawRect: CGRect
        
        switch self {
        case .fit:
            let newSize = currentSize.resize(to: targetSize, mode: .fit)
            drawSize = clipped ? newSize : targetSize
            if clipped {
                drawRect = CGRect(origin: .zero, size: newSize)
            } else {
                drawRect = newSize.centeredRect(in: targetSize)
            }
        case .fill:
            let newSize = currentSize.resize(to: targetSize, mode: .fill)
            drawSize = clipped ? targetSize : newSize
            drawRect = newSize.centeredRect(in: targetSize)
        }
        
        return (drawSize, drawRect)
    }
}
