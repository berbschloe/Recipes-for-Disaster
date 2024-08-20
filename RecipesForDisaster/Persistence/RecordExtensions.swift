//
//  RecordExtensions.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/19/24.
//

import Foundation

extension MealCategoryRecord {
    
    var thumbnailURL: URL? {
        thumbnail.flatMap(URL.init(string:))
    }
    
    var mealRecords: Set<MealRecord> {
        meals as! Set<MealRecord>
    }
}

extension MealRecord {
    var thumbnailURL: URL? {
        thumbnail.flatMap(URL.init(string:))
    }
    
    var isLiked: Bool {
        get { likedAt != nil }
        set { likedAt = newValue ? Date() : nil }
    }
    
    var ingredientRecords: Set<MealIngredientRecord> {
        ingredients as! Set<MealIngredientRecord>
    }
}
