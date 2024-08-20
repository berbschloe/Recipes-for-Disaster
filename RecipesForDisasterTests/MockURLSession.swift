//
//  MockURLSession.swift
//  RecipesForDisasterTests
//
//  Created by Brandon Erbschloe on 8/15/24.
//

import Foundation
@testable import RecipesForDisaster

// TODO: Use proper mocking library
final class MockURLSession: URLSessionProtocol, @unchecked Sendable {
    
    var onData: (URLRequest) async throws -> (Data, URLResponse) = { _ in fatalError() }
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await onData(request)
    }
}

class MockHTTPResponses {
    private init() {}
    
    static func success(request: URLRequest, file: String) -> (Data, HTTPURLResponse) {
        let url = Bundle(for: MockHTTPResponses.self).url(forResource: file, withExtension: "json")!
        
        let data = try! Data(contentsOf: url)
        
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        
        return (data, response)
    }
}
