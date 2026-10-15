//
//  NearbyPlaceCategory.swift
//  Carely
//
//  Created by Lala Suleymanova on 15.10.26.
//

import Foundation

enum NearbyPlaceCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case clinics = "Clinics"
    case hospitals = "Hospitals"
    case pharmacies = "Pharmacies"
    case laboratories = "Laboratories"

    var id: String { rawValue }

    var searchQuery: String {
        switch self {
        case .all:
            return "medical clinics hospitals pharmacies laboratories"
        case .clinics:
            return "medical clinics"
        case .hospitals:
            return "hospitals"
        case .pharmacies:
            return "pharmacies"
        case .laboratories:
            return "medical laboratories"
        }
    }

    var icon: String {
        switch self {
        case .all:
            return "cross.case"
        case .clinics:
            return "cross.case"
        case .hospitals:
            return "building.2"
        case .pharmacies:
            return "pills"
        case .laboratories:
            return "testtube.2"
        }
    }
}
