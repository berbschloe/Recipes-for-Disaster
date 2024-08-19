//
//  MealCategoriesView.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/18/24.
//

import SwiftUI

struct MealCategoriesView: View {
    
    @StateObject var viewModel: MealCategoriesViewModel
    
    var body: some View {
        NavigationStack {
            List(viewModel.categories) { category in
                NavigationLink {
                    MealCategoryDetailView(
                        viewModel: viewModel.categoryDetail(nameAndID: category.nameAndID)
                    )
                } label: {
                    Text(category.name)
                }
            }
            .navigationTitle("Categories")
            .task {
                await viewModel.fetchCategories()
            }
            .refreshable {
                await viewModel.fetchCategories()
            }
        }
    }
}
