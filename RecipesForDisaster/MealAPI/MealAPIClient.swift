//
//  MealAPIClient.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/14/24.
//

import Foundation

protocol MealAPIClientProtocol: Sendable {
    func categories() async throws -> [MealCategory]
    func meals(category: MealCategoryName) async throws -> [MealLight]
    func mealLookup(id: MealID) async throws -> MealLookup
}

final class MealAPIClient: MealAPIClientProtocol {
    
    private let apiKey: String
    private let hostURL: URL
    private let session: URLSessionProtocol
    
    private let decoder = JSONDecoder()
    
    init(
        host: URL = URL(string: "https://themealdb.com/api/json/v1")!,
        apiKey: String = "1",
        session: URLSessionProtocol = URLSession.shared
    ) {
        self.apiKey = apiKey
        self.session = session
        hostURL = host.appendingPathComponent(apiKey)
    }
    
    func categories() async throws -> [MealCategory] {
        let response: MealCategoriesResponse<MealCategory> = try await request(
            endpoint: "categories"
        )
        
        return response.categories
    }
    
    func meals(category: MealCategoryName) async throws -> [MealLight] {
        let response: MealsResponse<MealLight> = try await request(
            endpoint: "filter",
            parameters: ["c": category]
        )
        
        guard let meals = response.meals, !meals.isEmpty else {
            throw MealAPIError.contentMissing
        }
        
        return meals
    }
    
    func mealLookup(id: MealID) async throws -> MealLookup {
        let response: MealsResponse<MealLookup> = try await request(
            endpoint: "lookup",
            parameters: ["i": id]
        )
        
        guard let meal = response.meals?.first else {
            throw MealAPIError.contentMissing
        }
        
        return meal
    }
    
    private func request<Response: Decodable>(
        endpoint: String,
        parameters: [String: String] = [:]
    ) async throws -> Response {
        let url = hostURL
            .appendingPathComponent("\(endpoint).php")
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        if !parameters.isEmpty {
            urlComponents.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }.sorted(by: \.name)
        }
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        
        let content: Response
        do {
            
            let result: (data: Data, response: URLResponse)
            do {
                result = try await session.data(for: request)
            } catch let error as URLError {
                throw MealAPIError.urlError(error: error)
            } catch {
                throw MealAPIError.urlError(
                    error: URLError(.unknown, userInfo: [NSUnderlyingErrorKey: error])
                )
            }
            
            guard let httpResponse = result.response as? HTTPURLResponse else {
                throw MealAPIError.urlError(error: URLError(.unsupportedURL, userInfo: [NSDebugDescriptionErrorKey: "Incorrect response type"]))
            }
            
            guard httpResponse.statusCode == 200 else {
                throw MealAPIError.httpError(status: httpResponse.statusCode)
            }
            
            let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") ?? ""
            guard contentType.contains("application/json") else {
                throw MealAPIError.decoding(error: nil)
            }
            
            do {
                content = try decoder.decode(Response.self, from: result.data)
            } catch {
                throw MealAPIError.decoding(error: error)
            }
        }
        
        return content
    }
}
