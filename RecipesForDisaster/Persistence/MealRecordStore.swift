//
//  MealRecordStore.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/16/24.
//

import CoreData
import Combine

protocol MealRecordStoreProtocol {
    
    @MainActor
    func mealPublisher(id: MealID) -> AnyPublisher<MealRecord?, Never>
    
    @MainActor
    func mealsPublisher(categoryID: MealCategoryID) -> AnyPublisher<[MealRecord], Never>
    
    @MainActor
    func categoryPublisher(id: MealCategoryID) -> AnyPublisher<MealCategoryRecord?, Never>
    
    @MainActor
    func categoriesPublisher() -> AnyPublisher<[MealCategoryRecord], Never>

    func saveCategories(categories: [MealCategory]) async throws
    func saveMeals(meals: [MealLight], categoryName: MealCategoryName) async throws
    func saveMeal(meal: MealLookup) async throws
}

final class MealRecordStore: MealRecordStoreProtocol {
    
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
    
    @MainActor
    func categoryPublisher(id: MealCategoryID) -> AnyPublisher<MealCategoryRecord?, Never> {
        publisher(MealCategoryRecord.self, id: id)
    }
    
    @MainActor
    func categoriesPublisher() -> AnyPublisher<[MealCategoryRecord], Never> {
        let fetchRequest = MealCategoryRecord.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(
            keyPath: \MealCategoryRecord.name,
            ascending: true)
        ]
        
        return publisher(fetchRequest: fetchRequest)
    }
    
    @MainActor
    func mealPublisher(id: MealID) -> AnyPublisher<MealRecord?, Never> {
        publisher(MealRecord.self, id: id)
    }
    
    @MainActor
    func mealsPublisher(categoryID: MealCategoryID) -> AnyPublisher<[MealRecord], Never> {
        let fetchRequest = MealRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "%K == %@", "category.id", categoryID as CVarArg
        )
        fetchRequest.sortDescriptors = [NSSortDescriptor(
            keyPath: \MealCategoryRecord.name,
            ascending: true)
        ]
        return publisher(fetchRequest: fetchRequest)
    }
    
    @MainActor
    private func publisher<T: NSManagedObject>(_ type: T.Type, id: T.ID) -> AnyPublisher<T?, Never> where T: Identifiable {
        let fetchRequest = type.fetchRequest(id: id)
        return publisher(fetchRequest: fetchRequest).map { $0.first }
            .eraseToAnyPublisher()
    }
    
    @MainActor
    private func publisher<T: NSManagedObject>(fetchRequest: NSFetchRequest<T>) -> AnyPublisher<[T], Never> {
        Publishers.Merge(
            Deferred {
                Just(try? self.viewContext.fetch(fetchRequest))
                    .replaceNil(with: [])
            },
            backgroundContext.fetchedResultsPublisher(fetchRequest)
                .replaceError(with: [])
        )
        .eraseToAnyPublisher()
    }
    
    func saveCategories(categories: [MealCategory]) async throws {
        try await performSave { context in
            for category in categories {
                let record = try context.findOrCreate(MealCategoryRecord.self, id: category.id)
                
                record.name = category.name
                record.thumbnail = category.thumbnail
                record.body = category.body
            }
        }
    }
    
    func saveMeals(meals: [MealLight], categoryName: MealCategoryName) async throws {
        try await performSave { context in
            let categoryRecord = try context.findOrCreate(
                MealCategoryRecord.self,
                keyPath: \.name,
                value: categoryName
            )
            
            for meal in meals {
                let record = try context.findOrCreate(MealRecord.self, id: meal.id)
                record.name = meal.name
                record.thumbnail = meal.thumbnail
                record.category = categoryRecord
            }
        }
    }
    
    func saveMeal(meal: MealLookup) async throws {
        try await performSave { context in
            let record = try context.findOrCreate(MealRecord.self, id: meal.id)
            
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
                let ingredientRecord = try context.findOrCreate(MealIngredientRecord.self, id: ingredient.id)
                ingredientRecord.name = ingredient.ingredient
                ingredientRecord.measurement = ingredient.measurement
                ingredientRecord.sortOrder = Int16(ingredient.sortOrder)
                ingredientRecord.meal = record
            }
        }
    }
    
    private func performSave(
        _ block: @escaping (NSManagedObjectContext) throws -> Void
    ) async throws {
        let writeContext = self.backgroundContext
        try await writeContext.perform {
            do {
                try block(writeContext)
                
                if writeContext.hasChanges {
                    try writeContext.save()
                }
            } catch {
                writeContext.rollback()
                print("Unable to save changes, error: \(error)")
                throw error
            }
        }
    }
}
