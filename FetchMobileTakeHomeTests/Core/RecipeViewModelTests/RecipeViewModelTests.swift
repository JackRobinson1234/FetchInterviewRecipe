//
//  RecipeViewModel.swift
//  FetchMobileTakeHome
//
//  Created by Jack Robinson on 11/21/24.
//

import XCTest
@testable import FetchMobileTakeHome

/// Unit tests for `RecipeViewModel`, validating its behavior under various scenarios.
///
/// These tests ensure that the view model correctly handles:
/// - Initial state setup
/// - Successful data fetches
/// - Failure scenarios, including malformed data and empty datasets
/// - Proper updates to published properties (`recipes`, `isLoading`, `errorMessage`)
final class RecipeViewModelTests: XCTestCase {

    // MARK: - Tests

    /// Verifies the initial state of `RecipeViewModel`.
    ///
    /// The view model should have:
    /// - An empty `recipes` list
    /// - `isLoading` set to `false`
    /// - `errorMessage` set to `nil`
    func testInitialState() {
        let viewModel = RecipeViewModel(service: MockRecipeService())
        XCTAssertTrue(viewModel.recipes.isEmpty, "Expected recipes to be empty initially.")
        XCTAssertFalse(viewModel.isLoading, "Expected isLoading to be false initially.")
        XCTAssertNil(viewModel.errorMessage, "Expected errorMessage to be nil initially.")
    }

    /// Tests a successful fetch of recipes.
    ///
    /// Simulates a mock service returning one recipe and verifies:
    /// - The `recipes` list is updated with the fetched data.
    /// - `isLoading` is reset to `false`.
    /// - `errorMessage` remains `nil`.
    func testFetchRecipesSuccess() async throws {
        let mockService = MockRecipeService()
        mockService.mockRecipes = [
            Recipe(cuisine: "test",
                   name: "Pasta",
                   photoURLLarge: URL(string: "https://example.com/carbonara.jpg"),
                   photoURLSmall: nil,
                   id: UUID(),
                   sourceURL: URL(string: "https://example.com/carbonara"),
                   youtubeURL: URL(string: "https://youtube.com/watch?v=123"))
        ]
        let viewModel = RecipeViewModel(service: mockService)
        
        try await viewModel.fetchRecipes()
        
        XCTAssertFalse(viewModel.isLoading, "Expected isLoading to be false after successful fetch.")
        XCTAssertEqual(viewModel.recipes.count, 1, "Expected one recipe in the recipes list.")
        XCTAssertEqual(viewModel.recipes.first?.name, "Pasta", "Expected the recipe name to match.")
        XCTAssertNil(viewModel.errorMessage, "Expected errorMessage to remain nil after a successful fetch.")
    }

    /// Tests a failure during recipe fetching due to a service error.
    ///
    /// Simulates a mock service throwing an error and verifies:
    /// - `errorMessage` is set to the appropriate error message.
    /// - `recipes` remains empty.
    /// - `isLoading` is reset to `false`.
    func testFetchRecipesFailure() async {
        let mockService = MockRecipeService()
        mockService.mockError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Service error"])
        let viewModel = RecipeViewModel(service: mockService)
        
        do {
            try await viewModel.fetchRecipes()
            XCTFail("Expected fetchRecipes to throw an error.")
        } catch {
            XCTAssertEqual(viewModel.errorMessage, "Service error", "Expected errorMessage to match the service error.")
            XCTAssertTrue(viewModel.recipes.isEmpty, "Expected recipes to remain empty after a failure.")
            XCTAssertFalse(viewModel.isLoading, "Expected isLoading to be reset after a failure.")
        }
    }

    /// Tests the handling of malformed data during recipe fetching.
    ///
    /// Simulates a mock service throwing a `RecipeError.invalidData` and verifies:
    /// - `errorMessage` is set to a user-friendly message.
    /// - `recipes` remains empty.
    /// - `isLoading` is reset to `false`.
    func testMalformedData() async throws {
        let mockService = MockRecipeService()
        mockService.mockError = RecipeError.invalidData
        let viewModel = RecipeViewModel(service: mockService)
        
        do {
            try await viewModel.fetchRecipes()
            XCTFail("Expected fetchRecipes to throw a RecipeError.invalidData.")
        } catch RecipeError.invalidData {
            XCTAssertEqual(viewModel.errorMessage, "The recipes data is malformed. Please try again later.", "Expected errorMessage to match the user-friendly message for invalid data.")
            XCTAssertTrue(viewModel.recipes.isEmpty, "Expected recipes to remain empty after handling malformed data.")
            XCTAssertFalse(viewModel.isLoading, "Expected isLoading to be reset after handling malformed data.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    /// Tests the handling of empty recipe data.
    ///
    /// Simulates a mock service returning an empty recipe list and verifies:
    /// - `errorMessage` remains `nil`.
    /// - `recipes` remains empty.
    func testEmptyData() async throws {
        let mockService = MockRecipeService()
        mockService.mockRecipes = [] // Simulate empty data
        let viewModel = RecipeViewModel(service: mockService)
        
        try await viewModel.fetchRecipes()
        
        XCTAssertNil(viewModel.errorMessage, "Expected errorMessage to remain nil when data is empty.")
        XCTAssertTrue(viewModel.recipes.isEmpty, "Expected recipes to be empty when no data is returned.")
    }
}
