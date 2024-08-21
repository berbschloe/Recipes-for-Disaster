//
//  MealCategoryRow.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/18/24.
//

import Foundation
import SwiftUI

struct MealCategoryRowProps {
    var categoryNameAndID: MealCategoryNameAndID = MealCategoryNameAndID()
    var cells: [MealCategoryRowCellProps] = []
}

extension MealCategoryRowProps {
    static func favorites(
        cells: [MealCategoryRowCellProps]
    ) -> MealCategoryRowProps {
        MealCategoryRowProps(
            categoryNameAndID: MealCategoryNameAndID(
                id: "favorites",
                name: "Favorites"
            ),
            cells: cells
        )
    }
    
    var isFavorites: Bool {
        id == "favorites"
    }
}

extension MealCategoryRowProps {
    var title: String { categoryNameAndID.name }
}

extension MealCategoryRowProps: Hashable { }

extension MealCategoryRowProps: Identifiable {
    var id: MealCategoryID { categoryNameAndID.id }
}


struct MealCategoryRowCellProps {
    var id: MealID = ""
    var name: String = ""
    var imageURL: URL?
}

extension MealCategoryRowCellProps: Hashable { }
extension MealCategoryRowCellProps: Identifiable {}
extension MealCategoryRowCellProps: Comparable {
    static func < (lhs: MealCategoryRowCellProps, rhs: MealCategoryRowCellProps) -> Bool {
        (lhs.name, lhs.id) < (rhs.name, rhs.id)
    }
}

struct MealCategoryRow: View {
    
    var props: MealCategoryRowProps
    var categoryAction: (MealCategoryNameAndID) -> Void = { _ in }
    var mealAction: (MealID) -> Void = { _ in }
    
    var body: some View {
        VStack(spacing: 4) {
            Button {
                categoryAction(props.categoryNameAndID)
            } label: {
                HStack(spacing: 4) {
                    if props.isFavorites {
                        Image(systemName: "heart.fill")
                    }
                    
                    Text(props.title)
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 16)
                .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    if !props.cells.isEmpty {
                        ForEach(props.cells) { cell in
                            self.cell(props: cell)
                        }
                    } else {
                        ForEach(0..<5, id: \.self) { _ in
                            cell(props: nil)
                        }
                    }
                }
                .fixedSize()
                .padding(.horizontal, 4)
            }
            .scrollIndicators(.hidden)
        }
    }
    
    func cell(props: MealCategoryRowCellProps?) -> some View {
        Button {
            if let mealID = props?.id {
                mealAction(mealID)
            }
        } label: {
            ZStack(alignment: .bottom) {
                AsyncImage(url: props?.imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 160, height: 90)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(2)
                .contentShape(Rectangle())
                
                Text(props?.name ?? "")
                    .font(.system(size: 11))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                    .background(Color(UIColor.tertiarySystemBackground).opacity(0.6))
            }
            .frame(width: 160, height: 90)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MealCategoryRow(
        props: MealCategoryRowProps(categoryNameAndID: MealCategoryNameAndID(name: "Deserts"))
    )
}
