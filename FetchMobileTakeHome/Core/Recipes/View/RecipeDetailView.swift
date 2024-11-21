//
//  RecipeDetailView.swift
//  FetchMobileTakeHome
//
//  Created by Jack Robinson on 11/21/24.
//

import SwiftUI
import SafariServices

/// A detailed view displaying the content of a selected recipe.
///
/// This view shows a video player if a YouTube URL is available, a button to open the recipe's source
/// website, and a dismiss button in the navigation bar. It uses a sheet to present the recipe's source
/// website when the button is tapped.
///
/// - Parameters:
///   - recipe: The `Recipe` object to display.
/// - Features:
///   - Video playback for YouTube recipes.
///   - A button to view the recipe's website in Safari.
///   - Navigation bar customization with a dismiss button.
struct RecipeDetailView: View {
    
    // MARK: - Properties
    
    /// The recipe to display details for.
    let recipe: Recipe
    
    /// Environment value to dismiss the current view.
    @Environment(\.dismiss) var dismiss
    
    /// State variable to control the presentation of the Safari sheet.
    @State private var showingSafari = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Display YouTube video if available
                if let youtubeURL = recipe.youtubeURL {
                    VideoPlayerView(
                        url: youtubeURL,
                        autoPlay: false,
                        isSafariPresented: $showingSafari
                    )
                    .frame(height: 250)
                }
                
                // Button to open the recipe's website
                if recipe.sourceURL != nil {
                    Button {
                        showingSafari = true
                    } label: {
                        HStack {
                            Image(systemName: "globe")
                            Text("View Recipe Website")
                        }
                        .font(.headline)
                        .foregroundStyle(.blue)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle(recipe.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            // Present SafariView as a sheet
            .sheet(isPresented: $showingSafari) {
                if let url = recipe.sourceURL {
                    SafariView(url: url)
                }
            }
        }
    }
}

// MARK: - Preview

/// A preview for `RecipeDetailView` with a sample recipe.
#Preview {
    RecipeDetailView(recipe: DeveloperPreview.recipe)
}
