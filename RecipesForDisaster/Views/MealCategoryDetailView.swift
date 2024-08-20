//
//  MealCategoryDetailView.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/18/24.
//

import SwiftUI

struct MealCategoryDetailView: View {
    
    @StateObject var viewModel: MealCategoryDetailViewModel
    @State var selectedMealID: MealID?
    
    var body: some View {
        List {
            Text(viewModel.body)
                .font(.title3)
                .foregroundStyle(Color(UIColor.secondaryLabel))
                .listRowSeparator(.hidden)
            
            ForEach(viewModel.meals) { props in
                MealRow(props: props) { mealID in
                    selectedMealID = mealID
                } likeAction: { mealID in
                    viewModel.toggleLike(mealID: mealID)
                }
            }
            .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 16, trailing: 8))
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationTitle(viewModel.categoryNameAndID.name)
        .task {
            await viewModel.fetchMeals()
        }
        .refreshable {
            await viewModel.fetchMeals()
        }.navigationDestination(item: $selectedMealID) { mealID in
            MealDetailView(
                viewModel: viewModel.mealDetail(mealID: mealID)
            )
        }
    }
}
