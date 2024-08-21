//
//  MealResponses.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/14/24.
//

import Foundation

/// Top level container for a meals api response
struct MealsResponse<T: Decodable>: Decodable {
    var meals: [T]?
}

/// Top level container for a categories api response
struct MealCategoriesResponse<T: Decodable>: Decodable {
    var categories: [T] = []
}
