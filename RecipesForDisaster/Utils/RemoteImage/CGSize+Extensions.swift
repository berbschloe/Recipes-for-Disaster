//
//  CGSize+Extensions.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 1/27/25.
//

import Foundation
import CoreGraphics

extension CGSize {
    
    func resize(to targetSize: CGSize, mode: ResizeMode) -> CGSize {
        guard width > 0, height > 0, targetSize.width > 0, targetSize.height > 0 else {
            return .zero
        }
        
        let widthRatio = targetSize.width / width
        let heightRatio = targetSize.height / height
        
        let scale = switch mode {
        case .fit: min(widthRatio, heightRatio)
        case .fill: max(widthRatio, heightRatio)
        }
        
        return CGSize(width: width * scale, height: height * scale)
    }
    
    func centeredRect(in container: CGSize) -> CGRect {
        let originX = (container.width - self.width) / 2
        let originY = (container.height - self.height) / 2
        return CGRect(origin: CGPoint(x: originX, y: originY), size: self)
    }
    
    static func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    
    static func *(lhs: CGFloat, rhs: CGSize) -> CGSize {
        CGSize(width: lhs * rhs.width, height: lhs * rhs.height)
    }
}
