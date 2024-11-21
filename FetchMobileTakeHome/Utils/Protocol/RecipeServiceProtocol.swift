//
//  RecipeServiceProtocol.swift
//  FetchMobileTakeHome
//
//  Created by Jack Robinson on 11/21/24.
//


protocol RecipeServiceProtocol {
    func fetchRecipes(from urlString: String) async throws -> [Recipe]
}