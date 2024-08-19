//
//  Combine+Extensions.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/16/24.
//

import Foundation
import Combine

extension Publisher {
    /// Specifies the scheduler on which to receive post first elements from the publisher.
    func receivePostFirst<S: Scheduler>(on scheduler: S, options: S.SchedulerOptions? = nil) -> AnyPublisher<Output, Never> where Failure == Never {
        scan((0, nil)) { state, value -> (UInt, Output) in
            (state.0 + 1, value)
        }
        .flatMap { count, value -> AnyPublisher<Output, Never> in
            return if count == 1 {
                Just(value!)
                    .eraseToAnyPublisher()
            } else {
                Just(value!)
                    .receive(on: scheduler, options: options)
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Failure == Never {
    func asyncStream() -> AsyncStream<Output> {
        AsyncStream { continuation in
            let cancellable = self.sink { _ in
                continuation.finish()
            } receiveValue: {
                continuation.yield($0)
            }

            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}
