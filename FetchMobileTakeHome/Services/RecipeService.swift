//
//  RecipeService.swift
//  FetchMobileTakeHome
//
//  Created by Jack Robinson on 11/21/24.
//

import Foundation
import Kingfisher

/// A singleton service responsible for fetching recipes from a remote API
/// and managing image caching for efficient performance.
final class RecipeService: RecipeServiceProtocol {
    
    // MARK: - Singleton Instance
    
    /// The shared singleton instance of `RecipeService`.
    static let shared = RecipeService()
    
    /// Private initializer to enforce singleton pattern.
    private init() {
        setupImageCache()
    }
    
    // MARK: - Properties
    
    /// The `URLSession` used for network requests.
    /// Configured with no caching to ensure fresh data is always fetched.
    var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        return URLSession(configuration: config)
    }()
    
    // MARK: - Public Methods
    
    /// Fetches recipes from the provided URL and validates their content.
    ///
    /// - Parameter urlString: The URL string from which to fetch the recipes.
    /// - Returns: An array of valid `Recipe` objects.
    /// - Throws:
    ///   - `RecipeError.invalidData`: If the URL is invalid or the data cannot be decoded.
    ///   - `RecipeError.emptyRecipes`: If the response contains an empty list of recipes.
    ///   - `RecipeError.networkError`: For network-related issues.
    func fetchRecipes(from urlString: String) async throws -> [Recipe] {
            guard let url = URL(string: urlString) else {
                throw RecipeError.invalidData
            }
            
            do {
                // Perform the network request
                let (data, response) = try await session.data(from: url)
                
                // Validate HTTP response
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw RecipeError.networkError(URLError(.badServerResponse))
                }
                
                do {
                    // Decode JSON response in a separate do-catch block
                    let decoder = JSONDecoder()
                    let results = try decoder.decode(RecipeResponse.self, from: data)
                    
                    // Handle empty recipes list
                    if results.recipes.isEmpty {
                        print("Service is empty")
                        throw RecipeError.emptyRecipes
                    }
                    
                    // Validate the content of each recipe
                    return try validateRecipes(results.recipes)
                } catch DecodingError.dataCorrupted(_),
                       DecodingError.keyNotFound(_, _),
                       DecodingError.typeMismatch(_, _),
                       DecodingError.valueNotFound(_, _) {
                    throw RecipeError.invalidData
                }
            } catch RecipeError.emptyRecipes {
                // Specifically re-throw empty recipes error
                throw RecipeError.emptyRecipes
            } catch let error as RecipeError {
                // Re-throw any other RecipeError types
                throw error
            } catch {
                // Handle all other errors as network errors
                throw RecipeError.networkError(error)
            }
        }
    
    // MARK: - Private Methods
    
    /// Configures image caching using the Kingfisher library.
    ///
    /// - Sets memory and disk size limits for the cache.
    /// - Sets expiration policies for cached images.
    private func setupImageCache() {
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        cache.diskStorage.config.sizeLimit = 1024 * 1024 * 500 // 500 MB
        cache.diskStorage.config.expiration = .days(7)
        
        KingfisherManager.shared.downloader.downloadTimeout = 15.0
    }
    
    /// Validates the content of recipes to ensure no critical data is missing.
    ///
    /// - Parameter recipes: An array of recipes to validate.
    /// - Returns: The original array if all recipes are valid.
    /// - Throws: `RecipeError.invalidData` if any recipe contains empty required fields.
    private func validateRecipes(_ recipes: [Recipe]) throws -> [Recipe] {
        for recipe in recipes {
            guard !recipe.cuisine.isEmpty, !recipe.name.isEmpty else {
                throw RecipeError.invalidData
            }
        }
        return recipes
    }
}

// MARK: - RecipeError

/// Errors that can occur during recipe fetching or validation.
enum RecipeError: Error {
    /// The data provided is invalid or cannot be decoded.
    case invalidData
    
    /// The fetched recipes list is empty.
    case emptyRecipes
    
    /// A network-related error occurred.
    case networkError(Error)
}

// MARK: - RecipeResponse

/// The top-level response model for fetching recipes.
struct RecipeResponse: Codable {
    /// An array of recipes fetched from the API.
    let recipes: [Recipe]
}
