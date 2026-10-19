//
//  NearbyPlaceCategory.swift
//  Carely
//
//  Created by Lala Suleymanova on 15.10.26.
//

import SwiftUI

enum NearbyPlaceCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case clinics = "Clinics"
    case hospitals = "Hospitals"
    case pharmacies = "Pharmacies"
    case laboratories = "Laboratories"

    var id: String {
        rawValue
    }

    // MARK: - Localized Title
    func title(locale: Locale) -> String {
        LocalizationManager.localized(rawValue, locale: locale)
    }

    // MARK: - Icon
    var icon: String {
        switch self {
        case .all, .clinics:
            return "cross.case"
        case .hospitals:
            return "building.2"
        case .pharmacies:
            return "pills"
        case .laboratories:
            return "testtube.2"
        }
    }

    // MARK: - Backend Type
    var backendType: String? {
        switch self {
        case .all:
            return nil
        case .clinics:
            return "Clinic"
        case .hospitals:
            return "Hospital"
        case .pharmacies:
            return "Pharmacy"
        case .laboratories:
            return "Laboratory"
        }
    }

    // MARK: - Matching
    func matches(_ type: String) -> Bool {
        guard self != .all else {
            return true
        }

        switch self {
        case .all:
            return true
        case .clinics:
            return type == "0"
        case .hospitals:
            return type == "1"
        case .pharmacies:
            return type == "2"
        case .laboratories:
            return type == "3"
        }
    }
}
