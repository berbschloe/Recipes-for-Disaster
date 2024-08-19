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
    
    @Published private(set) var name: String = ""
    
    private let modules: CoreModules
    
    init(mealID: MealID, modules: CoreModules) {
        self.mealID = mealID
        self.modules = modules
        
        modules.store.mealPublisher(id: mealID)
            .map { meal in
                meal.flatMap(\.name) ?? ""
            }
            .removeDuplicates()
            .receivePostFirst(on: DispatchQueue.main)
            .assign(to: &$name)
    }
    
    func fetchMeal() async {
        do {
            let meal = try await modules.client.mealLookup(id: mealID)
            try await modules.store.saveMeal(meal: meal)
        } catch {
            print("Fetch meal failed, error: \(error)")
        }
    }
}
