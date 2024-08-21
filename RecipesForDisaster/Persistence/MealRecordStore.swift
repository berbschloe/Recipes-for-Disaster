//
//  MealRecordStore.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/16/24.
//

import CoreData
import Combine

protocol MealRecordStoreProtocol: Sendable {

    func categoriesStream<T>(
        _ transform: @escaping @Sendable ([MealCategoryRecord]) -> T
    ) -> FetchedResultsStream<T> where T : Equatable

    func favoriteMealsStream<T>(
        _ transform: @escaping @Sendable ([MealRecord]) -> T
    ) -> FetchedResultsStream<T> where T : Equatable

    func categoryStream<T>(
        id: MealCategoryID, _ transform: @escaping @Sendable ([MealCategoryRecord]) -> T
    ) -> FetchedResultsStream<T> where T : Equatable

    func mealsStream<T>(
        categoryID: MealCategoryID, _ transform: @escaping @Sendable ([MealRecord]) -> T
    ) -> FetchedResultsStream<T> where T : Equatable

    func mealStream<T>(
        id: MealID, _ transform: @escaping @Sendable ([MealRecord]) -> T
    ) -> FetchedResultsStream<T> where T : Equatable
    
    func toggleLike(mealID: MealID) async throws
    func saveCategories(categories: [MealCategory]) async throws
    func saveMeals(meals: [MealLight], categoryName: MealCategoryName) async throws
    func saveMeal(meal: MealLookup) async throws
}

final class MealRecordStore: MealRecordStoreProtocol, @unchecked Sendable {
    
    private let name = "RecipesForDisaster"
    private let container: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    private var viewContext: NSManagedObjectContext { container.viewContext }
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: name)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(
                fileURLWithPath: "/dev/null"
            )
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load store, error: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        
        backgroundContext = container.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        backgroundContext.automaticallyMergesChangesFromParent = true
    }
    
    func categoriesStream<T: Equatable>(
        _ transform: @Sendable @escaping ([MealCategoryRecord]) -> T
    ) -> FetchedResultsStream<T> {
        let fetchRequest: NSFetchRequest = MealCategoryRecord.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \MealCategoryRecord.name, ascending: true)
        ]
        return backgroundContext.fetchStream(
            fetchRequest: fetchRequest,
            transform: transform
        )
    }
    
    func favoriteMealsStream<T: Equatable>(
        _ transform: @Sendable @escaping ([MealRecord]) -> T
    ) -> FetchedResultsStream<T> {
        let fetchRequest = MealRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "%K != %@", "likedAt", NSNull()
        )
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \MealRecord.likedAt, ascending: false)
        ]
        return backgroundContext.fetchStream(
            fetchRequest: fetchRequest,
            transform: transform
        )
    }
    
    func categoryStream<T: Equatable>(
        id: MealCategoryID, _
        transform: @Sendable @escaping ([MealCategoryRecord]) -> T
    ) -> FetchedResultsStream<T> {
        backgroundContext.fetchStream(
            fetchRequest: MealCategoryRecord.fetchRequest(id: id),
            transform: transform
        )
    }
    
    func mealsStream<T: Equatable>(
        categoryID: MealCategoryID,
        _ transform: @Sendable @escaping ([MealRecord]) -> T
    ) -> FetchedResultsStream<T> {
        let fetchRequest = MealRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "%K == %@", "category.id", categoryID as CVarArg
        )
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \MealCategoryRecord.name, ascending: true)
        ]
        return backgroundContext.fetchStream(fetchRequest: fetchRequest, transform: transform)
    }
    
    func mealStream<T: Equatable>(
        id: MealID,
        _ transform: @Sendable @escaping ([MealRecord]) -> T
    ) -> FetchedResultsStream<T> {
        backgroundContext.fetchStream(
            fetchRequest: MealRecord.fetchRequest(id: id),
            transform: transform
        )
    }
    
    func toggleLike(mealID: MealID) async throws {
        try await performSave(name: "ToggleLike(mealID: \(mealID)") { context in
            guard let record = try context.fetch(MealRecord.self, id: mealID) else { return }
            record.isLiked.toggle()
        }
    }
    
    func saveCategories(categories: [MealCategory]) async throws {
        try await performSave(name: "Categories(count: \(categories.count))") { context in
            for category in categories {
                let record = try context.fetchOrCreate(MealCategoryRecord.self, id: category.id)
                
                record.name = category.name
                record.thumbnail = category.thumbnail
                record.body = category.body
            }
        }
    }
    
    func saveMeals(meals: [MealLight], categoryName: MealCategoryName) async throws {
        try await performSave(name: "Meals(count: \(meals.count), category: \(categoryName))") { context in
            let categoryRecord = try context.fetchOrCreate(
                MealCategoryRecord.self,
                keyPath: \.name,
                value: categoryName
            )
            
            for meal in meals {
                let record = try context.fetchOrCreate(MealRecord.self, id: meal.id)
                record.name = meal.name
                record.thumbnail = meal.thumbnail
                record.category = categoryRecord
            }
        }
    }
    
    func saveMeal(meal: MealLookup) async throws {
        try await performSave(name: "Meal(id: \(meal.id))") { context in
            let record = try context.fetchOrCreate(MealRecord.self, id: meal.id)
            
            record.name = meal.name
            record.drinkAlternate = meal.drinkAlternate
            record.area = meal.area
            record.instructions = meal.instructions
            record.thumbnail = meal.thumbnail
            record.tags = meal.tags
            record.youtube = meal.youtube
            record.source = meal.source
            record.imageSource = meal.imageSource
            record.creativeCommonsConfirmed = meal.creativeCommonsConfirmed
            record.dateModified = meal.dateModified
            
            context.delete(record.ingredients)
            try meal.ingredientsAndMeasurements.forEach { ingredient in
                let ingredientRecord = try context.fetchOrCreate(MealIngredientRecord.self, id: ingredient.id)
                ingredientRecord.name = ingredient.ingredient
                ingredientRecord.measurement = ingredient.measurement
                ingredientRecord.sortOrder = Int16(ingredient.sortOrder)
                ingredientRecord.meal = record
            }
        }
    }
    
    private func performSave(
        name: String,
        _ block: @escaping (NSManagedObjectContext) throws -> Void
    ) async throws {
        print("Will perform save: \(name))")
        let writeContext = self.backgroundContext
        try await writeContext.perform {
            do {
                try block(writeContext)
                
                if writeContext.hasChanges {
                    try writeContext.save()
                }
            } catch {
                writeContext.rollback()
                print("Failed to perform save, error: \(error)")
                throw error
            }
        }
        print("Did perform save: \(name)")
    }
}
