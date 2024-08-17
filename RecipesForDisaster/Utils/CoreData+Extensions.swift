//
//  CoreData+Extensions.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/15/24.
//

import Foundation

import CoreData

extension NSPersistentContainer {
    // This assumes that you have only one store to setup.
    func loadPersistentStores() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            loadPersistentStores { (_, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

extension NSManagedObjectContext {
    
    func create<T: NSManagedObject>(_ type: T.Type) -> T {
        return type.init(context: self)
    }
    
    func findOrCreate<T: NSManagedObject, V>(
        _ type: T.Type,
        keyPath: KeyPath<T, V>,
        value: V
    ) throws -> T {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        return try findOrCreate(type, key: key, value: value)
    }
    
    func findOrCreate<T: NSManagedObject>(
        _ type: T.Type,
        key: String,
        value: Any?
    ) throws -> T {
        let fetchRequest = type.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.predicate = NSPredicate(format: "%K == %@", key, value as! CVarArg)
        fetchRequest.fetchLimit = 1
        
        let record = try fetch(fetchRequest).first ?? {
            let newRecord = create(type)
            newRecord.setValue(value, forKey: key)
            return newRecord
        }()
        return record
    }
    
    func findOrCreate<T: NSManagedObject>(_ type: T.Type, id: T.ID) throws -> T where T: Identifiable {
        return try findOrCreate(
            type,
            key: "id",
            value: id
        )
    }
}
