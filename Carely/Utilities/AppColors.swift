//
//  AppColors.swift
//  Carely
//
//  Created by Lala Suleymanova on 07.10.26.
//

import SwiftUI
import UIKit

enum AppColors {
    static let primary = Color(hex: "0F9D8A")
    static let primaryDark = Color(hex: "087A6C")
    static let onPrimary = Color.white

    static let background = Color(
        light: Color(hex: "F7F9F9"),
        dark: Color(hex: "101514")
    )

    static let surface = Color(
        light: .white,
        dark: Color(hex: "18201F")
    )

    static let primaryText = Color(
        light: Color(hex: "17201F"),
        dark: Color(hex: "F4F7F6")
    )

    static let secondaryText = Color(
        light: Color(hex: "6B7775"),
        dark: Color(hex: "A8B2B0")
    )

    static let divider = Color(
        light: Color(hex: "E6ECEB"),
        dark: Color(hex: "2A3533")
    )

    static let success = Color(hex: "34A853")
    static let warning = Color(hex: "F5A623")
    static let error = Color(hex: "E55353")
}

extension Color {
    init(light: Color, dark: Color) {
        self.init(
            UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(dark)
                    : UIColor(light)
            }
        )
    }

    init(hex: String) {
        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let red = Double((int >> 16) & 0xFF) / 255
        let green = Double((int >> 8) & 0xFF) / 255
        let blue = Double(int & 0xFF) / 255

        self.init(
            red: red,
            green: green,
            blue: blue
        )
    }
}
