//
//  MealResponses.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/14/24.
//

import Foundation

struct MealsResponse<T: Decodable>: Decodable {
    var meals: [T]?
}

struct MealCategoriesResponse<T: Decodable>: Decodable {
    var categories: [T] = []
}
