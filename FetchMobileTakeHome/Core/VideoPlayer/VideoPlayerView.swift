//
//  VideoPlayerView.swift
//  FetchMobileTakeHome
//
//  Created by Jack Robinson on 11/21/24.
//

import SwiftUI
import AVFoundation
import AVKit
import YouTubePlayerKit

/// A reusable video player view for embedding YouTube videos or handling unsupported URLs.
///
/// This view integrates with a YouTube player and provides optional controls for playback, fullscreen mode, and autoplay.
/// It also listens for external interactions, such as the presentation of a Safari view, to pause playback when needed.
///
/// - Parameters:
///   - url: The URL of the video to be played. Must be a valid YouTube link to enable playback.
///   - autoPlay: A boolean indicating whether the video should start playing automatically. Defaults to `true`.
///   - showControls: A boolean indicating whether playback controls should be displayed. Defaults to `true`.
///   - showFullscreenButton: A boolean indicating whether a fullscreen button should be available. Defaults to `true`.
///   - frameHeight: The height of the video frame. Defaults to `250`.
///   - isSafariPresented: A binding to track the presentation of a Safari view. Playback pauses when this becomes `true`.
struct VideoPlayerView: View {
    
    // MARK: - Properties
    
    /// The URL of the video to play.
    let url: URL
    
    /// Whether the video should start playing automatically.
    var autoPlay: Bool = true
    
    /// Whether playback controls should be displayed.
    var showControls: Bool = true
    
    /// Whether a fullscreen button should be available.
    var showFullscreenButton: Bool = true
    
    /// The height of the video frame.
    var frameHeight: CGFloat = 250
    
    /// A binding that tracks whether the Safari view is presented. Used to pause playback.
    @Binding var isSafariPresented: Bool

    /// The YouTubePlayer instance, configured if the URL is a YouTube link.
    private let youtubePlayer: YouTubePlayer?
    
    // MARK: - Initializer
    
    /// Initializes a `VideoPlayerView` with the given parameters.
    ///
    /// - Parameters:
    ///   - url: The URL of the video to play.
    ///   - autoPlay: Whether the video should start playing automatically. Defaults to `true`.
    ///   - showControls: Whether playback controls should be displayed. Defaults to `true`.
    ///   - showFullscreenButton: Whether a fullscreen button should be available. Defaults to `true`.
    ///   - frameHeight: The height of the video frame. Defaults to `250`.
    ///   - isSafariPresented: A binding to track the presentation of a Safari view.
    init(
        url: URL,
        autoPlay: Bool = true,
        showControls: Bool = true,
        showFullscreenButton: Bool = true,
        frameHeight: CGFloat = 250,
        isSafariPresented: Binding<Bool>
    ) {
        self.url = url
        self.autoPlay = autoPlay
        self.showControls = showControls
        self.showFullscreenButton = showFullscreenButton
        self.frameHeight = frameHeight
        self._isSafariPresented = isSafariPresented
        
        // Configure YouTubePlayer if URL is a YouTube link
        if url.host?.contains("youtube.com") == true || url.host?.contains("youtu.be") == true {
            self.youtubePlayer = YouTubePlayer(
                source: .url(url),
                configuration: .init(
                    autoPlay: autoPlay,
                    showControls: showControls,
                    showFullscreenButton: showFullscreenButton
                )
            )
        } else {
            self.youtubePlayer = nil
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if let youtubePlayer = youtubePlayer {
                // Display the YouTube player
                YouTubePlayerView(youtubePlayer)
                    .frame(height: frameHeight)
                    .onChange(of: isSafariPresented) { isPresented in
                        if isPresented {
                            youtubePlayer.pause() // Pause the video when Safari view is shown
                        }
                    }
            } else {
                // Fallback for unsupported URLs
                Text("Invalid or Unsupported Video URL")
                    .foregroundColor(.red)
                    .frame(height: frameHeight)
                    .multilineTextAlignment(.center)
            }
        }
        .background(Color.black)
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}
