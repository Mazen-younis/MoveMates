//
//  ColorManager.swift
//  MoveMates
//
//  Created by Mazen Younis on 19/05/2025.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }

    // Global App Color Palette
    static var jetBlack: Color { Color(hex: "#000000") }
    static var aquaBlue: Color { Color(hex: "#00C2D1") }
    static var pureWhite: Color { Color(hex: "#FFFFFF") }
    static var coolGray: Color { Color(hex: "#9CA3AF") }
    static var charcoalGray: Color { Color(hex: "#374151") }
}



