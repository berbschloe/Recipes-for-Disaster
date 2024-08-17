//
//  FetchedResultsPublisher.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/16/24.
//

import Foundation
import Combine
import CoreData

public struct FetchedResultsPublisher<Entity: NSManagedObject>: Publisher {
    public typealias Output = [Entity]
    public typealias Failure = Never

    private let fetchRequest: NSFetchRequest<Entity>
    private let context: NSManagedObjectContext
    private let preFetch: Bool

    public init(
        fetchRequest: NSFetchRequest<Entity>,
        context: NSManagedObjectContext,
        preFetch: Bool = true
    ) {
        self.fetchRequest = fetchRequest
        self.context = context
        self.preFetch = preFetch
    }

    public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = FetchedResultsSubscription(
            subscriber: subscriber,
            fetchRequest: fetchRequest,
            context: context,
            preFetch: preFetch
        )
        subscriber.receive(subscription: subscription)
    }
}

final class FetchedResultsSubscription<SubscriberType: Subscriber, Entity: NSManagedObject>:
    NSObject, Subscription, NSFetchedResultsControllerDelegate where SubscriberType.Input == [Entity] {

    private let subject = PassthroughSubject<[Entity], Never>()
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

        cancellable = subject.sink { [weak self] in
            guard let self = self, let subscriber = self.subscriber else {
                return
            }
            
            _ = subscriber.receive($0)
        }
        
        createFetchedResultsController(context: context)
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

        let fetchBlock = {
            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Fetch failed, error: \(error)")
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
    

    func request(_ demand: Subscribers.Demand) { }

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
