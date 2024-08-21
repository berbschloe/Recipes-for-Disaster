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
    private let taskRegistry = TaskRegistry()
    
    init(
        categoryNameAndID: MealCategoryNameAndID,
        modules: CoreModules
    ) {
        self.categoryNameAndID = categoryNameAndID
        self.modules = modules
        
        taskRegistry.subscribe {
            modules.store.categoryStream(id: categoryNameAndID.id) {
                $0.first?.body ?? ""
            }
        } onNext: { [weak self] in
            self?.body = $0
        }
        
        taskRegistry.subscribe {
            modules.store.mealsStream(categoryID: categoryNameAndID.id) {
                $0.map { MealRowProps(record: $0) }
            }
        } onNext: { [weak self] in
            self?.meals = $0
        }
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
