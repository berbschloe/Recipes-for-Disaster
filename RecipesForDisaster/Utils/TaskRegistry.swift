//
//  TaskRegistry.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/20/24.
//

import Foundation
import os

/// Stores a collection of tasks that are cancelled on de-init
final class TaskRegistry: Sendable {
    
    private struct State {
        var isCanceled: Bool = false
        var tasks: [Task<Void, Never>] = []
    }
    
    private let name: String
    
    private let lock = OSAllocatedUnfairLock(initialState: State())
    
    init(name: String = #file) {
        self.name = shortFileName(name)
    }
    
    func task(
        priority: TaskPriority = .userInitiated,
        _ action: @Sendable @escaping () async -> Void
    ) {
        lock.withLock {
            guard !$0.isCanceled else { return }
            $0.tasks.append(
                Task(priority: priority) {
                    await action()
                }
            )
        }
    }
    
    func subscribe<S: AsyncSequence>(
        priority: TaskPriority = .userInitiated,
        onStream: @Sendable @escaping () async -> S,
        onNext: @Sendable @escaping (S.Element) async -> Void,
        onFailure: (@Sendable (Error) async -> Void)? = nil
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
            $0.isCanceled = true
            $0.tasks.forEach { $0.cancel() }
            $0.tasks.removeAll()
        }
    }
    
    deinit {
        cancel()
    }
}
