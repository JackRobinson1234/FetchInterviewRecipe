//
//  DeveloperPreview.swift
//  FetchMobileTakeHome
//
//  Created by Jack Robinson on 11/21/24.
//

import Foundation
struct DeveloperPreview {
    // Mock recipe
    static let recipe = Recipe(
        cuisine: "Italian",
        name: "Spaghetti Carbonara",
        photoURLLarge: URL(string: "https://example.com/large.jpg"),
        photoURLSmall: URL(string: "https://example.com/small.jpg"),
        id: UUID(),
        sourceURL: URL(string: "https://example.com/recipe"),
        youtubeURL: URL(string: "https://youtube.com/watch?v=123")
    )
    
    // Collection of mock recipes
    static let recipes: [Recipe] = [
        .init(
            cuisine: "Italian",
            name: "Spaghetti Carbonara",
            photoURLLarge: URL(string: "https://example.com/carbonara.jpg"),
            photoURLSmall: nil,
            id: UUID(),
            sourceURL: URL(string: "https://example.com/carbonara"),
            youtubeURL: URL(string: "https://youtube.com/watch?v=123")
        ),
        .init(
            cuisine: "Japanese",
            name: "Tonkotsu Ramen",
            photoURLLarge: URL(string: "https://example.com/ramen.jpg"),
            photoURLSmall: nil,
            id: UUID(),
            sourceURL: nil,
            youtubeURL: URL(string: "https://youtube.com/watch?v=456")
        ),
        .init(
            cuisine: "Mexican",
            name: "Tacos al Pastor",
            photoURLLarge: URL(string: "https://example.com/tacos.jpg"),
            photoURLSmall: nil,
            id: UUID(),
            sourceURL: URL(string: "https://example.com/tacos"),
            youtubeURL: nil
        ),
        .init(
            cuisine: "French",
            name: "Coq au Vin",
            photoURLLarge: URL(string: "https://example.com/coq.jpg"),
            photoURLSmall: nil,
            id: UUID(),
            sourceURL: URL(string: "https://example.com/coq"),
            youtubeURL: URL(string: "https://youtube.com/watch?v=789")
        ),
        .init(
            cuisine: "Indian",
            name: "Butter Chicken",
            photoURLLarge: URL(string: "https://example.com/butter-chicken.jpg"),
            photoURLSmall: nil,
            id: UUID(),
            sourceURL: URL(string: "https://example.com/butter-chicken"),
            youtubeURL: URL(string: "https://youtube.com/watch?v=012")
        )
    ]
}
