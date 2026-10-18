//
//  NearbyPlacesService.swift.swift
//  Carely
//
//  Created by Lala Suleymanova on 15.10.26.
//

import Foundation
import MapKit

struct NearbyPlacesService {
    private let networkService: NetworkService

    init(networkService: NetworkService = DefaultNetworkService()) {
        self.networkService = networkService
    }

    func search(category: NearbyPlaceCategory,region: MKCoordinateRegion) async throws -> [NearbyPlace] {

        let response: [MedicalFacilityDTO] =
            try await networkService.request(
                MedicalFacilityEndpoint.getAll(
                    type: category.backendType,
                    search: nil
                ),
                token: nil
            )

        let center = CLLocation(
            latitude: region.center.latitude,
            longitude: region.center.longitude
        )

        return response
            .filter { facility in
                category.matches(String(facility.type))
            }
            .map(NearbyPlace.init(dto:))
            .sorted { first, second in
                let firstLocation = CLLocation(
                    latitude: first.coordinate.latitude,
                    longitude: first.coordinate.longitude
                )

                let secondLocation = CLLocation(
                    latitude: second.coordinate.latitude,
                    longitude: second.coordinate.longitude
                )

                return firstLocation.distance(from: center)
                    < secondLocation.distance(from: center)
            }
    }
}
