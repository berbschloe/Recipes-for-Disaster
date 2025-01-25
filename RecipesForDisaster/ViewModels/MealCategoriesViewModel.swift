//
//  MealCategoriesViewModel.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/18/24.
//

import Foundation
import Combine

@MainActor
final class MealCategoriesViewModel: ObservableObject {
    
    @Published private(set) var favorites: MealCategoryRowProps = MealCategoryRowProps()
    @Published private(set) var categories: [MealCategoryRowProps] = []
    
    private let modules: CoreModules
    private let taskRegistry = TaskRegistry()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(modules: CoreModules) {
        self.modules = modules
        taskRegistry.subscribe {
            modules.store.favoriteMealsStream {
                MealCategoryRowProps.favorites(
                    cells: $0.map { MealCategoryRowCellProps(record: $0) }
                )
            }
        } onNext: { @MainActor [weak self] in
            self?.favorites = $0
        }
        
        taskRegistry.subscribe {
            modules.store.categoriesStream {
                $0.map { MealCategoryRowProps(record: $0) }
            }
        } onNext: { @MainActor [weak self] in
            self?.categories = $0
        }
    }
    
    func categoryDetail(
        nameAndID: MealCategoryNameAndID
    ) -> MealCategoryDetailViewModel {
        MealCategoryDetailViewModel(categoryNameAndID: nameAndID, modules: modules)
    }
    
    func mealDetail(mealID: MealID) -> MealDetailViewModel {
        MealDetailViewModel(mealID: mealID, modules: modules)
    }
    
    func fetchCategories() async {
        do {
            let categories = try await modules.client.categories()
            try await modules.store.saveCategories(categories: categories)
            
            try await withThrowingTaskGroup(of: Void.self) { group in
                categories.forEach { category in
                    _ = group.addTaskUnlessCancelled { [self] in
                        let meals = try await modules.client.meals(category: category.name)
                        try await modules.store.saveMeals(meals: meals, categoryName: category.name)
                    }
                }
                
                for try await _ in group { }
            }
        } catch {
            print("Fetch categories failed, error: \(error)")
        }
    }
}
