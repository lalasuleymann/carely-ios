//
//  NearbyPlacesService.swift.swift
//  Carely
//
//  Created by Lala Suleymanova on 15.10.26.
//


import Foundation
import MapKit

struct NearbyPlacesService {

    func search(category: NearbyPlaceCategory,region: MKCoordinateRegion) async throws -> [NearbyPlace] {

        let queries: [String]

        if category == .all {
            queries = [
                "medical clinics",
                "hospitals",
                "pharmacies",
                "medical laboratories"
            ]
        } else {
            queries = [category.searchQuery]
        }

        var places: [NearbyPlace] = []

        for query in queries {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = region

            let search = MKLocalSearch(request: request)
            let response = try await search.start()

            places.append(
                contentsOf: response.mapItems.map {
                    NearbyPlace(mapItem: $0)
                }
            )
        }

        var seen = Set<String>()

        return places.filter { place in
            let key = [
                place.name.lowercased(),
                String(format: "%.5f", place.coordinate.latitude),
                String(format: "%.5f", place.coordinate.longitude)
            ].joined(separator: "|")

            return seen.insert(key).inserted
        }
    }
}
