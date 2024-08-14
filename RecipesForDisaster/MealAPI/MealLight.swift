//
//  MealLight.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/14/24.
//

import Foundation

typealias MealID = String

struct MealLight {
    var id: MealID = ""
    var name: String?
    var thumbnail: String?
}

extension MealLight: Identifiable { }

extension MealLight: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
        case thumbnail = "strMealThumb"
    }
}

extension MealLight {
    var thumbnailURL: URL? {
        thumbnail.flatMap(URL.init(string:))
    }
}
