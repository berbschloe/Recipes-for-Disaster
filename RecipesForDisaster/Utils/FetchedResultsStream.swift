//
//  FetchedResultsStream.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/19/24.
//

import CoreData


typealias FetchedResultsStream<T: Sendable> = AsyncFilterSequence<AsyncThrowingStream<T, Error>>

extension NSManagedObjectContext {
    func fetchStream<Entity: NSManagedObject, T: Sendable & Equatable>(
        fetchRequest: NSFetchRequest<Entity>,
        initialValue: T? = nil,
        transform: @Sendable @escaping ([Entity]) -> T
    ) -> FetchedResultsStream<T> {
        fetchedResultsAsyncStream(
            fetchRequest: fetchRequest,
            context: self,
            initialValue: initialValue,
            transform: transform
        )
    }
}

private func fetchedResultsAsyncStream<Entity: NSManagedObject, T: Sendable & Equatable>(
    fetchRequest: NSFetchRequest<Entity>,
    context: NSManagedObjectContext,
    initialValue: T?,
    transform: @Sendable @escaping ([Entity]) -> T
) -> FetchedResultsStream<T> {
    AsyncThrowingStream(
        bufferingPolicy: .bufferingNewest(1)
    ) { continuation in
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        let delegate = FetchedResultsConrollerDelegate<Entity>()
        delegate.didChangeContent = {
            continuation.yield(transform($0))
        }
        controller.delegate = delegate
        
        continuation.onTermination = { _ in
            controller.delegate = nil
            _ = delegate // hold a refernce to the delgate to keep it from deiniting
        }
        
        context.perform {
            do {
                try controller.performFetch()
            } catch {
                continuation.finish(throwing: error)
            }
            
            continuation.yield(
                transform(controller.fetchedObjects ?? [])
            )
        }
    }
    .removeDuplicates(initialValue: initialValue)
}

private class FetchedResultsConrollerDelegate<Entity: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    
    var didChangeContent: ([Entity]) -> Void = { _ in }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        let fetchedObjects = controller.fetchedObjects.flatMap { $0 as? [Entity] } ?? []
        didChangeContent(fetchedObjects)
    }
}
