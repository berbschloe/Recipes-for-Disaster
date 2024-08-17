//
//  MealCategory.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/14/24.
//

import Foundation

typealias MealCategoryID = String
typealias MealCategoryName = String

struct MealCategory {
    var id: MealCategoryID = ""
    var name: MealCategoryName = ""
    var thumbnail: String?
    var body: String?
}

extension MealCategory: Hashable { }
extension MealCategory: Identifiable { }

extension MealCategory: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "idCategory"
        case name = "strCategory"
        case thumbnail = "strCategoryThumb"
        case body = "strCategoryDescription"
    }
}

extension MealCategory {
    var thumbnailURL: URL? {
        thumbnail.flatMap(URL.init(string:))
    }
}
