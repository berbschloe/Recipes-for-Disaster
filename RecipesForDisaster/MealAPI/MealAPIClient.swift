//
//  MealAPIClient.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/14/24.
//

import Foundation

final class MealAPIClient {
    
    private let apiKey: String
    private let host: URL
    private let urlSession = URLSession(configuration: .default)
    
    init(apiKey: String = "1") {
        self.apiKey = apiKey
        host = URL(string: "https://themealdb.com/api/json/v1/\(apiKey)/")!
    }
    
    func categories() async throws -> [MealCategory] {
        return []
    }
    
    func meals(category: MealCategoryName) async throws -> [MealLight] {
        return []
    }
    
    func mealLookup(id: MealID) async throws -> MealLookup {
        return MealLookup(id: id)
    }
}
