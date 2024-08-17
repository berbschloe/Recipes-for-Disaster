//
//  RecordStore.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/16/24.
//

import Foundation
import CoreData
import Combine

final class RecordStore {
    
    private let container: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    private var viewContext: NSManagedObjectContext { container.viewContext }
    
    func categoriesPublisher() -> AnyPublisher<[MealCategoryRecord], Never> {
        let fetchRequest = MealCategoryRecord.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(
            keyPath: \MealCategoryRecord.name,
            ascending: true)
        ]
        
        return publisher(fetchRequest: fetchRequest)
    }
    
    private func publisher<T: NSManagedObject>(fetchRequest: NSFetchRequest<T>) -> AnyPublisher<[T], Never> {
        return Publishers.Merge(
            Just((try? viewContext.fetch(fetchRequest)) ?? []),
            FetchedResultsPublisher(
                fetchRequest: fetchRequest,
                context: backgroundContext
            )
        )
        .share()
        .eraseToAnyPublisher()
    }
    
    init(inMemory: Bool = true) {
        _ = NSExpression(forKeyPath: \MealRecord.name).keyPath
        container = NSPersistentContainer(name: "RecipesForDisaster")
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
        backgroundContext = container.newBackgroundContext()
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
