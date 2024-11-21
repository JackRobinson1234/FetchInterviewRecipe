//
//  RecipeCell.swift
//  FetchMobileTakeHome
//
//  Created by Jack Robinson on 11/21/24.
//

import SwiftUI
import Kingfisher

/// A reusable SwiftUI component that displays a recipe as a card with an image, title, and optional action buttons.
///
/// This view is intended to be used in a grid or list of recipes. It dynamically handles content overlay, gradients,
/// and optional action buttons for interacting with external resources like YouTube or a recipe website.
///
/// - Parameters:
///   - recipe: The `Recipe` object containing the information to display.
/// - Features:
///   - Displays the recipe's image with a gradient overlay.
///   - Shows the recipe name and cuisine.
///   - Optionally includes action buttons for YouTube videos and external recipe links.
struct RecipeCell: View {
    let recipe: Recipe

    /// A gradient overlay for the image, adding a fade effect from black to clear.
    private var imageGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [.black.opacity(0.6), .clear]),
            startPoint: .bottom,
            endPoint: .center
        )
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            recipeImage
            contentOverlay
        }
        .frame(height: 200)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Private Subviews

    /// Displays the recipe's image with a gradient overlay.
    private var recipeImage: some View {
        KFImage(recipe.photoURLLarge ?? recipe.photoURLSmall)
            .placeholder { Color.gray.opacity(0.3) }
            .resizable()
            .scaledToFit()
            .overlay(imageGradient)
            .cornerRadius(6)
    }

    /// The overlay content for the recipe card, containing the title, cuisine, and action buttons.
    private var contentOverlay: some View {
        VStack(alignment: .leading, spacing: 4) {
            recipeInfo
            actionButtons
        }
        .padding(4)
    }

    /// Displays the recipe's name and cuisine information.
    private var recipeInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recipe.name)
                .font(.headline)
                .lineLimit(2)
                .foregroundStyle(.white)
                .shadow(radius: 2, y: 1)

            Text(recipe.cuisine)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
                .shadow(radius: 2, y: 1)
        }
    }
    
    /// Action buttons for interacting with the recipe, such as opening a YouTube video or external recipe link.
    private var actionButtons: some View {
        HStack(spacing: 10) {
            if recipe.youtubeURL != nil {
                
                Image(systemName: "play.circle.fill")
                    .foregroundStyle(.white)
            }
            
            if recipe.sourceURL != nil {
                Image(systemName: "globe")
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    RecipeCell(recipe: DeveloperPreview.recipe)
}
