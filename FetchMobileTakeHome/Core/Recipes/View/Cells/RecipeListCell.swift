//
//  RecipeListCell.swift
//  FetchMobileTakeHome
//
//  Created by Jack Robinson on 11/21/24.
//

import SwiftUI
import Kingfisher

struct RecipeListCell: View {
    let recipe: Recipe

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Image
            KFImage(recipe.photoURLSmall ?? recipe.photoURLLarge)
                .placeholder {
                    Color.gray.opacity(0.3)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // Text Information
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                Text(recipe.cuisine)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Buttons
                HStack(spacing: 10) {
                    if recipe.youtubeURL != nil {
                        Button(action: {
                            // Handle Play button action
                        }) {
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }

                    if recipe.sourceURL != nil {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    RecipeListCell(recipe: DeveloperPreview.recipe)
}
