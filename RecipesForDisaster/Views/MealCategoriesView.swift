//
//  MealCategoriesView.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/18/24.
//

import SwiftUI

struct MealCategoriesView: View {
    
    @StateObject var viewModel: MealCategoriesViewModel
    @State var selectedCategoryNameAndID: MealCategoryNameAndID?
    @State var selectedMealID: MealID?
    
    var body: some View {
        NavigationStack {
            List {
                if (!viewModel.favorites.cells.isEmpty) {
                    row(category: viewModel.favorites)
                }
                ForEach(viewModel.categories) {
                    row(category: $0)
                }
            }
            .listStyle(.plain)
            .edgesIgnoringSafeArea(.horizontal)
            .navigationTitle("Recipes for Disaster")
            .task {
                await viewModel.fetchCategories()
            }
            .refreshable {
                await viewModel.fetchCategories()
            }
            .navigationDestination(item: $selectedCategoryNameAndID) { categoryNameAndID in
                MealCategoryDetailView(viewModel: viewModel.categoryDetail(nameAndID: categoryNameAndID))
            }
            .navigationDestination(item: $selectedMealID) { mealID in
                MealDetailView(viewModel: viewModel.mealDetail(mealID: mealID))
            }
        }
    }
    
    func row(category: MealCategoryRowProps) -> some View {
        MealCategoryRow(props: category) { categoryNameAndID in
            if !category.isFavorites {
                selectedCategoryNameAndID = categoryNameAndID
            }
        } mealAction: { mealID in
            selectedMealID = mealID
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .padding(.vertical, 8)
    }
}
