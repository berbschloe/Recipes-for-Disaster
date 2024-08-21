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

/// A meal id and name combo struct. Since the MealAPI likes to use name as a lookup key, we sometimes need both it and the id.
struct MealCategoryNameAndID {
    var id: MealCategoryID = ""
    var name: MealCategoryName = ""
}

extension MealCategoryNameAndID: Hashable { }
extension MealCategoryNameAndID: Identifiable { }

extension MealCategory {
    
    var nameAndID: MealCategoryNameAndID {
        MealCategoryNameAndID(id: id, name: name)
    }
    
    var thumbnailURL: URL? {
        thumbnail.flatMap(URL.init(string:))
    }
}
