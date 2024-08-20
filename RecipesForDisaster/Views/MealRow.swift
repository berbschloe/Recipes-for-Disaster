//
//  MealRow.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/19/24.
//

import SwiftUI

struct MealRowProps {
    var id: MealID = ""
    var name: String = ""
    var imageURL: URL?
    var isLiked: Bool = false
}

extension MealRowProps: Identifiable { }
extension MealRowProps: Hashable { }

struct MealRow: View {
    
    var props: MealRowProps
    var action: (MealID) -> Void = { _ in }
    var likeAction: (MealID) -> Void = { _ in }
    
    var body: some View {
        VStack {
            HStack {
                Text(props.name)
                    .font(.headline)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                
                HeartButton(isLiked: props.isLiked) {
                    likeAction(props.id)
                }
            }
            
            Button {
                action(props.id)
            } label: {
                AsyncImage(url: props.imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(4)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Divider().padding(.top, 8)
        }
    }
}

#Preview {
    MealRow(
        props: MealRowProps(
            name: "Krispy Kreme Donut",
            imageURL: URL(string: "https://www.themealdb.com/images/media/meals/4i5cnx1587672171.jpg")
        )
    )
}
