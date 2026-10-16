//
//  DoctorEndpoint.swift
//  Carely
//
//  Created by Lala Suleymanova on 16.10.26.
//

import Foundation

enum DoctorEndpoint: Endpoint {
    case all(
        specialtyId: Int? = nil,
        minRating: Double? = nil,
        maxPrice: Double? = nil,
        search: String? = nil
    )
    case detail(id: Int)

    var baseURL: String {
        APIConfig.baseURL
    }

    var path: String {
        switch self {
        case .all:
            return "/api/doctors"
        case .detail(let id):
            return "/api/doctors/\(id)"
        }
    }

    var method: HttpMethod {
        .get
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .all(let specialtyId, let minRating, let maxPrice, let search):
            var items: [URLQueryItem] = []

            if let specialtyId {
                items.append(
                    URLQueryItem(
                        name: "specialtyId",
                        value: String(specialtyId)
                    )
                )
            }

            if let minRating {
                items.append(
                    URLQueryItem(
                        name: "minRating",
                        value: String(minRating)
                    )
                )
            }

            if let maxPrice {
                items.append(
                    URLQueryItem(
                        name: "maxPrice",
                        value: String(maxPrice)
                    )
                )
            }

            if let search, !search.isEmpty {
                items.append(
                    URLQueryItem(
                        name: "search",
                        value: search
                    )
                )
            }

            return items

        case .detail:
            return []
        }
    }
}
