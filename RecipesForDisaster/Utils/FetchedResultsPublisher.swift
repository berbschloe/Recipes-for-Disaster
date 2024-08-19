//
//  FetchedResultsPublisher.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/16/24.
//
// Inspired by: https://github.com/franzlj/CoreDataPublisher/blob/master/Sources/CoreDataPublisher/FetchedResultsPublisher.swift

import Foundation
import Combine
import CoreData

extension NSManagedObjectContext {
    func fetchedResultsPublisher<T: NSManagedObject>(
        _ fetchRequest: NSFetchRequest<T>,
        preFetch: Bool = false
    ) -> FetchedResultsPublisher<T> {
        FetchedResultsPublisher(
            fetchRequest: fetchRequest,
            context: self,
            preFetch: preFetch
        )
    }
}

public struct FetchedResultsPublisher<Entity: NSManagedObject>: Publisher {
    public typealias Output = [Entity]
    public typealias Failure = Error

    private let fetchRequest: NSFetchRequest<Entity>
    private let context: NSManagedObjectContext
    private let preFetch: Bool

    public init(
        fetchRequest: NSFetchRequest<Entity>,
        context: NSManagedObjectContext,
        preFetch: Bool
    ) {
        self.fetchRequest = fetchRequest
        self.context = context
        self.preFetch = preFetch
    }

    public func receive<S>(
        subscriber: S
    ) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = FetchedResultsSubscription(
            subscriber: subscriber,
            fetchRequest: fetchRequest,
            context: context,
            preFetch: preFetch
        )
        subscriber.receive(subscription: subscription)
    }
}

private final class FetchedResultsSubscription<SubscriberType: Subscriber, Entity: NSManagedObject>:
    NSObject, Subscription, NSFetchedResultsControllerDelegate where SubscriberType.Input == [Entity], SubscriberType.Failure == Error {

    private let subject = CurrentValueSubject<[Entity]?, Error>(nil)
    private let fetchRequest: NSFetchRequest<Entity>
    private let preFetch: Bool
    
    private var cancellable: AnyCancellable?
    private var subscriber: SubscriberType?
    private var context: NSManagedObjectContext?
    private var fetchedResultsController: NSFetchedResultsController<Entity>?
    
    init(
        subscriber: SubscriberType,
        fetchRequest: NSFetchRequest<Entity>,
        context: NSManagedObjectContext,
        preFetch: Bool
    ) {
        
        self.subscriber = subscriber
        self.fetchRequest = fetchRequest
        self.context = context
        self.preFetch = preFetch

        super.init()
        
        createFetchedResultsController(context: context)
        
        cancellable = subject.sink { [weak self] completion in
            guard let self = self, let subscriber = self.subscriber else {
                return
            }
            
            subscriber.receive(completion: completion)
        } receiveValue: { [weak self] value in
            guard let self = self, let subscriber = self.subscriber else {
                return
            }
            
            // Only notify if value has been set.
            if let value {
                _ = subscriber.receive(value)
            }
        }
    }
    
    private func createFetchedResultsController(context: NSManagedObjectContext) {
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        fetchedResultsController.delegate = self
        self.fetchedResultsController = fetchedResultsController

        let fetchBlock = { [weak self] in
            guard let self = self else { return }
            
            do {
                try fetchedResultsController.performFetch()
            } catch {
                self.subject.send(completion: .failure(error))
            }
            
            if self.preFetch {
                let objects = fetchedResultsController.fetchedObjects
                self.subject.send(objects ?? [])
            }
        }
        
        if context.concurrencyType == .mainQueueConcurrencyType && Thread.isMainThread {
            fetchBlock()
        } else {
            context.perform(fetchBlock)
        }
    }
    

    func request(_ demand: Subscribers.Demand) {
        // When a demand is sent this means we should re-send the latest buffer, since
        // subscribing can happen later after the initialization.
        subject.send(subject.value)
    }

    func cancel() {
        cancellable?.cancel()
        cancellable = nil
        fetchedResultsController = nil
        context = nil
        subscriber = nil
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let objects = controller.fetchedObjects as? [Entity] else { return }
        subject.send(objects)
    }
}
