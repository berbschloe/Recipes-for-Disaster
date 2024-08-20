//
//  HeartButton.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/20/24.
//

import SwiftUI

struct HeartButton: View {
    
    var isLiked: Bool = false
    var action: () -> Void = { }
    
    var body: some View {
        Button(
            "",
            systemImage: isLiked ? "heart.fill" : "heart",
            action: action
        )
        .buttonStyle(.plain)
        .foregroundColor(.accentColor)
        .symbolEffect(.bounce, value: isLiked)
        .imageScale(.large)
    }
}

#Preview {
    HeartButton()
}
