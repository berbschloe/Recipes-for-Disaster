//
//  MealDetailView.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/17/24.
//

import SwiftUI

struct MealDetailViewProps {
    var isLiked: Bool = false
    var imageURL: URL?
    var name: String = ""
    var instructions: String = ""
    var ingredients: [MealDetailIngredientRowProps] = []
}

extension MealDetailViewProps: Hashable { }

struct MealDetailIngredientRowProps {
    var id: MealIngredientAndMeasurementID = ""
    var name: String = ""
    var measurement: String = ""
}

extension MealDetailIngredientRowProps: Identifiable { }
extension MealDetailIngredientRowProps: Hashable { }

struct MealDetailView: View {
 
    @StateObject var viewModel: MealDetailViewModel
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: viewModel.props.imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 240)
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(4)
                .contentShape(Rectangle())
                
                Text(viewModel.props.name)
                    .font(.title2)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .foregroundColor(.accentColor)
                
                Text(viewModel.props.instructions)
                    .font(.caption)
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                    .padding(.horizontal, 12)
                
                Text("Ingredients")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                ForEach(viewModel.props.ingredients) { ingredient in
                    HStack {
                        Text(ingredient.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(":")
                            .fixedSize()
                        Text(ingredient.measurement)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.accentColor)
                    }
                    .lineLimit(1)
                    .font(.body)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 12)
                }
            }
            .padding(12)
        }
        .navigationTitle("Recipe")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HeartButton(
                    isLiked: viewModel.props.isLiked,
                    action: viewModel.toggleLike
                )
            }
        }        
        .task {
            await viewModel.fetchMeal()
        }
        // There is a bug with refreshable and ScrollView.
        // For some reason it doesn't clean up the reference to the action.
        .refreshable { [weak viewModel] in
            await viewModel?.fetchMeal()
        }
    }
}
