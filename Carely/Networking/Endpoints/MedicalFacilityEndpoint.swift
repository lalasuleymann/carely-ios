//
//  MedicalFacilityEndpoint.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import Foundation

enum MedicalFacilityEndpoint: Endpoint {
    case getAll(type: String?, search: String?)
    case getById(id: Int)

    var baseURL: String {
        APIConfig.baseURL
    }

    var path: String {
        switch self {
        case .getAll:
            return "/api/MedicalFacilities"
        case .getById(let id):
            return "/api/MedicalFacilities/\(id)"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .getAll(let type, let search):
            var items: [URLQueryItem] = []

            if let type {
                items.append(
                    URLQueryItem(name: "type", value: type)
                )
            }

            if let search, !search.isEmpty {
                items.append(
                    URLQueryItem(name: "search", value: search)
                )
            }

            return items.isEmpty ? nil : items

        case .getById:
            return nil
        }
    }

    var requiresAuthentication: Bool {
        false
    }
}
