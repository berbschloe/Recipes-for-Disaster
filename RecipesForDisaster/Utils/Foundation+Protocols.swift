//
//  Foundation+Protocols.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/15/24.
//

import Foundation

protocol URLSessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
