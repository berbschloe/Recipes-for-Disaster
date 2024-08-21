//
//  MealDetailViewModel.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/18/24.
//

import Foundation

@MainActor
final class MealDetailViewModel: ObservableObject {
    
    let mealID: MealID
    
    @Published private(set) var props: MealDetailViewProps = MealDetailViewProps()
    
    private let modules: CoreModules
    private let taskRegistry = TaskRegistry()
    
    init(mealID: MealID, modules: CoreModules) {
        self.mealID = mealID
        self.modules = modules
        
        taskRegistry.subscribe {
            modules.store.mealStream(id: mealID) {
                $0.first.map {
                    MealDetailViewProps(record: $0)
                }
            }.compactMap { $0 }
        } onNext: { [weak self] in
            self?.props = $0
        }
    }
    
    func fetchMeal() async {
        do {
            let meal = try await modules.client.mealLookup(id: mealID)
            try await modules.store.saveMeal(meal: meal)
        } catch {
            print("Fetch meal failed, error: \(error)")
        }
    }
    
    func toggleLike() {
        Task { [modules] in
            do {
                try await modules.store.toggleLike(mealID: mealID)
            } catch {
                print("Failed to like meal: \(mealID), error: \(error)")
            }
        }
    }
}
