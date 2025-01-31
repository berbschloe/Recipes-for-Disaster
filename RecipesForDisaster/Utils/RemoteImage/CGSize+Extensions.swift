//
//  CGSize+Extensions.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 1/27/25.
//

import Foundation
import CoreGraphics

enum AspectMode: String, Hashable {
    case fit
    case fill
}

extension CGSize {
    
    func resized(to targetSize: CGSize, aspectMode: AspectMode) -> CGSize {
        guard width > 0, height > 0, targetSize.width > 0, targetSize.height > 0 else {
            return .zero
        }

        let widthRatio = targetSize.width / width
        let heightRatio = targetSize.height / height

        switch aspectMode {
        case .fit:
            let scale = min(widthRatio, heightRatio)
            return CGSize(width: width * scale, height: height * scale)
        case .fill:
            let scale = max(widthRatio, heightRatio)
            return CGSize(width: width * scale, height: height * scale)
        }
    }
    
    static func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    
    static func *(lhs: CGFloat, rhs: CGSize) -> CGSize {
        CGSize(width: lhs * rhs.width, height: lhs * rhs.height)
    }
}
