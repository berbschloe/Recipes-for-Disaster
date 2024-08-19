//
//  MealCategoryDetailViewModel.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/18/24.
//

import Foundation

@MainActor
final class MealCategoryDetailViewModel: ObservableObject {
    
    let categoryNameAndID: MealCategoryNameAndID
    
    @Published private(set) var category: MealCategory?
    @Published private(set) var meals: [MealLight] = []
    
    private let modules: CoreModules
    
    init(
        categoryNameAndID: MealCategoryNameAndID,
        modules: CoreModules
    ) {
        self.categoryNameAndID = categoryNameAndID
        self.modules = modules
        
        modules.store
            .categoryPublisher(id: categoryNameAndID.id)
            .map { category in
                category.map {
                    MealCategory(
                        id: $0.id ?? "",
                        name: $0.name ?? "",
                        thumbnail: $0.thumbnail ?? "",
                        body: $0.body ?? ""
                    )
                }
            }
            .receivePostFirst(on: DispatchQueue.main)
            .assign(to: &$category)
        
        modules.store
            .mealsPublisher(categoryID: categoryNameAndID.id)
            .map { meals in
                meals.map {
                    MealLight(
                        id: $0.id ?? "",
                        name: $0.name ?? "",
                        thumbnail: $0.thumbnail
                    )
                }
            }
            .receivePostFirst(on: DispatchQueue.main)
            .assign(to: &$meals)
    }
    
    func mealDetail(mealID: MealID) -> MealDetailViewModel {
        MealDetailViewModel(mealID: mealID, modules: modules)
    }
    
    func fetchMeals() async {
        do {
            let meals = try await modules.client.meals(category: categoryNameAndID.name)
            try await modules.store.saveMeals(meals: meals, categoryName: categoryNameAndID.name)
        } catch {
            print("Fetch meals failed, error: \(error)")
        }
    }
}
