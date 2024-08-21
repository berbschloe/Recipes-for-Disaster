//
//  PropBindings.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/19/24.
//

import Foundation

/*
 PropBindings is a file that maps CoreData "Record" objects to their respective View Props in the UI. View props represent the minimal amount of information needed to represent the view. View Props are meant to be equatable and sendable (thread safe). That is so we can filter out any "noise" from updates that happen in our data layer.
 */

extension MealCategoryRowProps {
    init(record: MealCategoryRecord) {
        self.init(
            categoryNameAndID: MealCategoryNameAndID(
                id: record.id ?? "",
                name: record.name ?? ""
            ),
            cells: record.mealRecords.map {
                MealCategoryRowCellProps(record: $0)
            }.sorted()
        )
    }
}

extension MealCategoryRowCellProps {
    init(record: MealRecord) {
        self.init(
            id: record.id ?? "",
            name: record.name ?? "",
            imageURL: record.thumbnailURL
        )
    }
}

extension MealRowProps {
    init(record: MealRecord) {
        self.init(
            id: record.id ?? "",
            name: record.name ?? "",
            imageURL: record.thumbnailURL,
            isLiked: record.isLiked
        )
    }
}


extension MealDetailViewProps {
    init(record: MealRecord) {
        self.init(
            isLiked: record.isLiked,
            imageURL: record.thumbnailURL,
            name: record.name ?? "",
            instructions: record.instructions ?? "",
            ingredients: record.ingredientRecords
                .sorted(by: \.sortOrder)
                .map { MealDetailIngredientRowProps(record: $0)}
        )
    }
}

extension MealDetailIngredientRowProps {
    init(record: MealIngredientRecord) {
        self.init(
            id: record.id ?? "",
            name: record.name ?? "",
            measurement: record.measurement ?? ""
        )
    }
}
