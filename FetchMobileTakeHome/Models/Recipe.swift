//
//  Model.swift
//  FetchMobileTakeHome
//
//  Created by Jack Robinson on 11/21/24.
//

import Foundation
struct Recipe: Codable, Identifiable, Equatable {
    let cuisine: String
    let name: String
    let photoURLLarge: URL?
    let photoURLSmall: URL?
    let id: UUID
    let sourceURL: URL?
    let youtubeURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case cuisine
        case name
        case photoURLLarge = "photo_url_large"
        case photoURLSmall = "photo_url_small"
        case id = "uuid"
        case sourceURL = "source_url"
        case youtubeURL = "youtube_url"
    }
}
