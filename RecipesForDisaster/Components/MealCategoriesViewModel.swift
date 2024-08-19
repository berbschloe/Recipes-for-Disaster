//
//  MealCategoriesViewModel.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/18/24.
//

import Foundation

@MainActor
final class MealCategoriesViewModel: ObservableObject {
    
    @Published private(set) var categories: [MealCategory] = []
    
    private let modules: CoreModules
    
    init(modules: CoreModules) {
        self.modules = modules
        
        modules.store.categoriesPublisher().map { categories in
            categories.map {
                MealCategory(
                    id: $0.id ?? "",
                    name: $0.name ?? "",
                    thumbnail: $0.thumbnail,
                    body: $0.body
                )
            }
        }
        .removeDuplicates()
        .receivePostFirst(on: DispatchQueue.main)
        .assign(to: &$categories)
    }
    
    func categoryDetail(
        nameAndID: MealCategoryNameAndID
    ) -> MealCategoryDetailViewModel {
        MealCategoryDetailViewModel(
            categoryNameAndID: nameAndID,
            modules: modules
        )
    }
    
    func fetchCategories() async {
        do {
            let categories = try await modules.client.categories()
            try await modules.store.saveCategories(categories: categories)
        } catch {
            print("Fetch categories failed, error: \(error)")
        }
    }
}
