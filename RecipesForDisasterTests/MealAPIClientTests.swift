//
//  MealAPIClientTests.swift
//  RecipesForDisasterTests
//
//  Created by Brandon Erbschloe on 8/15/24.
//

import Foundation

import XCTest
@testable import RecipesForDisaster

final class MealAPIClientTests: XCTestCase {
    
    var client: MealAPIClient!
    var session: MockURLSession!
    
    override func setUp() {
        session = MockURLSession()
        client = MealAPIClient(
            host: URL(string: "https://test.com")!,
            apiKey: "API_KEY",
            session: session
        )
    }
    
    func testCategories() async throws {
        session.onData = { request in
            XCTAssertEqual(
                request.url,
                URL(string: "https://test.com/API_KEY/categories.php")
            )
            
            return MockHTTPResponses.success(
                request: request,
                file: "MealCategories"
            )
        }
        
        let categories = try await client.categories()
        
        XCTAssertEqual(categories.count, 14)
    }
    
    func testMealFilter() async throws {
        let category: MealCategoryName = "Deserts"
        
        session.onData = { request in
            XCTAssertEqual(
                request.url,
                URL(string: "https://test.com/API_KEY/filter.php?c=\(category)")
            )
            
            return MockHTTPResponses.success(
                request: request,
                file: "MealFilterDeserts"
            )
        }
        
        let meals = try await client.meals(category: category)
        
        XCTAssertEqual(meals.count, 65)
    }
    
    func testMealLookup() async throws {
        let id: MealID = "53015"
        
        session.onData = { request in
            XCTAssertEqual(
                request.url,
                URL(string: "https://test.com/API_KEY/lookup.php?i=\(id)")
            )
            
            return MockHTTPResponses.success(
                request: request,
                file: "MealLookup"
            )
        }
        
        let meal = try await client.mealLookup(id: id)
        
        XCTAssertEqual(meal.id, id)
    }
}

