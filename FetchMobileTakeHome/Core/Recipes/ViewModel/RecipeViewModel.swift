//
//  ViewModel.swift
//  FetchMobileTakeHome
//
//  Created by Jack Robinson on 11/21/24.
//

import Foundation
import Combine

import Foundation

/// The `RecipeViewModel` class is responsible for managing the state and logic
/// of fetching, processing, and exposing a list of recipes to the view layer.
///
/// This class communicates with a service conforming to `RecipeServiceProtocol`
/// to fetch recipes from a remote API. It handles error scenarios such as
/// malformed data, empty data, and network issues, and provides appropriate
/// feedback to the UI.
final class RecipeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The list of recipes fetched from the API. This property is read-only
    /// for external observers and is updated when a successful fetch occurs.
    @Published private(set) var recipes: [Recipe] = []
    
    /// A boolean indicating whether a fetch operation is currently in progress.
    @Published private(set) var isLoading = false
    
    /// An optional error message to display to the user when a fetch operation fails.
    @Published private(set) var errorMessage: String?
    
    // MARK: - Private Properties

    
    /// The service responsible for fetching recipes.
    private let service: RecipeServiceProtocol
    
    // MARK: - Initializer
    
    /// Creates a new instance of `RecipeViewModel`.
    ///
    /// - Parameter service: A service conforming to `RecipeServiceProtocol`
    ///   that fetches recipes from a remote API. Defaults to the shared instance.
    init(service: RecipeServiceProtocol = RecipeService.shared) {
        self.service = service
    }
    
    
    // MARK: - Public Methods
    
    /// Fetches the list of recipes from the remote API and updates the published properties.
    ///
    /// This method handles various error scenarios:
    /// - Malformed data: Displays an error message and clears the recipes list.
    /// - Empty data: Clears the recipes list without displaying an error.
    /// - Other errors: Displays a user-friendly error message.
    ///
    /// - Throws: Propagates errors related to invalid data, empty recipes, or network issues.
    @MainActor
        func fetchRecipes() async throws {
            guard !isLoading else { return }
            
            isLoading = true
            errorMessage = nil

            defer {
                isLoading = false
            }

            do {
                let fetchedRecipes = try await service.fetchRecipes(
                    from: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
                )
                self.recipes = fetchedRecipes
            } catch RecipeError.invalidData {
                self.errorMessage = "The recipes data is malformed. Please try again later."
                self.recipes = []
                throw RecipeError.invalidData
            } catch RecipeError.emptyRecipes {
                // This is an expected state, not an error
                // Just clear the recipes and don't set an error message
                print("should be empty")
                self.recipes = []
                self.errorMessage = nil
                // Don't throw the error - empty state is valid
            } catch {
                // Handle other unexpected errors
                self.errorMessage = error.localizedDescription
                self.recipes = []
                throw error
            }
        }
    
    #if DEBUG
    // MARK: - Debugging Helpers
    
    /// Simulates a loading state for use in SwiftUI previews or unit tests.
    func simulateLoading() {
        isLoading = true
        recipes = []
        errorMessage = nil
    }
    
    /// Simulates an error state for use in SwiftUI previews or unit tests.
    func simulateError() {
        isLoading = false
        recipes = []
        errorMessage = "Failed to load recipes"
    }
    #endif
}
