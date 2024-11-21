//
//  Untitled.swift
//  FetchMobileTakeHome
//
//  Created by Jack Robinson on 11/21/24.
//

import Foundation
import Foundation
import UIKit
import SwiftUI
import SafariServices

class URLHandler {
    // Common URL schemes
    private static let validSchemes = ["http", "https"]
    // Expanded TLD list
    private static let validTLDs = Set([
        "com", "org", "net", "edu", "gov", "io", "co", "app", "dev",
        "uk", "ca", "au", "de", "fr", "jp", "cn", "br", "ru", "in",
        "info", "biz", "me", "tv", "us", "eu"
    ])
    
    static func parseAndValidate(_ urlString: String) -> URL? {
        guard !urlString.isEmpty else { return nil }
        
        var parsedString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle percent encoding
        if let decodedString = parsedString.removingPercentEncoding {
            parsedString = decodedString
        }
        
        // Handle Google redirect URLs
        if parsedString.hasPrefix("/url?q=") {
            guard let startIndex = parsedString.range(of: "=")?.upperBound,
                  let endIndex = parsedString.range(of: "&")?.lowerBound else {
                return nil
            }
            parsedString = String(parsedString[startIndex..<endIndex])
        }
        
        // Add scheme if missing
        if !validSchemes.contains(where: { parsedString.lowercased().hasPrefix("\($0)://") }) {
            parsedString = "https://" + parsedString.replacingOccurrences(of: "://", with: "")
        }
        
        // Remove trailing slashes
        while parsedString.hasSuffix("/") {
            parsedString.removeLast()
        }
        
        // Validate URL
        guard let url = URL(string: parsedString),
              let host = url.host?.lowercased(),
              !host.isEmpty else {
            return nil
        }
        
        // Validate TLD
        let hostComponents = host.components(separatedBy: ".")
        guard hostComponents.count >= 2,
              let tld = hostComponents.last?.lowercased(),
              validTLDs.contains(tld) else {
            return nil
        }
        
        return url
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIViewController {
        guard let validURL = URLHandler.parseAndValidate(url.absoluteString) else {
            let errorView = SafariErrorView(urlString: url.absoluteString) {
                dismiss()
            }
            return UIHostingController(rootView: errorView)
        }
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let safariVC = SFSafariViewController(url: validURL, configuration: config)
        return safariVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct SafariErrorView: View {
    let urlString: String
    let dismissAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
            
            Text("Invalid URL")
                .font(.headline)
            
            Text(urlString)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Close", action: dismissAction)
                .padding()
        }
    }
}
