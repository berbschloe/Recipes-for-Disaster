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
    var ingredients: [String] = []
    var measurements: [String] = []
    var source: String?
    var imageSource: String?
    var creativeCommonsConfirmed: String?
    var dateModified: String?
}

extension MealLookup: Identifiable { }

extension MealLookup: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
        case drinkAlternate = "strDrinkAlternate"
        case category = "strCategory"
        case area = "strArea"
        case instructions = "strInstructions"
        case thumbnail = "strMealThumb"
        case tags = "strTags"
        case youtube = "strYoutube"
        case ingredients = "strIngredient"
        case measurements = "strMeasure"
        case source = "strSource"
        case imageSource = "strImageSource"
        case creativeCommonsConfirmed = "strCreativeCommonsConfirmed"
        case dateModified = "dateModified"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        
        self.id = try container.decode(MealID.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.drinkAlternate = try container.decodeIfPresent(String.self, forKey: .drinkAlternate)
        self.category = try container.decodeIfPresent(String.self, forKey: .category)
        self.area = try container.decodeIfPresent(String.self, forKey: .area)
        self.instructions = try container.decodeIfPresent(String.self, forKey: .instructions)
        self.thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        self.tags = try container.decodeIfPresent(String.self, forKey: .tags)
        self.youtube = try container.decodeIfPresent(String.self, forKey: .youtube)
        self.ingredients = try dynamicContainer.decodeFlattenedStringArray(forKey: CodingKeys.ingredients)
        self.measurements = try dynamicContainer.decodeFlattenedStringArray(forKey: CodingKeys.measurements)
        self.source = try container.decodeIfPresent(String.self, forKey: .source)
        self.imageSource = try container.decodeIfPresent(String.self, forKey: .imageSource)
        self.creativeCommonsConfirmed = try container.decodeIfPresent(String.self, forKey: .creativeCommonsConfirmed)
        self.dateModified = try container.decodeIfPresent(String.self, forKey: .dateModified)
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
    
    var ingredientsAndMeasurements: [MealIngredientAndMeasurement] {
        Array(zip(ingredients, measurements).enumerated().map { entry in
            MealIngredientAndMeasurement(
                id: MealIngredientAndMeasurement.id(mealID: id, index: entry.offset),
                ingredient: entry.element.0,
                measurement: entry.element.1,
                sortOrder: entry.offset
            )
        })
    }
}

typealias MealIngredientAndMeasurementID = String

struct MealIngredientAndMeasurement {
    static func id(mealID: MealID, index: Int) -> MealIngredientAndMeasurementID {
        "\(mealID):\(index)"
    }
    
    var id: MealIngredientAndMeasurementID = ""
    var ingredient: String = ""
    var measurement: String = ""
    var sortOrder: Int = 0
}

extension MealIngredientAndMeasurement: Hashable { }
