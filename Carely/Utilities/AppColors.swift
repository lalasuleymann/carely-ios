//
//  AppColors.swift
//  Carely
//
//  Created by Lala Suleymanova on 07.10.26.
//

import SwiftUI

enum AppColors {
    static let primary = Color(hex: "0F9D8A")
    static let primaryDark = Color(hex: "087A6C")
    static let background = Color(hex: "F7F9F9")
    static let surface = Color.white
    static let primaryText = Color(hex: "17201F")
    static let secondaryText = Color(hex: "6B7775")
    static let success = Color(hex: "34A853")
    static let warning = Color(hex: "F5A623")
    static let error = Color(hex: "E55353")
    static let divider = Color(hex: "E6ECEB")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

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
