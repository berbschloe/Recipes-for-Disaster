//
//  AsyncAwait+Extensions.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/27/24.
//

import Foundation

extension AsyncSequence where Self: Sendable {
    func assign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Element>, on object: Root) -> Task<Void, Error> where Root: Sendable {
        Task { [weak object] in
            for try await value in self {
                object?[keyPath: keyPath] = value
            }
        }
    }
}

#if compiler(<6.0) || !hasFeature(InferSendableFromCaptures)
extension KeyPath: @unchecked Sendable {}
#endif
