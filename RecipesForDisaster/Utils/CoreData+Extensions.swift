//
//  CoreData+Extensions.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/15/24.
//

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

extension Identifiable where Self: NSManagedObject {
    static func fetchRequest(id: Self.ID) -> NSFetchRequest<Self> {
        let fetchRequest = self.fetchRequest() as! NSFetchRequest<Self>
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "id", id as! CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.fetchLimit = 1
        return fetchRequest
    }
}

extension NSManagedObjectContext {
    
    func create<T: NSManagedObject>(_ type: T.Type) -> T {
        return type.init(context: self)
    }
    
    func fetch<T: NSManagedObject>(_ type: T.Type, id: T.ID) throws -> T? where T: Identifiable {
        let fetchRequest = type.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "id", id as! CVarArg)
        fetchRequest.fetchLimit = 1
        
        return try fetch(fetchRequest).first
    }
    
    func fetchOrCreate<T: NSManagedObject, V>(
        _ type: T.Type,
        keyPath: KeyPath<T, V>,
        value: V
    ) throws -> T {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        return try fetchOrCreate(type, key: key, value: value)
    }
    
    func fetchOrCreate<T: NSManagedObject>(
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
    
    func fetchOrCreate<T: NSManagedObject>(_ type: T.Type, id: T.ID) throws -> T where T: Identifiable {
        return try fetchOrCreate(
            type,
            key: "id",
            value: id
        )
    }
    
    func delete(_ elements: NSSet?) {
        (elements as? Set<NSManagedObject>)?.forEach {
            self.delete($0)
        }
    }
}
