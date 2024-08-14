//
//  MealLookup.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/14/24.
//

import Foundation

struct MealLookup {
    var id: MealID = ""
    var name: String?
    var drinkAlternate: String?
    var category: MealCategoryName?
    var area: String?
    var instructions: String?
    var thumbnail: String?
    var tags: String?
    var youtube: String?
    var ingredients: [String] = [] // TODO: Handle named conversion
    var measurements: [String] = [] // TODO: Handle named conversion
    var source: String?
    var imageSource: String?
    var creativeCommonsConfirmed: String?
    var dateModified: String?
}

extension MealLookup: Identifiable { }

extension MealLookup: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case drinkAlternate = "strDrinkAlternate"
        case name = "strMeal"
        case category = "strCategory"
        case area = "strArea"
        case instructions = "strInstructions"
        case thumbnail = "strMealThumb"
        case tags = "strTags"
        case youtube = "strYoutube"
        case ingredients = "strIngredient"
        case measurements = "strMeasurement"
        case source = "strSource"
        case imageSource = "strImageSource"
        case creativeCommonsConfirmed = "strCreativeCommonsConfirmed"
        case dateModified = "dateModified"
    }
}

extension MealLookup {
    var thumbnailURL: URL? {
        thumbnail.flatMap(URL.init(string:))
    }
    
    var youtubeURL: URL? {
        youtube.flatMap(URL.init(string:))
    }
    
    var sourceURL: URL? {
        source.flatMap(URL.init(string:))
    }
}
