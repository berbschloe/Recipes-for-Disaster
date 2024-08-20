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
    
    @Published private(set) var body: String = ""
    @Published private(set) var meals: [MealRowProps] = []
    
    private let modules: CoreModules
    
    init(
        categoryNameAndID: MealCategoryNameAndID,
        modules: CoreModules
    ) {
        self.categoryNameAndID = categoryNameAndID
        self.modules = modules
        
        modules.store
            .categoryPublisher(id: categoryNameAndID.id)
            .map { $0.body ?? "" }
            .receivePostFirst(on: DispatchQueue.main)
            .assign(to: &$body)
        
        modules.store
            .mealsPublisher(categoryID: categoryNameAndID.id)
            .mapMany { MealRowProps(record: $0) }
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
    
    func toggleLike(mealID: MealID) {
        Task { [modules] in
            do {
                try await modules.store.toggleLike(mealID: mealID)
            } catch {
                print("Failed to like meal: \(mealID), error: \(error)")
            }
        }
    }
}
