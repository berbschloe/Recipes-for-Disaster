//
//  RecipesForDisasterApp.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/14/24.
//

import SwiftUI

final class CoreModules {
    let client: MealAPIClientProtocol = MealAPIClient()
    let store: MealRecordStoreProtocol = MealRecordStore()
}

private let modules = CoreModules()

@main
struct RecipesForDisasterApp: App {
    
    var body: some Scene {
        WindowGroup {
            MealCategoriesView(
                viewModel: MealCategoriesViewModel(modules: modules)
            )
        }
    }
}
