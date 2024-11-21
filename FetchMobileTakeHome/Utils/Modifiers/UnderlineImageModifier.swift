//
//  UnderlineImageModifier.swift
//  FetchMobileTakeHome
//
//  Created by Jack Robinson on 11/21/24.
//
import SwiftUI
import Foundation
struct UnderlineImageModifier: ViewModifier {
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        VStack {
            content
            Rectangle()
                .frame(height: 2)
                .foregroundColor(isSelected ? .blue : .clear)
        }
    }
}
