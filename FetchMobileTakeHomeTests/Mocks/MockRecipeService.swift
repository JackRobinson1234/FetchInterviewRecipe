//
//  MockRecipeService.swift
//  FetchMobileTakeHome
//
//  Created by Jack Robinson on 11/21/24.
//

@testable import FetchMobileTakeHome
import SwiftUI
final class MockRecipeService: RecipeServiceProtocol {
    var mockRecipes: [Recipe] = []
    var mockError: Error?

    func fetchRecipes(from url: String) async throws -> [Recipe] {
        if let error = mockError {
            throw error
        }
        return mockRecipes
    }
}
