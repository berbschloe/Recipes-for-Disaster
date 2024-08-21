//
//  RecipesForDisasterApp.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/14/24.
//

import SwiftUI

final class CoreModules: Sendable {
    let client: MealAPIClientProtocol = MealAPIClient()
    let store: MealRecordStoreProtocol = MealRecordStore()
}

@main
struct RecipesForDisasterApp: App {
    
    var body: some Scene {
        WindowGroup {
            MealCategoriesView(
                viewModel: MealCategoriesViewModel(
                    modules: CoreModules()
                )
            )
        }
    }
}
