//
//  MealsView.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/14/24.
//

import SwiftUI
import Combine

private let client = MealAPIClient()
private let store = RecordStore()

extension Publisher where Failure == Never {
    func asyncStream() -> AsyncStream<Output> {
        AsyncStream { continuation in
            let cancellable = self.sink { _ in
                continuation.finish()
            } receiveValue: {
                continuation.yield($0)
            }

            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}

@MainActor
final class MealsViewModel: ObservableObject {
    @Published private(set) var categories: [MealCategory] = []
    
    init() {
        store.categoriesPublisher().map { categories in
            return categories.map {
                MealCategory(
                    id: $0.id ?? "",
                    name: $0.name ?? "",
                    thumbnail: $0.thumbnail,
                    body: $0.body
                )
            }
        }
        .removeDuplicates()
        .receive(on: DispatchQueue.main)
        .assign(to: &$categories)
    }
    
    func fetchCategories() async {
        do {
            let categories = try await client.categories()
            try await store.saveCategories(categories: categories)
        } catch {
            print("Fetch categories failed, error: \(error)")
        }
    }
}

@MainActor
struct MealsView: View {
    
    @StateObject var viewModel = MealsViewModel()
    
    var body: some View {
        List(viewModel.categories) { category in
            Text(category.name)
        }
        .refreshable {
            await viewModel.fetchCategories()
        }
        .task {
            await viewModel.fetchCategories()
        }
    }
}

#Preview {
    MealsView()
}
