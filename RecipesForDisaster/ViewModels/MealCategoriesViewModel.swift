//
//  MealCategoriesViewModel.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/18/24.
//

import Foundation

@MainActor
final class MealCategoriesViewModel: ObservableObject {
    
    @Published private(set) var favorites: MealCategoryRowProps = MealCategoryRowProps()
    @Published private(set) var categories: [MealCategoryRowProps] = []
    
    private let modules: CoreModules
    
    init(modules: CoreModules) {
        self.modules = modules
        
        modules.store.favoriteMealsPublisher()
            .map { records in
                return MealCategoryRowProps.favorites(
                    cells: records.map { MealCategoryRowCellProps(record:  $0) }
                )
            }
            .removeDuplicates()
            .receivePostFirst(on: DispatchQueue.main)
            .assign(to: &$favorites)
        
        modules.store.categoriesPublisher()
            .mapMany { MealCategoryRowProps(record: $0) }
            .removeDuplicates()
            .receivePostFirst(on: DispatchQueue.main)
            .assign(to: &$categories)
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
                    group.addTask { [self] in
                        let meals = try await modules.client.meals(category: category.name)
                        try await modules.store.saveMeals(meals: meals, categoryName: category.name)
                    }
                }
                
                try await group.waitForAll()
            }
        } catch {
            print("Fetch categories failed, error: \(error)")
        }
    }
}
