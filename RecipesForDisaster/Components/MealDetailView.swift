//
//  MealDetailView.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/17/24.
//

import SwiftUI

struct MealDetailView: View {
 
    @StateObject var viewModel: MealDetailViewModel
    
    var body: some View {
        Text(viewModel.name)
            .task {
                await viewModel.fetchMeal()
            }
    }
}
