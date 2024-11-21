//
//  RecipeView.swift
//  FetchMobileTakeHome
//
//  Created by Jack Robinson on 11/21/24.
//

import SwiftUI

/// A SwiftUI view that displays a list or grid of recipes, allowing users to toggle between views,
/// refresh the data, and handle empty or error states gracefully.
///
/// This view is tied to a `RecipeViewModel` for managing the state and logic, including fetching
/// recipes from a remote API. Users can also view detailed information about a recipe via a sheet.
///
/// - Dependencies:
///   - `RecipeViewModel` for managing the recipes and fetch state.
///   - `RecipeCell` and `RecipeListCell` for rendering recipes in grid and list formats, respectively.
///   - `RecipeDetailView` for presenting recipe details.
///
/// - Features:
///   - Toggling between grid and list views.
///   - Pull-to-refresh functionality.
///   - Error handling with retry options.
///   - Empty state UI for when no recipes are available.
@MainActor
struct RecipeView: View {
    
    // MARK: - Properties
    
    /// The view model responsible for managing the state of recipes.
    @StateObject private var viewModel: RecipeViewModel
    
    /// The currently selected section (grid or list view).
    @State private var currentSection: ViewMode = .grid
    
    /// The recipe currently selected for detailed viewing.
    @State private var selectedRecipe: Recipe?
    
    /// Indicates whether an error alert is shown.
    @State private var showError = false
    
    /// Tracks the scene's lifecycle phase to trigger data refresh when the app becomes active.
    @Environment(\.scenePhase) private var scenePhase
    
    // MARK: - Initializer
    
    /// Creates an instance of `RecipeView` with a specified view model.
    ///
    /// - Parameter viewModel: The `RecipeViewModel` instance to manage the state.
    ///   Defaults to a new `RecipeViewModel` instance.
    init(viewModel: RecipeViewModel = RecipeViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - View Mode Enum
    
    /// An enumeration representing the available view modes: list or grid.
    enum ViewMode: String, CaseIterable {
        case list, grid
        
        /// The icon name for the view mode.
        var icon: String {
            switch self {
            case .list: return "list.bullet"
            case .grid: return "square.grid.2x2"
            }
        }
        
        /// An accessibility label for the view mode.
        var accessibilityLabel: String {
            switch self {
            case .list: return "List View"
            case .grid: return "Grid View"
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                toggleButtons
                    .background(Color(.systemBackground))
                
                contentView
            }
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await fetchRecipes()
            }
            .task {
                await fetchRecipes()
            }
            .sheet(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .alert("Error Loading Recipes", isPresented: $showError) {
                Button("Retry") {
                    Task {
                        await fetchRecipes()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    Task {
                        await fetchRecipes()
                    }
                }
            }
        }
    }
    
    // MARK: - Views
    
    /// The main content view that displays recipes, loading, error, or empty states.
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.recipes.isEmpty {
            loadingView
        } else if let errorMessage = viewModel.errorMessage {
            errorView(message: errorMessage)
        } else if viewModel.recipes.isEmpty {
            emptyStateView()
        } else {
            content
        }
    }
    
    /// A view displayed when recipes are being loaded.
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading recipes...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// A view displayed when an error occurs while fetching recipes.
    ///
    /// - Parameter message: The error message to display.
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
            
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button {
                Task {
                    await fetchRecipes()
                }
            } label: {
                Text("Try Again")
                    .frame(maxWidth: 200)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// A view displayed when no recipes are available.
    private func emptyStateView() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No recipes available.")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// The toggle buttons for switching between list and grid views.
    private var toggleButtons: some View {
        HStack(spacing: 0) {
            ForEach(ViewMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentSection = mode
                    }
                } label: {
                    Image(systemName: mode.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 20)
                        .foregroundColor(.primary)
                }
                .modifier(UnderlineImageModifier(isSelected: currentSection == mode))
                .frame(maxWidth: .infinity)
                .accessibilityLabel(mode.accessibilityLabel)
                .accessibilityAddTraits(currentSection == mode ? .isSelected : [])
            }
        }
        .padding()
    }
    
    /// The content view displaying recipes in either grid or list format.
    private var content: some View {
        Group {
            switch currentSection {
            case .grid:
                gridContent
            case .list:
                listContent
            }
        }
    }
    
    /// A grid layout displaying recipes.
    private var gridContent: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ],
                spacing: 10
            ) {
                recipeContent
            }
            .padding(.horizontal, 16)
        }
        .animation(.default, value: viewModel.recipes)
    }
    
    /// A list layout displaying recipes.
    private var listContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                recipeContent
            }
            .padding(.horizontal, 16)
        }
        .animation(.default, value: viewModel.recipes)
    }
    
    /// The common content displayed in both grid and list layouts.
    private var recipeContent: some View {
        ForEach(viewModel.recipes) { recipe in
            Group {
                if currentSection == .grid {
                    RecipeCell(recipe: recipe)
                        .frame(height: 200)
                } else {
                    RecipeListCell(recipe: recipe)
                }
            }
            .onTapGesture {
                handleRecipeSelection(recipe)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(recipe.name), \(recipe.cuisine) cuisine")
            .accessibilityAddTraits(recipe.youtubeURL != nil || recipe.sourceURL != nil ? .isButton : [])
        }
    }
    
    // MARK: - Actions
    
    /// Handles the selection of a recipe, triggering a haptic feedback and presenting the detail view.
    ///
    /// - Parameter recipe: The selected recipe.
    private func handleRecipeSelection(_ recipe: Recipe) {
        if recipe.youtubeURL != nil || recipe.sourceURL != nil {
            hapticFeedback()
            selectedRecipe = recipe
        }
    }
    
    /// Triggers a medium haptic feedback.
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Fetches recipes using the view model and handles errors.
    private func fetchRecipes() async {
        do {
            try await viewModel.fetchRecipes()
        } catch {
            showError = true
        }
    }
}

// MARK: - Preview Provider

/// Provides previews for `RecipeView` in different states.
#Preview("Normal State") {
    NavigationView {
        RecipeView()
    }
}

#Preview("Loading State") {
    NavigationView {
        RecipeView(viewModel: {
            let vm = RecipeViewModel()
            vm.simulateLoading()
            return vm
        }())
    }
}

#Preview("Error State") {
    NavigationView {
        RecipeView(viewModel: {
            let vm = RecipeViewModel()
            vm.simulateError()
            return vm
        }())
    }
}
