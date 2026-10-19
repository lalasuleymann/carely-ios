//
//  LocalizationManager.swift
//  Carely
//
//  Created by Lala Suleymanova on 19.10.26.
//

import SwiftUI

enum LocalizationManager {

    static func localized(_ key: String,locale: Locale) -> String {
        String(
            localized: String.LocalizationValue(key),
            table: "Localizable",
            locale: locale
        )
    }
}
