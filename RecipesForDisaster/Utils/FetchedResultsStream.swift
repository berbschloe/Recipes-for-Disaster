//
//  FetchedResultsStream.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/19/24.
//

import CoreData

// TODO: The async stream has re-enqueues the value on a differnt thread. A custom stream will have to be made.
func fetchedResultsAsyncStream<Entity: NSManagedObject>(
    fetchRequest: NSFetchRequest<Entity>,
    context: NSManagedObjectContext
) -> AsyncThrowingStream<[Entity], Error> {
    return AsyncThrowingStream() { continuation in
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        let delegate = FetchedResultsConrollerDelegate<Entity>()
        delegate.didChangeContent = {
            continuation.yield($0)
        }
        controller.delegate = delegate
        
        do {
            try controller.performFetch()
        } catch {
            continuation.finish(throwing: error)
        }
        
        continuation.yield(controller.fetchedObjects ?? [])
        
        continuation.onTermination = { _ in
            _ = delegate // hold a refernce to the delgate
            controller.delegate = nil
        }
    }
}

private class FetchedResultsConrollerDelegate<Entity: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    
    var didChangeContent: ([Entity]) -> Void = { _ in }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        let fetchedObjects = controller.fetchedObjects.flatMap { $0 as? [Entity] } ?? []
        didChangeContent(fetchedObjects)
    }
}
