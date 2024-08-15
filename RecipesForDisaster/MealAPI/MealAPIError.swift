//
//  MealAPIError.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/14/24.
//

import Foundation

enum MealAPIError: Error {
    case urlError(error: URLError)
    case httpError(status: Int)
    case decoding(error: Error?)
    case contentMissing
}

extension MealAPIError {
    var isCancelled: Bool {
        guard case let .urlError(error) = self else {
            return false
        }
        
        return error.code == .cancelled
    }
}
