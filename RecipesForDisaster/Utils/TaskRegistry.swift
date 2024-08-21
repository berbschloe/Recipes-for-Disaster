//
//  TaskRegistry.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/20/24.
//

import Foundation

/// Stores a collection of tasks that are cancelled on deinit
final class TaskRegistry: @unchecked Sendable {
    
    private let name: String
    private var isCanceled: Bool = false
    private var tasks: [Task<Void, Never>] = []
    private let lock = NSLock()
    
    init(name: String = #file) {
        self.name = shortFileName(name)
    }
    
    func task(
        priority: TaskPriority = .userInitiated,
        _ action: @escaping () async -> Void
    ) {
        lock.withLock {
            guard !isCanceled else { return }
            tasks.append(
                Task.detached(priority: priority) {
                    await action()
                }
            )
        }
    }
    
    func subscribe<S: AsyncSequence>(
        priority: TaskPriority = .userInitiated,
        onStream: @escaping () async -> S,
        onNext: @escaping (S.Element) async -> Void,
        onFailure: ((Error) async -> Void)? = nil
    )  {
        task(priority: priority) {
            do {
                let stream = await onStream()
                for try await value in stream {
                    await onNext(value)
                }
            } catch {
                if let onFailure {
                    await onFailure(error)
                } else {
                    print("Stream failed, error: \(error)")
                }
            }
        }
    }
    
    func cancel() {
        print("Canceling TaskRegistry(name: \(name))")
        lock.withLock {
            isCanceled = true
            tasks.forEach { $0.cancel() }
            tasks.removeAll()
        }
    }
    
    deinit {
        cancel()
    }
}
