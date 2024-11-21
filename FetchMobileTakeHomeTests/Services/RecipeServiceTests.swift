//
//  RecipeServiceTests.swift
//  FetchMobileTakeHomeTests
//
//  Created by Jack Robinson on 11/21/24.
//

import Foundation
import XCTest
@testable import FetchMobileTakeHome

/// Unit tests for the `RecipeService` class.
final class RecipeServiceTests: XCTestCase {
    /// Tests the `fetchRecipes` method for successful decoding of a mock JSON array response.
    func testFetchRecipesSuccess() async throws {
        // Mock JSON array response
        let mockJSON = """
        {
            "recipes": [
                {
                    "cuisine": "Italian",
                    "name": "Spaghetti Carbonara",
                    "photo_url_large": "https://example.com/full_size_photo.jpg",
                    "photo_url_small": "https://example.com/small_photo.jpg",
                    "uuid": "d1a76a5f-62c2-4c08-bef5-bb839e9f95c4",
                    "source_url": "https://example.com/recipe",
                    "youtube_url": "https://youtube.com/watch?v=dQw4w9WgXcQ"
                },
                {
                    "cuisine": "Mexican",
                    "name": "Tacos al Pastor",
                    "photo_url_large": "https://example.com/full_size_photo2.jpg",
                    "photo_url_small": "https://example.com/small_photo2.jpg",
                    "uuid": "e2b16b5f-8f2c-4c19-8ff5-cc839f9f95d2",
                    "source_url": "https://example.com/recipe2",
                    "youtube_url": null
                }
            ]
        }
        """
        let mockData = mockJSON.data(using: .utf8)!

        // Mock session configuration
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: config)

        // Set up MockURLProtocol response
        MockURLProtocol.mockResponse = (
            data: mockData,
            response: HTTPURLResponse(
                url: URL(string: "https://example.com/recipes")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ),
            error: nil
        )

        // Inject mock session into RecipeService
        let recipeService = RecipeService.shared
        recipeService.session = mockSession

        // Fetch the recipes
        let recipes = try await recipeService.fetchRecipes(from: "https://example.com/recipes")

        // Verify the results
        XCTAssertEqual(recipes.count, 2)
        XCTAssertEqual(recipes[0].name, "Spaghetti Carbonara")
        XCTAssertEqual(recipes[0].cuisine, "Italian")
        XCTAssertEqual(recipes[0].photoURLLarge, URL(string: "https://example.com/full_size_photo.jpg"))
        XCTAssertEqual(recipes[0].photoURLSmall, URL(string: "https://example.com/small_photo.jpg"))
        XCTAssertEqual(recipes[0].sourceURL, URL(string: "https://example.com/recipe"))
        XCTAssertEqual(recipes[0].youtubeURL, URL(string: "https://youtube.com/watch?v=dQw4w9WgXcQ"))

        XCTAssertEqual(recipes[1].name, "Tacos al Pastor")
        XCTAssertEqual(recipes[1].cuisine, "Mexican")
        XCTAssertEqual(recipes[1].photoURLLarge, URL(string: "https://example.com/full_size_photo2.jpg"))
        XCTAssertEqual(recipes[1].photoURLSmall, URL(string: "https://example.com/small_photo2.jpg"))
        XCTAssertEqual(recipes[1].sourceURL, URL(string: "https://example.com/recipe2"))
        XCTAssertNil(recipes[1].youtubeURL)
    }
}
