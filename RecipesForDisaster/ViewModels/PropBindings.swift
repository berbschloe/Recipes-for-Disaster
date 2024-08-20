//
//  PropBindings.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/19/24.
//

import Foundation

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
