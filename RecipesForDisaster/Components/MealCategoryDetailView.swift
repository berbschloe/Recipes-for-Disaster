//
//  MealCategoryDetailView.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/18/24.
//

import SwiftUI

struct MealCategoryDetailView: View {
    
    @StateObject var viewModel: MealCategoryDetailViewModel
    
    var body: some View {
        List(viewModel.meals) { meal in
            NavigationLink {
                MealDetailView(
                    viewModel: viewModel.mealDetail(mealID: meal.id)
                )
            } label: {
                Text(meal.name)
            }
        }
        .navigationTitle(viewModel.categoryNameAndID.name)
        .task {
            await viewModel.fetchMeals()
        }
        .refreshable {
            await viewModel.fetchMeals()
        }
    }
}
